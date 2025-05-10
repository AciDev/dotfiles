if status is-interactive
    set -U fish_greeting
    set -gx EDITOR nvim
end

function starship_transient_rprompt_func
    starship module time
end

starship init fish | source
enable_transience
