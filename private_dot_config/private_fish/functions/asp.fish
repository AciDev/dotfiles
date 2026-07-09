function asp -d "AWS Set Profile - Set AWS_PROFILE and optionally handle SSO login/logout"
    # Clear profile if no argument provided
    if test (count $argv) -eq 0
        set -e AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE AWS_PROFILE_REGION
        _aws_clear_state
        echo "AWS profile cleared."
        return 0
    end

    set -l profile $argv[1]
    set -l action $argv[2]
    set -l sso_session $argv[3]

    # Check if profile exists
    set -l available_profiles (aws_profiles)
    if not contains $profile $available_profiles
        set_color red
        echo "Profile '$profile' not found in '~/.aws/config'" >&2
        echo "Available profiles: $available_profiles" >&2
        set_color normal
        return 1
    end

    # Set the profile
    set -gx AWS_DEFAULT_PROFILE $profile
    set -gx AWS_PROFILE $profile
    set -gx AWS_EB_PROFILE $profile

    # Get the region for this profile
    set -gx AWS_PROFILE_REGION (aws configure get region 2>/dev/null)

    # Update state file
    _aws_update_state

    # Handle SSO login/logout
    if test "$action" = "login"
        if test -n "$sso_session"
            aws sso login --sso-session $sso_session
        else
            aws sso login
        end
    else if test "$action" = "logout"
        aws sso logout
    end
end
