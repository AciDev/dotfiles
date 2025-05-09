if status is-interactive
    set -U fish_greeting
    set -gx EDITOR nvim
end

starship init fish | source
