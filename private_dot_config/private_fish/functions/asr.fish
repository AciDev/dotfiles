function asr -d "AWS Set Region - Set AWS_REGION"
    # Clear region if no argument provided
    if test (count $argv) -eq 0
        set -e AWS_DEFAULT_REGION AWS_REGION
        _aws_update_state
        echo "AWS region cleared."
        return 0
    end

    set -l region $argv[1]

    # Validate region exists
    set -l available_regions (aws_regions 2>/dev/null)
    if test $status -ne 0
        return 1
    end

    if not contains $region $available_regions
        set_color red
        echo "Available regions:" >&2
        aws_regions >&2
        set_color normal
        return 1
    end

    set -gx AWS_REGION $region
    set -gx AWS_DEFAULT_REGION $region
    _aws_update_state
end
