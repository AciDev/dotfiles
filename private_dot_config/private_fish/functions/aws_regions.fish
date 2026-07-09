function aws_regions -d "List available AWS regions"
    set -l region
    
    if set -q AWS_DEFAULT_REGION
        set region $AWS_DEFAULT_REGION
    else if set -q AWS_REGION
        set region $AWS_REGION
    else
        set region us-west-1
    end

    if set -q AWS_DEFAULT_PROFILE; or set -q AWS_PROFILE
        aws ec2 describe-regions --region $region 2>/dev/null | grep RegionName | awk -F ':' '{gsub(/"/, "", $2); gsub(/,/, "", $2); gsub(/ /, "", $2); print $2}'
    else
        echo "You must specify an AWS profile." >&2
        return 1
    end
end
