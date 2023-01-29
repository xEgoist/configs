# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  unstable = import <unstable> {};
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "Egoist"; # Define your hostname.

  networking.nameservers = [ "45.90.28.69" "45.90.30.69" ];
  networking.networkmanager.dns = "none";
  networking.dhcpcd.extraConfig = "nohook resolv.conf";
  services.resolved.enable = false;
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  time.timeZone = "US/Central";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  #sound.enable = true;
  # hardware.pulseaudio.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    #pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.pipewire = {
    config.pipewire = {
      "context.properties" = {
        "link.max-buffers" = 16;
        "log.level" = 2;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
       # "default.clock.quantum" = 50000;
       # "default.clock.min-quantum" = 50000;
       # "default.clock.max-quantum" = 50000;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
#      "context.modules" = [
#        {
#          name = "libpipewire-module-rtkit";
#          args = {
#            "nice.level" = -15;
#            "rt.prio" = 88;
#            "rt.time.soft" = 200000;
#            "rt.time.hard" = 200000;
#          };
#          flags = [ "ifexists" "nofail" ];
#        }
#        { name = "libpipewire-module-protocol-native"; }
#        { name = "libpipewire-module-profiler"; }
#        { name = "libpipewire-module-metadata"; }
#        { name = "libpipewire-module-spa-device-factory"; }
#        { name = "libpipewire-module-spa-node-factory"; }
#        { name = "libpipewire-module-client-node"; }
#        { name = "libpipewire-module-client-device"; }
#        {
#          name = "libpipewire-module-portal";
#          flags = [ "ifexists" "nofail" ];
#        }
#        {
#          name = "libpipewire-module-access";
#          args = { };
#        }
#        { name = "libpipewire-module-adapter"; }
#        { name = "libpipewire-module-link-factory"; }
#        { name = "libpipewire-module-session-manager"; }
#      ];
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

  environment.variables.EDITOR = "vim";
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
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      fzf
      git
      irssi
      librewolf
      mpc_cli
      nomacs
      obs-studio
      qbittorrent
      thunderbird
      udisks2
      unzip
      vim
      vimpc
      vlc
      wireguard-tools
      xdg-utils
      unstable.brave
    ];
  };
  # Enable Fish
  #programs.fish.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      #arc-theme
      #brightnessctl
      #solarc-gtk-theme
      #zafiro-icons
      acpi
      alacritty
      dex
      egl-wayland
      foot
      grim
      gtk-engine-murrine
      gtk-layer-shell
      htop
      jq
      mako
      networkmanagerapplet
      oksh
      phinger-cursors
      polkit_gnome
      slurp
      sway-contrib.grimshot
      swaybg
      swayidle
      swayimg
      swaylock
      sysstat
      unstable.waybar
      wayland-protocols
      wf-recorder
      wget
      wl-clipboard
      wofi
      xdg-desktop-portal-wlr
      xed
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
    ## libreoffice
    SAL_USE_VCLPLUGIN = "gtk3";
    ## qt
    QT_QPA_PLATFORM = "wayland-egl";
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
    XDG_CURRENT_DESKTOP = "sway";
  };

  fonts.fonts = with pkgs;
    [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "DroidSansMono"
          "IBMPlexMono"
          "UbuntuMono"
          "VictorMono"
        ];
      })
	  noto-fonts
	  noto-fonts-cjk
	  noto-fonts-emoji
    ];

  programs.waybar.enable = true;

  qt5.platformTheme = "qt5ct";
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };
  # system wide installed packages:
  environment.systemPackages = with pkgs; [ virt-manager ];



  # enable libvirtd
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;


  #MPD
  services.mpd.user = "egoist";
  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/1000"; 
  };
  services.mpd = {
  enable = true;
  musicDirectory = "/home/egoist/Music";
  extraConfig = ''
    auto_update "yes"
	audio_output {
	  type "pipewire"
	  name "My PipeWire Output"
	}
  '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  #networking.firewall.enable = false;

  # VPN Config

#  networking.wg-quick.interfaces = {
#    wg0 = {
#      address = [ "172.25.12.7/32" ];
#      dns = [ "172.16.0.1" ];
#      privateKeyFile = "/home/egoist/wireguard-keys/private";
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

