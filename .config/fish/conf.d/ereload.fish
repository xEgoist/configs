function ereload -d "Refresh nix-direnv (removes lock and issues direnv reload)"

    if not test -f "flake.lock"
        echo "flake.lock does not exist, make sure to run this command in an existing nix direnv"
        return -1
    end

    rm flake.lock

    command direnv reload
end   
