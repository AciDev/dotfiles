function aws_profiles -d "List available AWS profiles"
    if aws --no-cli-pager configure list-profiles 2>/dev/null
        return 0
    end

    if not test -r "$HOME/.aws/config"
        return 1
    end

    grep -Eo '\[.*\]' "$HOME/.aws/config" | sed -E 's/^[[:space:]]*\[(profile)?[[:space:]]*([^[:space:]]+)\][[:space:]]*$/\2/g'
end
