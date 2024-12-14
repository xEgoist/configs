{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  # disabledModules = [ "services/web-apps/invidious.nix" ];
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  nixpkgs.overlays = [
    outputs.overlays.unstable
    outputs.overlays.custom
  ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  # networking.dhcpcd.extraConfig = "nohook resolv.conf";

  networking.hostName = "cassini";
  # AgeNix
  age.secrets.cassiniNginx = {
    file = ../../secrets/cassini.internal.key.age;
    owner = "nginx";
    group = "nginx";
    mode = "0400";
  };


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
      sslCertificateKey = config.age.secrets.cassiniNginx.path;
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
      sslCertificateKey = config.age.secrets.cassiniNginx.path;
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
      sslCertificateKey = config.age.secrets.cassiniNginx.path;
      extraConfig = ''
        allow 10.0.0.0/8;
        deny all;
      '';
    };
  };
  services.invidious = {
    # package = pkgs.unstable.invidious.override({
    #   versions = {
    #     invidious = {
    #       hash = "sha256-oNkEFATRVgPC8Bhp0v04an3LvqgsSEjLZdeblb7n8TI=";
    #       version = "2.20240825.2";
    #       date = "2024.08.26";
    #       commit = "a021b93063f3956fc9bb3cce0fb56ea252422738";
    #     };
    #     videojs = {
    #       hash = "sha256-jED3zsDkPN8i6GhBBJwnsHujbuwlHdsVpVqa1/pzSH4=";
    #     };
    #   };
    # }));
    package = pkgs.unstable.invidious;
    enable = true;
    sig-helper.enable = true;
    sig-helper.package = pkgs.unstable.inv-sig-helper;
    domain = "yt.cassini.internal";
    nginx.enable = true;
    settings.db.user = "invidious";
    settings.db.dbname = "invidious";
    settings.po_token = "MnQIodLLk0fi1AiZ5ZKZgLHZR5DP4P6-99tiBek4eVfm3UW4kz7gqkFbIjGehDiDgwXfGNiBl1SnMjhejcKHmN5J--pEIjFNTAhVZyhuiX9M2HAhiik6ZaGF2IC-aG8qRuQBCduKjlWogsTC17aKPUsPaja9bQ==";
    settings.visitor_data = "CgthcDdrdHhFVlNvNCiglJ26BjIKCgJVUxIEGgAgVA%3D%3D";
  };

  systemd.services.pastel = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "pastebin alternative";
    serviceConfig = {
      ExecStart = "${pkgs.pastel}/bin/pastel";
      StateDirectory = "pastel";
    };
  };

  users.users.cassini = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
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
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    6697
  ];
  networking.firewall.allowedUDPPorts = [
    22
    80
    443
    6697
  ];
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
