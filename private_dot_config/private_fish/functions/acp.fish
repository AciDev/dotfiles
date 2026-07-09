function acp -d "AWS Change Profile - Assume role or get session token with MFA support"
    # Clear profile if no argument provided
    if test (count $argv) -eq 0
        set -e AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE
        set -e AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
        echo "AWS profile cleared."
        return 0
    end

    set -l profile $argv[1]
    set -l mfa_token $argv[2]

    # Check if profile exists
    set -l available_profiles (aws_profiles)
    if not contains $profile $available_profiles
        set_color red
        echo "Profile '$profile' not found in '~/.aws/config'" >&2
        echo "Available profiles: $available_profiles" >&2
        set_color normal
        return 1
    end

    # Get fallback credentials
    set -l aws_access_key_id (aws configure get aws_access_key_id --profile $profile 2>/dev/null)
    set -l aws_secret_access_key (aws configure get aws_secret_access_key --profile $profile 2>/dev/null)
    set -l aws_session_token (aws configure get aws_session_token --profile $profile 2>/dev/null)

    # Check for MFA configuration
    set -l mfa_serial (aws configure get mfa_serial --profile $profile 2>/dev/null)
    set -l sess_duration (aws configure get duration_seconds --profile $profile 2>/dev/null)

    set -l mfa_opts
    if test -n "$mfa_serial"
        if test -z "$mfa_token"
            read -P "Please enter your MFA token for $mfa_serial: " mfa_token
        end
        if test -z "$sess_duration"
            read -P "Please enter the session duration in seconds (900-43200; default: 3600): " sess_duration
        end
        set mfa_opts --serial-number $mfa_serial --token-code $mfa_token --duration-seconds (test -n "$sess_duration"; and echo $sess_duration; or echo 3600)
    end

    # Check if we need to assume a role
    set -l role_arn (aws configure get role_arn --profile $profile 2>/dev/null)
    set -l sess_name (aws configure get role_session_name --profile $profile 2>/dev/null)

    if test -n "$role_arn"
        # Assume role
        set -l source_profile (aws configure get source_profile --profile $profile 2>/dev/null)
        if test -z "$sess_name"
            set sess_name (test -n "$source_profile"; and echo $source_profile; or echo "profile")
        end

        set -l aws_command aws sts assume-role --role-arn $role_arn $mfa_opts --profile (test -n "$source_profile"; and echo $source_profile; or echo "profile") --role-session-name $sess_name

        # Check for external_id
        set -l external_id (aws configure get external_id --profile $profile 2>/dev/null)
        if test -n "$external_id"
            set aws_command $aws_command --external-id $external_id
        end

        set aws_command $aws_command --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' --output text

        echo "Assuming role $role_arn using profile "(test -n "$source_profile"; and echo $source_profile; or echo "profile")
        
        set -l credentials (eval $aws_command 2>&1)
        if test $status -eq 0
            set -l creds (string split \t $credentials)
            set aws_access_key_id $creds[1]
            set aws_secret_access_key $creds[2]
            set aws_session_token $creds[3]
        end
    else if test -n "$mfa_serial"
        # Get session token with MFA
        set -l aws_command aws sts get-session-token --profile $profile $mfa_opts --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' --output text

        echo "Obtaining session token for profile $profile"
        
        set -l credentials (eval $aws_command 2>&1)
        if test $status -eq 0
            set -l creds (string split \t $credentials)
            set aws_access_key_id $creds[1]
            set aws_secret_access_key $creds[2]
            set aws_session_token $creds[3]
        end
    end

    # Switch to AWS profile
    if test -n "$aws_access_key_id" -a -n "$aws_secret_access_key"
        set -gx AWS_DEFAULT_PROFILE $profile
        set -gx AWS_PROFILE $profile
        set -gx AWS_EB_PROFILE $profile
        set -gx AWS_ACCESS_KEY_ID $aws_access_key_id
        set -gx AWS_SECRET_ACCESS_KEY $aws_secret_access_key

        if test -n "$aws_session_token"
            set -gx AWS_SESSION_TOKEN $aws_session_token
        else
            set -e AWS_SESSION_TOKEN
        end

        echo "Switched to AWS Profile: $profile"
    end
end
