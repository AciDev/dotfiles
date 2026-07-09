# Completions for asp (AWS Set Profile)
complete -c asp -f
complete -c asp -a '(aws_profiles)' -d "AWS Profile"
complete -c asp -n '__fish_seen_subcommand_from (aws_profiles)' -a 'login logout' -d "SSO Action"
