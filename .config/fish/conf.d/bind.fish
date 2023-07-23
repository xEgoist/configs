# Binds ctr-z to fg so it can act as a toggle
function fish_user_key_bindings
    bind \cz 'fg 2>/dev/null; commandline -f repaint'
end
fish_user_key_bindings
