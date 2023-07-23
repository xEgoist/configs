## My Config Files.

* Current OS: NIXOS
* WM: Sway (dotfiles derived from EndevourOS sway edition: https://github.com/EndeavourOS-Community-Editions/sway) with few changes and personal configs. 

to install user dot files (.nixpkgs/\*)

`nix-env -iA nixos.all`

non-nixos systems:

`nix-env -iA nixpkgs.all`

## Note:

This is a mildly personalized config for myself. There are many parts that requires tinkering, especially settings defined under my username. However, feel free to use any part of my config files.

## Common Problems:

- Locale warning on non NIXOS systems:

  run the following for fish: 

  `set -Ux LOCALE_ARCHIVE (nix-build --no-out-link '<nixpkgs>' -A glibcLocales)'/lib/locale/locale-archive'`

  or for bash:

  `export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive`

- Sway and playing steam games on full screen:

  I found that playing steam games on sway is not the best experience compared to gnome, especially because the mouse would have a limited area. To get the correct area, I had to disable the second monitor temporarily.

  
  Currently, the procedure is:
    
    - Edit the sway file to comment out my customization for the second monitor.
    - temporarily disable the second monitor using ` swaymsg "output DP-2 dpms off" ` Replace DP-2 with your monitor
    - Play the game.

