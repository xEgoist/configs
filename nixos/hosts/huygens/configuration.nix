# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # NOTE: Huygens doesn't require any overlays for now

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "bcachefs" ];

  age.secrets.huygensStunnel = {
    file = ../../secrets/huygens.internal.key.age;
    owner = "nobody";
    group = "nogroup";
    mode = "0400";
  };
  age.secrets.huygensNginx = {
    file = ../../secrets/huygens.internal.key.age;
    owner = "nginx";
    group = "nginx";
    mode = "0400";
  };

  fileSystems."/persist" = {
    device = "UUID=066511c4-76fc-49fa-b71e-a411377877a4";
    fsType = "bcachefs";
    neededForBoot = true;
  };

  fileSystems."/export" = {
    device = "/persist";
    fsType = "none";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  # services.nfs.server.exports = ''
  #   /export/music 10.0.0.0/16(rw,no_subtree_check,no_root_squash)
  #   /export/torrent 10.0.0.0/16(rw,sync,no_subtree_check,no_root_squash)
  # '';
  # services.nfs.server.exports = ''
  #   # /export/music 127.0.0.1(rw,fsid=0,insecure,no_subtree_check)
  #   /export/music 127.0.0.1(rw,insecure,no_subtree_check,no_root_squash)
  #   /export/torrent 127.0.0.1(rw,insecure,no_subtree_check,no_root_squash)

  #   # /export/torrent 10.0.0.0/16(rw,sync,no_subtree_check,no_root_squash)
  # '';
  services.nfs.server.exports = ''
    /export 127.0.0.1(rw,fsid=0,insecure,no_subtree_check,no_root_squash)
    /export/music 127.0.0.1(rw,insecure,no_subtree_check,no_root_squash)
    /export/torrent 127.0.0.1(rw,insecure,no_subtree_check,no_root_squash)
    /export/games 127.0.0.1(rw,insecure,no_subtree_check,no_root_squash)
  '';

  services.stunnel.enable = true;
  services.stunnel.servers = {
    nfs = {
      accept = 20490;
      connect = "127.0.0.1:2049";
      CAfile = "/etc/ssl/certs/ca-bundle.crt";
      cert = "${./certs/huygens.internal.crt}";
      key = config.age.secrets.huygensStunnel.path;
      verifyChain = "yes";
      requireCert = "yes";
    };
  };

  services.gonic = {
    enable = true;
    settings = {
      playlists-path = [ "/persist/music/playlists" ];
      podcast-path = [ "/persist/music/podcasts" ];
      music-path = [ "/persist/music" ];
    };
  };

  services.atticd = {
    enable = true;

    # Replace with absolute path to your environment file
    environmentFile = "/etc/attic.env";

    settings = {
      listen = "[::]:8080";

      jwt = { };

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
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
    proxyTimeout = "600s";

    virtualHosts."gonic.huygens.internal" = {
      locations."/".proxyPass = "http://127.0.0.1:4747";
      enableACME = false;
      forceSSL = true;
      kTLS = true;
      sslCertificate = ./certs/huygens.internal.crt;
      sslCertificateKey = config.age.secrets.huygensNginx.path;
    };

    virtualHosts."cache.huygens.internal" = {
      locations."/".proxyPass = "http://${config.services.atticd.settings.listen}";
      enableACME = false;
      forceSSL = true;
      kTLS = true;
      sslCertificate = ./certs/huygens.internal.crt;
      sslCertificateKey = config.age.secrets.huygensNginx.path;
      extraConfig = ''
        client_max_body_size 2048M;
      '';
    };

  };

  networking.hostName = "huygens";

  services.openssh = {
    enable = true;
    # settings.PasswordAuthentication = false;
  };

  users.users.huygens = {
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
    443
    20490
  ];
  networking.firewall.allowedUDPPorts = [
    22
    443
    20490
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
