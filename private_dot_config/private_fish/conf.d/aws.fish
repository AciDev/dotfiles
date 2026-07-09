# AWS Plugin Configuration for Fish Shell
# This file is sourced automatically when Fish starts

# Configuration variables (can be set in config.fish or environment)
# AWS_PROFILE_STATE_ENABLED - set to "true" to enable state persistence
# AWS_STATE_FILE - path to state file (default: /tmp/.aws_current_profile)

# Helper functions for state management
function _aws_update_state
    if test "$AWS_PROFILE_STATE_ENABLED" = "true"
        set -l state_file (set -q AWS_STATE_FILE; and echo $AWS_STATE_FILE; or echo /tmp/.aws_current_profile)
        set -l state_dir (dirname $state_file)
        
        if not test -d $state_dir
            return 1
        end
        
        echo "$AWS_PROFILE $AWS_PROFILE_REGION" > $state_file
    end
end

function _aws_clear_state
    if test "$AWS_PROFILE_STATE_ENABLED" = "true"
        set -l state_file (set -q AWS_STATE_FILE; and echo $AWS_STATE_FILE; or echo /tmp/.aws_current_profile)
        set -l state_dir (dirname $state_file)
        
        if not test -d $state_dir
            return 1
        end
        
        echo -n > $state_file
    end
end

# Restore AWS profile state from previous session
if test "$AWS_PROFILE_STATE_ENABLED" = "true"
    set -l state_file (set -q AWS_STATE_FILE; and echo $AWS_STATE_FILE; or echo /tmp/.aws_current_profile)
    
    if test -s $state_file
        set -l aws_state (cat $state_file)
        set -l state_parts (string split " " $aws_state)
        
        if test (count $state_parts) -ge 1
            set -gx AWS_DEFAULT_PROFILE $state_parts[1]
            set -gx AWS_PROFILE $state_parts[1]
            set -gx AWS_EB_PROFILE $state_parts[1]
        end
        
        if test (count $state_parts) -ge 2 -a -n "$state_parts[2]"
            set -gx AWS_PROFILE_REGION $state_parts[2]
            set -gx AWS_DEFAULT_REGION $state_parts[2]
        else if test -n "$AWS_PROFILE"
            set -gx AWS_PROFILE_REGION (aws configure get region 2>/dev/null)
            test -n "$AWS_PROFILE_REGION"; and set -gx AWS_DEFAULT_REGION $AWS_PROFILE_REGION
        end
    end
end
