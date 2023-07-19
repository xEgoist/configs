# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let unstable = import <unstable> { config.allowUnfree = true; };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "Egoist"; # Define your hostname.

  #networking.nameservers = [ "10.0.1.1" ];
  networking.extraHosts = "";
  # We use dhcpcd here. no network manager BS.
  networking.dhcpcd.enable = true;
  #networking.dhcpcd.extraConfig = "nohook resolv.conf";
  services.resolved.enable = false;
  nixpkgs.config.allowUnfree = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Set your time zone.
  time.timeZone = "US/Central";


  # Enable Git and config it
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
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    # Pulse/Jack isn't really needed these days as many have adopted pipewire.
    # Firefox is currently not ideal for recording with only pipewire.
    # However, when disabling all the garbage audio 'enhancement' stuff, it works flawlessly.
    # I hate when recording software tries to "help" anyway. No time have i ever wanted AGC!.
    # https://wiki.archlinux.org/title/Firefox/Tweaks#Disable_WebRTC_audio_post_processing
    # Otherwise if nothing works, pulse may be enabled here.

    # pulse.enable = true;
    # jack.enable = true;
  };
  environment.etc =
    let json = pkgs.formats.json { };
    in {
      "pipewire/pipewire.conf.d/92-low-latency.conf".source =
        json.generate "92-low-latency.conf" {
          context.properties = {
            link.max-buffers = 16;
            default.clock.allowed-rates = [ 44100 48000 88200 96000 ];
            default.clock.quantum = 32;
            default.clock.min-quantum = 32;
            default.clock.max-quantum = 32;
          };
        };
    };

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  # Vulkan
  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;

  # Turn on nix flakes (TODO: Remove once it's no longer experimental)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  environment.pathsToLink = [ "/share/nix-direnv" ];

  environment.variables.EDITOR = "hx";

  nix.settings.auto-optimise-store = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  # Fucking sudo man
  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    users = [ "egoist" ];
    keepEnv = true;
    persist = true;
  }];
  users.users.egoist = {
    shell = unstable.fish;
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      unstable.brave
      unstable.librewolf
      fzf
      irssi
      mpc_cli
      mpv
      ncmpc
      nomacs
      obs-studio
      qbittorrent
      tealdeer
      unstable.thunderbird
      unstable.vscode
      unzip
      vim
      vlc
      xdg-utils
    ];
  };
  # Enable Fish
  # programs.fish.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      gnome.adwaita-icon-theme
      acpi
      unstable.imhex
      alacritty
      dex
      unstable.egl-wayland
      foot
      grim
      gtk-engine-murrine
      gtk-layer-shell
      htop
      jq
      mako
      polkit_gnome
      slurp
      sway-contrib.grimshot
      swaybg
      swayidle
      swayimg
      mpd
      swaylock
      sysstat
      yambar
      unstable.wayland-protocols
      wf-recorder
      wget
      wl-clipboard
      wofi
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
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };
  };

  environment.sessionVariables = rec {

    ## mozilla
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    ## libreoffice
    SAL_USE_VCLPLUGIN = "gtk3";
    ## qt
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    ## efl
    ECORE_EVAS_ENGINE = "wayland_egl";
    ELM_ENGINE = "wayland_egl";
    ## sdl No longer needed (Will cause steam to fail)
    #SDL_VIDEODRIVER = "wayland";
    ## java is bad
    _JAVA_AWT_WM_NONREPARENTING = "1";
    ## xdg session
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "sway";
    XDG_CURRENT_DESKTOP = "sway";
  };

  fonts.fonts = with pkgs; [
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
    noto-fonts-cjk
  ];

  fonts.fontconfig = { defaultFonts = { emoji = [ "Twitter Color Emoji" ]; }; };

  qt.platformTheme = "qt5ct";
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # system wide installed packages:
  environment.systemPackages = with pkgs; [
    pinentry-curses
    # Android Device Support (Helpful for mount)
    android-udev-rules
    direnv
    # Enable General Man Pages
    man-pages
    man-pages-posix
    nix-direnv
    nix-index
    unstable.helix
    unstable.lapce
    virt-manager
  ];

  # yubikey to enable ssh key

  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = true;
  };

  # For VSCode (Disabled now because VSCode is being such a bitch right)
  services.gnome.gnome-keyring.enable = true;

  # enable libvirtd
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  #MPD Currently user defined under .config and runs from sway. Running it system wide is a bit dificult

  #  services.mpd.user = "egoist";
  #  systemd.services.mpd.environment = {
  #    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
  #    XDG_RUNTIME_DIR = "/run/user/1000";
  #  };
  #  services.mpd = {
  #  enable = true;
  #  musicDirectory = "/home/egoist/Music";
  #  extraConfig = ''
  #    auto_update "yes"
  #	audio_output {
  #	  type "pipewire"
  #	  name "My PipeWire Output"
  #	}
  #  '';
  #  };

  # programs.mtr.enable = true;

  # Open ports in the firewall.

  #  networking.firewall.allowedTCPPorts = [ ];
  # networking.firewall.interfaces."virbr0".allowedTCPPorts = [
  #   8000
  # ];

  # In case I decide I need to bride my adapter for VMs (bad idea currently)
  # networking = {
  #   useDHCP = false;
  #   bridges = { br0 = { interfaces = [ "enp4s0" ]; }; };
  #   interfaces = { br0 = { useDHCP = true; }; };
  # };

  networking.firewall.enable = true;

  # NOTE: nftables might get absorbed into firewall later on.
  networking.nftables.enable = true;

  # networking.firewall.interfaces."br0".allowedTCPPorts = [ 8000 ];

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

