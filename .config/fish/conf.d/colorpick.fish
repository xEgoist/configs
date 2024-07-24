function colorpick -d "use slurp to get color from the screen... a color picker"
    command nix shell nixpkgs#imagemagick -c sh -c 'grim -g "$(slurp -p)" -t ppm - | convert - -format \'%[pixel:p{0,0}]\' txt:-'

end
