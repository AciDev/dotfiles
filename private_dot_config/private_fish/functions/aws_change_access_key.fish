function aws_change_access_key -d "AWS Change Access Key - Rotate AWS access keys for a profile"
    if test (count $argv) -eq 0
        echo "usage: aws_change_access_key <profile>"
        return 1
    end

    set -l profile $argv[1]

    # Get current access key
    set -l original_aws_access_key_id (aws configure get aws_access_key_id --profile $profile)

    # Set the profile
    if not asp $profile
        return 1
    end

    echo "Generating a new access key pair for you now."
    if aws --no-cli-pager iam create-access-key
        echo "Insert the newly generated credentials when asked."
        aws --no-cli-pager configure --profile $profile
    else
        echo "Current access keys:"
        aws --no-cli-pager iam list-access-keys
        echo "Profile \"$profile\" is currently using the $original_aws_access_key_id key. You can delete an old access key by running: aws --profile $profile iam delete-access-key --access-key-id AccessKeyId"
        return 1
    end

    read -P "Would you like to disable your previous access key ($original_aws_access_key_id) now? [y/N] " -l yn
    switch $yn
        case Y y
            echo -n "Disabling access key $original_aws_access_key_id..."
            if aws --no-cli-pager iam update-access-key --access-key-id $original_aws_access_key_id --status Inactive
                echo "done."
            else
                echo "Failed to disable $original_aws_access_key_id key."
            end
        case '*'
            # Do nothing
    end

    echo "You can now safely delete the old access key by running: aws --profile $profile iam delete-access-key --access-key-id $original_aws_access_key_id"
    echo "Your current keys are:"
    aws --no-cli-pager iam list-access-keys
end
