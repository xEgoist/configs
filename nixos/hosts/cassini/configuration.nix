{
  inputs,
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

  security.acme.defaults.email = "pie@quince.org";
  security.acme.acceptTerms = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.soju = {
    enable = true;
    enableMessageLogging = true;
    hostName = "irc.cassini.internal";
    tlsCertificateKey = ./certs/cassini.internal.key;
    tlsCertificate = ./certs/cassini.internal.crt;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    sslProtocols = "TLSv1.3";
    sslCiphers = null;
    commonHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=paste_limit:20m rate=2r/m;
      limit_req_status 429;
    '';
    virtualHosts."yt.cassini.internal" = {
      enableACME = false;
      forceSSL = true;
      kTLS = true;
      sslCertificate = ./certs/cassini.internal.crt;
      sslCertificateKey = ./certs/cassini.internal.key;
      extraConfig = ''
        allow 10.0.0.0/8;
        deny all;
      '';
    };
    virtualHosts."paste.cassini.internal" = {
      enableACME = false;
      forceSSL = true;
      kTLS = true;
      sslCertificate = ./certs/cassini.internal.crt;
      sslCertificateKey = ./certs/cassini.internal.key;
      locations."/" = {
        proxyPass = "http://127.0.0.1:21338";
      };
      extraConfig = ''
        allow 10.0.0.0/8;
        deny all;
      '';
    };
    virtualHosts."paste.quince.org" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:21338";
        extraConfig = ''
          limit_req zone=paste_limit burst=20 nodelay;
        '';
      };
    };
    virtualHosts."ca.cassini.internal" = {
      root = ./www/ca.cassini.internal;
      enableACME = false;
      forceSSL = true;
      kTLS = true;
      sslCertificate = ./certs/cassini.internal.crt;
      sslCertificateKey = ./certs/cassini.internal.key;
      extraConfig = ''
        allow 10.0.0.0/8;
        deny all;
      '';
    };
  };
  services.invidious = {
    package = pkgs.unstable.invidious;
    enable = true;
    domain = "yt.cassini.internal";
    nginx.enable = true;
    settings.db.user = "invidious";
    settings.db.dbname = "invidious";
  };

  systemd.services.pastel = let
    pastel = inputs.pastel.packages.${pkgs.system}.default;
  in {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    description = "pastebin alternative";
    serviceConfig = {
      ExecStart = "${pastel}/bin/pastel";
      StateDirectory = "pastel";
    };
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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [22 80 443 6697];
  networking.firewall.allowedUDPPorts = [22 80 443 6697];
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
