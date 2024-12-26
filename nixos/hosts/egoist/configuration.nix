{
  inputs,
  outputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    outputs.overlays.unstable
    outputs.overlays.custom
    outputs.overlays.modifications
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "Egoist";
  # networking.nameservers = [ "1.1.1.1" ];

  # networking.extraHosts = "";

  # We use dhcpcd here. no network manager BS.
  # networking.dhcpcd.extraConfig = "nohook resolv.conf";
  nixpkgs.config.allowUnfree = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  age.identityPaths = [ "/var/lib/persistent/titan_ed25519" ];
  age.secrets.titanStunnel = {
    file = ../../secrets/titan.internal.key.age;
    owner = "nobody";
    group = "nogroup";
    mode = "0400";
  };

  # # SWITCH
  # networking.interfaces.enp4s0.ipv4.addresses = [
  #   {
  #     address = "192.168.88.2";
  #     prefixLength = 24;
  #   }
  # ];
  services.stunnel.enable = true;
  services.stunnel.clients = {
    nfs = {
      connect = "10.0.1.3:20490";
      accept = "127.0.0.1:2049";
      cert = "${./certs/titan.internal.crt}";
      key = config.age.secrets.titanStunnel.path;
      CAfile = "/etc/ssl/certs/ca-bundle.crt";
    };
  };

  # fileSystems."/mnt/music" = {
  #   device = "10.0.1.3:/export/music";
  #   fsType = "nfs";
  #   # options = [ "rw" "sync" "hard" "noatime" "intr" "rsize=8192" "wsize=8192" ];
  #   options = [ "noatime" "nfsvers=4.2" "rsize=1048576" "wsize=1048576" "intr" ];
  # };
  fileSystems."/mnt/music" = {
    device = "127.0.0.1:/music";
    fsType = "nfs";
    options = [
      "noatime"
      "nfsvers=4.2"
      "rsize=1048576"
      "wsize=1048576"
      "soft"
      "bg"
      "x-systemd.requires=stunnel.service"
    ];
    # options = [ "noauto" "proto=tcp" "nfsvers=4.2" ];
  };

  # fileSystems."/mnt/torrent" = {
  #   device = "10.0.1.3:/export/torrent";
  #   fsType = "nfs";
  #   # options = [ "rw" "sync" "hard" "noatime" "intr" "rsize=8192" "wsize=8192" ];
  #   options = [ "rw" "noatime" "nfsvers=4.2" "rsize=1048576" "wsize=1048576" "intr" ];
  # };

  fileSystems."/mnt/torrent" = {
    device = "127.0.0.1:/torrent";
    fsType = "nfs";
    options = [
      "rw"
      "noatime"
      "nfsvers=4.2"
      "rsize=1048576"
      "wsize=1048576"
      "soft"
      "bg"
      "x-systemd.requires=stunnel.service"
    ];
  };

  fileSystems."/mnt/games" = {
    device = "127.0.0.1:/games";
    fsType = "nfs";
    options = [
      "rw"
      "noatime"
      "nfsvers=4.2"
      "rsize=1048576"
      "wsize=1048576"
      "soft"
      "bg"
      "x-systemd.requires=stunnel.service"
    ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    # systemWide = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    # Pulse/Jack isn't really needed these days as many have adopted pipewire.
    # Firefox is currently not ideal for recording with only pipewire.
    # However, when disabling all the garbage audio 'enhancement' stuff, it works flawlessly.
    # I hate when recording software tries to "help" anyway. No time have i ever wanted AGC!.
    # https://wiki.archlinux.org/title/Firefox/Tweaks#Disable_WebRTC_audio_post_processing
    # Otherwise if nothing works, pulse may be enabled here.

    # 2023-12-27: Baldur's Gate 3 Seems to want pulse :(
    pulse.enable = true;
    # jack.enable = true;
  };
  environment.enableDebugInfo = true;
  services.pipewire.extraConfig.pipewire = {
    "low-latency-clock" = {
      context.properties = {
        default.clock.rate = 384000;
        default.clock.allowed-rates = [ 384000 ];
        # Low Latency (If buggy, comment out)
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
        # "link.max-buffers" = 16;
      };
    };
  };

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  environment.variables.EDITOR = "hx";

  # Firefox

  programs.firefox = {
    enable = true;
    preferences = {
      "browser.tabs.inTitlebar" = 0;
      # FUCK GTK File Chooser, use KDE from extraPortals
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      # Sync with https://github.com/K3V1991/Disable-Firefox-Telemetry-and-Data-Collection/blob/main/README.md
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.ping-centre.telemetry" = false;
      "datareporting.healthreport.service.enabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.sessions.current.clean" = true;
      "devtools.onboarding.telemetry.logged" = false;
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.hybridContent.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.prompted" = 2;
      "toolkit.telemetry.rejected" = true;
      "toolkit.telemetry.reportingpolicy.firstRun" = false;
      "toolkit.telemetry.server" = "";
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.unifiedIsOptIn" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      # Extra Privacy
      "identity.fxaccounts.enabled" = false;
      "privacy.donottrackheader.enabled" = true;
      "ui.prefersReducedMotion" = 1;
      "extensions.pocket.enabled" = false;
      "signon.autofillForms" = false;
      "services.sync.engine.passwords" = false;
      "privacy.trackingprotection.enabled" = true;
      # Audio
      "media.getusermedia.aec_enabled" = false;
      "media.getusermedia.agc_enabled" = false;
      "media.getusermedia.noise_enabled" = false;
      "media.getusermedia.hpf_enabled" = false;
    };
  };

  # Fucking sudo man
  users.users.egoist = {
    shell = pkgs.unstable.fish;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
      "docker"
    ];
    packages = with pkgs; [
      unstable.blender-hip
      bfs
      brave
      emacs29
      # TODO: transform factorio into (callPackage ../pkgs/factorio.nix) so that we can easily use api key
      # TODO: Make a custom factorio derivation so we don't have to deal with nixpkgs being outdated.
      # TODO: Use agenix for api key
      # TODO: Should i even bother or just use steam's version?
      # unstable.factorio
      fzf
      gpgme
      heroic
      matcha
      irssi
      krita
      libnotify
      mpc_cli
      mpv
      ncmpc
      neomutt
      obs-studio
      unstable.qbittorrent
      unstable.jujutsu
      unstable.zellij
      unzip
      urlscan
      w3m
      xdg-utils
      mullvad-browser
    ];
  };

  programs.sway = {
    enable = true;
    package = pkgs.sway;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      btop
      adwaita-icon-theme
      grim
      jq
      mako
      mpd
      unstable.mpd-discord-rpc
      vesktop
      polkit_gnome
      screen
      slurp
      swaybg
      swayidle
      swayimg
      swaylock
      sysstat
      egl-wayland
      unstable.foot
      unstable.imhex
      wf-recorder
      wget
      wl-clipboard
      bemenu
      yambar
    ];
    extraSessionCommands = "";
  };
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  services.dbus.enable = true;
  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-kde ];
    };
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };

  environment.sessionVariables = rec {
    STEAM_FORCE_DESKTOPUI_SCALING = "2.0";
    EDITOR = "hx";
    ## mozilla
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    ## libreoffice
    SAL_USE_VCLPLUGIN = "gtk3";
    ## qt
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    ## sdl No longer needed (Will cause steam to fail)
    # SDL_VIDEODRIVER = "wayland";
    ## java is bad
    _JAVA_AWT_WM_NONREPARENTING = "1";
    ## xdg session
    # XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
    BEMENU_BACKEND = "wayland";
    BEMENU_SCALE = "2.5";
    QT_SCALE_FACTOR = "1.5";
    GDK_DPI_SCALE = "1.5";
    BEMENU_OPTS = "-W 0.3 -c --no-overlap -p '' ";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "IBMPlexMono"
        "UbuntuMono"
        "Ubuntu"
        "VictorMono"
      ];
    })
    noto-fonts
    twitter-color-emoji
    noto-fonts-cjk-sans
    font-awesome
  ];

  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Twitter Color Emoji" ];
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.gamemode.enable = true;

  # system wide installed packages:
  environment.systemPackages = with pkgs; [
    agenix
    # pinentry-qt
    attic-client
    # Android Device Support (Helpful for mount)
    android-udev-rules
    git-crypt
    direnv
    nix-direnv
    sshfs
    virt-manager
    virtiofsd
    clinfo
    # file chooser image preview
    libsForQt5.qt5.qtimageformats
    libsForQt5.kio-extras
  ];

  # yubikey to enable ssh key

  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.unstable.pinentry-bemenu;
    enableSSHSupport = true;
  };

  # For VSCode (Disabled now because VSCode is being such a bitch)
  services.gnome.gnome-keyring.enable = true;

  # enable libvirtd
  virtualisation.libvirtd.enable = true;
  # virtualisation.docker.enable = true;
  programs.dconf.enable = true;

  # programs.mtr.enable = true;

  # Open ports in the firewall.

  #  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.interfaces."virbr1".allowedTCPPorts = [ 42069 ];
  networking.firewall.interfaces."tun0".allowedTCPPorts = [ 42069 ];

  # In case I decide I need to bride my adapter for VMs (bad idea currently)
  # networking = {
  #   useDHCP = false;
  #   bridges = { br0 = { interfaces = [ "enp4s0" ]; }; };
  #   interfaces = { br0 = { useDHCP = true; }; };
  # };

  networking.firewall.enable = true;

  # NOTE: Using nftables seem to interfere with the automatic config that dnsmasq makes for virt-manager
  #       Thus, I am disabling it for now until it gets absorbed into Nix's firewall
  networking.nftables.enable = false;

  #  # VPN Config Currently Router Level but it's here juuust in case.
  #
  #  networking.wg-quick.interfaces = {
  #    wg0 = {
  #      address = [ "172.30.77.2/32" ];
  #      dns = [ "172.16.0.1" ];
  #      privateKeyFile = "/home/egoist/.wireguard/peer_A.key";
  #
  #      peers = [
  #        {
  #          publicKey = "LvWf548mFddi8PTrIGL6uD1/l85LU8z0Rc8tpvw2Vls=";
  #          allowedIPs = [ "0.0.0.0/0" ];
  #          endpoint = "96.44.189.197:2049";
  #          persistentKeepalive = 25;
  #        }
  #      ];
  #    };
  #  };

  # services.openvpn.servers = {
  #   htb = {
  #     config = "config /home/egoist/Downloads/lab_xEgoist.ovpn ";
  #     autoStart = false;
  #   };
  # };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
