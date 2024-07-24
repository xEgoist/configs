function emacs
    command emacs $argv > /dev/null 2>&1 &
    disown
end
