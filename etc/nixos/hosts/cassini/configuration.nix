{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["bcachefs"];
  # networking.dhcpcd.extraConfig = "nohook resolv.conf";

  networking.hostName = "cassini";

  # environment.enableDebugInfo = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    virtualHosts."yt.cassini.internal" = {
      enableACME = false;
      forceSSL = true;
      sslCertificate = ./certs/yt.cassini.internal.crt;
      sslCertificateKey = ./certs/yt.cassini.internal.key;
    };
  };
  services.invidious = {
    enable = true;
    domain = "yt.cassini.internal";
    nginx.enable = true;
  };

  users.users.cassini = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel"];
    packages = with pkgs; [
      zellij
      fzf
      irssi
      libnotify
      mpc_cli
      mpv
      ncmpc
      w3m
      tealdeer
      unzip
      xdg-utils
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop
    direnv
    # Enable General Man Pages
    man-pages
    man-pages-posix
    nix-direnv
    nix-index
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [22 80 443];
  networking.firewall.allowedUDPPorts = [22 80 443];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
