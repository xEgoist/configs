## My Config Files.

* Current OS: NIXOS
* WM: Sway (dotfiles derived from EndevourOS sway edition: https://github.com/EndeavourOS-Community-Editions/sway) with few changes and personal configs. 

to install user dot files (.nixpkgs/\*)

`nix-env -iA nixos.all`

non-nixos systems:

`nix-env -iA nixpkgs.all`

## Note:

Dotfiles aren't complete. There is so much configs going inside .config that needs to be automated, especially the sway configs.


## Common Problems:

- Locale warning on non NIXOS systems:

run the following for fish: 

`set -Ux LOCALE_ARCHIVE (nix-build --no-out-link '<nixpkgs>' -A glibcLocales)'/lib/locale/locale-archive'`

or for bash:

`export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive`
