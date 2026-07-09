function aws_account -d "AWS SSO - dynamically pick an account + role and switch to it"
    if not type -q fzf
        echo "aws_account requires fzf" >&2
        return 1
    end

    set -l session $argv[1]
    test -z "$session"; and set session default

    # 1. Get a valid SSO token, logging in if the cache is empty/expired
    set -l tokinfo (_aws_sso_token $session)
    if test $status -ne 0
        set_color yellow
        echo "No valid SSO session - logging in..."
        set_color normal
        aws sso login --sso-session $session; or return 1
        set tokinfo (_aws_sso_token $session)
        or begin
            echo "Could not read SSO token after login" >&2
            return 1
        end
    end
    set -l parts (string split \t -- $tokinfo)
    set -l token $parts[1]
    set -l sso_region $parts[2]

    # 2. Pick an account from the live list your login grants
    set -l line (aws --no-cli-pager sso list-accounts \
        --access-token $token --region $sso_region \
        --query 'accountList[].[accountId,accountName]' --output text \
        | sort -t \t -k2 \
        | fzf --prompt="Account > " --with-nth=2..)
    or return 1
    set -l aparts (string split \t -- $line)
    set -l account_id $aparts[1]
    set -l account_name $aparts[2]

    # 3. Pick a role available in that account
    set -l role (aws --no-cli-pager sso list-account-roles \
        --access-token $token --region $sso_region --account-id $account_id \
        --query 'roleList[].roleName' --output text \
        | string split \t \
        | fzf --prompt="Role > ")
    or return 1

    # 4. Materialize a profile and switch to it (CLI auto-refreshes creds)
    set -l slug (string lower -- (string replace -a -r '[^A-Za-z0-9]+' '-' -- $account_name) | string trim -c -)
    set -l profile "$slug-$role"

    aws configure set sso_session $session --profile $profile
    aws configure set sso_account_id $account_id --profile $profile
    aws configure set sso_role_name $role --profile $profile
    aws configure set region $sso_region --profile $profile

    asp $profile
    set_color green
    echo "Switched to profile: $profile  ($account_name / $role)"
    set_color normal
    aws --no-cli-pager sts get-caller-identity
end
