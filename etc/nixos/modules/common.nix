{pkgs, unstable, defaultUser, ...}:
{
  # Turn on nix flakes (TODO: Remove once it's no longer experimental)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  nix.settings.auto-optimise-store = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  security.pki.certificates = [ (builtins.readFile ./intermRoot.crt) ];
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ defaultUser ];
    keepEnv = true;
    persist = true;
  }];
  security.sudo.enable = false;

  boot.tmp.cleanOnBoot = true;
  networking.dhcpcd.enable = true;
  services.resolved.enable = false;
  time.timeZone = "US/Central";

  programs.fish.enable = true;
  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      core = {
        editor = "hx";
      };
      commit = {
        verbose = true;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    # Enable General Man Pages
    man-pages
    man-pages-posix
    nix-index
    unstable.helix
  ];
  environment.variables.EDITOR = "hx";
}
