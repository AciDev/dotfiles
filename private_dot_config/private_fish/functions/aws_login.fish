function aws_login -d "AWS SSO Login - pick a profile (fzf) and log in via SSO"
    set -l profile $argv[1]

    # No profile given: pick one interactively
    if test -z "$profile"
        if type -q fzf
            set profile (aws_profiles | fzf --prompt="AWS profile > " --no-multi)
            or return 1
        else
            echo "usage: aws_login <profile>" >&2
            echo "Available profiles: "(aws_profiles) >&2
            return 1
        end
    end

    if test -z "$profile"
        return 1
    end

    # Reuse the cached SSO session if it is still valid
    if aws sts get-caller-identity --profile $profile --no-cli-pager >/dev/null 2>&1
        set_color green
        echo "Session for '$profile' still valid - skipping browser login."
        set_color normal
        asp $profile
    else
        asp $profile login
        or return 1
    end

    # Confirm who we are
    aws --no-cli-pager sts get-caller-identity
end
