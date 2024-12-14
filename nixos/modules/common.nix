{
  outputs,
  pkgs,
  defaultUser,
  ...
}:
{

  nixpkgs.overlays = [
    outputs.overlays.unstable
  ];
  # Turn on nix flakes (TODO: Remove once it's no longer experimental)
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    extra-trusted-users = [ defaultUser ];
  };
  nix.settings.auto-optimise-store = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  security.pki.certificates = [ (builtins.readFile ./saturnChain.crt) ];
  security.doas.enable = true;
  security.doas.extraRules = [
    {
      users = [ defaultUser ];
      keepEnv = true;
      persist = true;
    }
  ];
  security.sudo.enable = false;

  boot.tmp.cleanOnBoot = true;
  networking.useNetworkd = true;
  networking.useDHCP = false;
  systemd.network.networks =
    let
      networkConfig = {
        DHCP = "yes";
        DNSSEC = "yes";
        # DNSOverTLS = "yes";
      };
    in
    {
      "40-wired" = {
        enable = true;
        name = "en*";
        inherit networkConfig;
      };
    };
  systemd.network.wait-online.anyInterface = true;
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
  documentation.man.generateCaches = false;
}
