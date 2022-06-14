# Edit this configuration file to define what should be installed on
# you rsystem.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Egoist"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
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
  #services.xserver.enable = true;

  # Enable NTFS Support
  boot.supportedFilesystems = [ "ntfs" ];
  
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
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;
	};

  services.pipewire = {
  config.pipewire = {
    "context.properties" = {
      "link.max-buffers" = 16;
      "log.level" = 2;
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 32;
      "core.daemon" = true;
      "core.name" = "pipewire-0";
    };
    "context.modules" = [
      {
        name = "libpipewire-module-rtkit";
        args = {
          "nice.level" = -15;
          "rt.prio" = 88;
          "rt.time.soft" = 200000;
          "rt.time.hard" = 200000;
        };
        flags = [ "ifexists" "nofail" ];
      }
      { name = "libpipewire-module-protocol-native"; }
      { name = "libpipewire-module-profiler"; }
      { name = "libpipewire-module-metadata"; }
      { name = "libpipewire-module-spa-device-factory"; }
      { name = "libpipewire-module-spa-node-factory"; }
      { name = "libpipewire-module-client-node"; }
      { name = "libpipewire-module-client-device"; }
      {
        name = "libpipewire-module-portal";
        flags = [ "ifexists" "nofail" ];
      }
      {
        name = "libpipewire-module-access";
        args = {};
      }
      { name = "libpipewire-module-adapter"; }
      { name = "libpipewire-module-link-factory"; }
      { name = "libpipewire-module-session-manager"; }
      ];
    };
  };




# hardware.pulseaudio.enable = true;

  # Defaults to Vim 
  environment.variables.EDITOR = "vim";  

  # Enable experimental features for Nix (Flake and command)
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
     };
   };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  

  # Fucking sudo man
  security.doas.enable = true;
  security.sudo.enable = false;
  # KeepEnv is cruical here, if you forget to do it, doas -s , add the nix env var and fix this 
  # then rebuild 
  security.doas.extraRules = [{
        users = [ "egoist" ];
        keepEnv = true;
  }];
  environment.systemPackages = with pkgs; [ firefox-wayland ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # Currently using fish, but I really hate how there is no implementation for exclusion.
  # oksh config seems to be fine but it crashed once and it doesn't have multiline support :( .  
   users.users.egoist = {
     shell = pkgs.fish;
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
        nomacs
	      qbittorrent
        thunderbird
        vim
	      neovim
        vlc
        unzip
        git
        wireguard-tools
        xdg-utils
     ];
   };

# networking.wg-quick.interfaces = {
#    wg0 = {
# # "IPV4" "IPV6
#      address = [ "" "" ];
#      dns = [ "" ];
#      privateKeyFile = "";
#      
#      peers = [
#        {
#          publicKey = "";
#          allowedIPs = [ "0.0.0.0/0" "::/0" ];
#          endpoint = "";
#          persistentKeepalive = 25;
#        }
#      ];
#    };
#  };




  


#networking.firewall = {
#    allowedUDPPorts = [ 443 ]; # Clients and peers can use the same port, see listenport
#  };



# Enable SSHD.
# Note: The service is read-only once enabled.

#  services.openssh = {
#    enable = true;
#  #  passwordAuthentication = false; # default true
#  #  permitRootLogin = "yes";
#  #  challengeResponseAuthentication = false;
#  };



  # Enable Fish
  programs.fish.enable = true;

  programs.sway = {
	enable = true;
	wrapperFeatures.gtk = true;
	extraPackages = with pkgs; [
	swaylock
	swayidle
	wl-clipboard
	wf-recorder
	mako
  oksh
	grim
  sway-contrib.grimshot
	slurp
	kitty
	wofi
	zafiro-icons
	pavucontrol
	waybar
	swaybg
	lxappearance
	gtk-engine-murrine
	acpi
	bluez
	networkmanagerapplet
	sysstat
	htop
	wayland-protocols
	egl-wayland
	polkit_gnome
  gtk-layer-shell
	xdg-desktop-portal-wlr
	brightnessctl
	pamixer
	dex
	jq
	xed
  arc-theme
  wget
  zafiro-icons
  solarc-gtk-theme
	foot
	];
	extraSessionCommands = ''
	'';
  };

  services.dbus.enable = true;
  xdg = {
  portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    gtkUsePortal = true;
  };
	};


  environment.sessionVariables = rec {

    ## mozilla
    MOZ_ENABLE_WAYLAND = "1";
    ## libreoffice
    SAL_USE_VCLPLUGIN = "gtk3";
    QT_QPA_PLATFORM = "wayland-egl";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    ECORE_EVAS_ENGINE = "wayland_egl";
    ELM_ENGINE = "wayland_egl";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    ## xdg session
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };


	fonts.fonts = with pkgs; [
  (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "IBMPlexMono" "UbuntuMono" "VictorMono"]; })
	];

  programs.waybar.enable = true;
  programs.qt5ct.enable = true;
  
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
  # networking.firewall.enable = false;

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
  system.stateVersion = "22.05"; # Did you read the comment?

}

