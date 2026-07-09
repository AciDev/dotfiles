function eks_kubeconfig -d "Fuzzy-pick an EKS cluster (region auto-detected) and update kubeconfig"
    if not type -q fzf
        echo "eks_kubeconfig requires fzf" >&2
        return 1
    end

    # Regions to search: args > $EKS_REGIONS > current profile's region
    set -l regions $argv
    if test (count $regions) -eq 0
        if set -q EKS_REGIONS
            set regions (string split ' ' -- $EKS_REGIONS)
        else
            set regions (aws configure get region 2>/dev/null)
        end
    end
    if test (count $regions) -eq 0
        echo "No region to search - pass regions as args, set \$EKS_REGIONS, or configure a profile region" >&2
        return 1
    end

    # Discover clusters and the region each one lives in
    set -l rows
    for r in $regions
        for c in (aws --no-cli-pager eks list-clusters --region $r --query 'clusters[]' --output text 2>/dev/null | string split \t)
            test -n "$c"; and set -a rows "$c"\t"$r"
        end
    end

    if test (count $rows) -eq 0
        echo "No EKS clusters found in: $regions" >&2
        return 1
    end

    # Pick - align the columns so the region list isn't ragged
    set -l line (printf '%s\n' $rows \
        | awk -F'\t' '{printf "%-40s %s\n", $1, $2}' \
        | fzf --prompt="EKS cluster > ")
    or return 1

    set -l p (string split -n ' ' -- $line)
    set -l cluster $p[1]
    set -l region $p[-1]

    echo "Updating kubeconfig for $cluster ($region)..."
    aws --no-cli-pager eks --region $region update-kubeconfig --name $cluster
end
