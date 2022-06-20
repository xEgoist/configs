# Edit this configuration file to define what should be installed on
# you rsystem.	Help is available in the configuration.nix(5) man page
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
	networking.networkmanager.enable = true;	# Easiest to use and most distros use this by default.
  nixpkgs.config.allowUnfree = true;
	# Set your time zone.
	time.timeZone = "US/Central";
	boot.initrd.kernelModules = [ "amdgpu" ];

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Select internationalisation properties.
	# i18n.defaultLocale = "en_US.UTF-8";
	# console = {
	#		font = "Lat2-Terminus16";
	#		keyMap = "us";
	#		useXkbConfig = true; # use xkbOptions in tty.
	# };

	# Enable the X11 windowing system.
	#services.xserver.enable = true;

	# Enable NTFS Support
	boot.supportedFilesystems = [ "ntfs" ];
	
	# Configure keymap in X11
	# services.xserver.layout = "us";
	# services.xserver.xkbOptions = {
	#		"eurosign:e";
	#		"caps:escape" # map caps to escape.
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


	# OpenCL for AMD:
	hardware.opengl.extraPackages = with pkgs; [
		 rocm-opencl-icd
		 rocm-opencl-runtime
		 vaapiVdpau
		 libvdpau-va-gl
     SDL2
	];
	# Vulkan
	hardware.opengl.driSupport = true;
	# For 32 bit applications
	hardware.opengl.driSupport32Bit = true;


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
	security.doas.extraRules = [{
				users = [ "egoist" ];
				keepEnv = true;
        persist = true;
	}];
	environment.systemPackages = with pkgs; [ firefox-wayland ];

	# Define a user account. Don't forget to set a password with ‘passwd’.
	 users.users.egoist = {
		 shell = pkgs.fish;
		 isNormalUser = true;
		 extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
		 packages = with pkgs; [
				nomacs
				qbittorrent
				thunderbird
				vim
        irssi
				neovim
				vlc
				fzf
				unzip
				git
				wireguard-tools
				xdg-utils
		 ];
	 };

# networking.wg-quick.interfaces = {
#		wg0 = {
#			address = [ "" "" ];
#			dns = [ ""  ];
#			privateKeyFile = "/home/egoist/wireguard/privatekey";
#			
#			peers = [
#				{
#					publicKey = "";
#					allowedIPs = [ "0.0.0.0/0" "::/0" ];
#					endpoint = "";
#					persistentKeepalive = 25;
#				}
#			];
#		};
#	};




	


#networking.firewall = {
#		 allowedUDPPorts = [ 443 ]; # Clients and peers can use the same port, see listenport
#  };
#  # Enable WireGuard
#  networking.wireguard.interfaces = {
#		 # "wg0" is the network interface name. You can name the interface arbitrarily.
#		 wg0 = {
#			 # Determines the IP address and subnet of the client's end of the tunnel interface.
#			 ips = [ "172.20.217.191/32" "fd00:4956:504e:ffff::ac14:d9bf/128" ];
#			 listenPort = 443; # to match firewall allowedUDPPorts (without this wg uses random port numbers)
#			 # Path to the private key file.
#			 #
#			 # Note: The private key can also be included inline via the privateKey option,
#			 # but this makes the private key world-readable; thus, using privateKeyFile is
#			 # recommended.
#			 privateKeyFile = "/home/egoist/wireguard/privatekey";
#
#			 peers = [
#				 # For a client configuration, one peer entry for the server will suffice.
#
#				 {
#					 # Public key of the server (not a file path).
#					 publicKey = "om8hOGUcEvoOhHvJZoBHxNF4jxY/+Ml9Iy1WOSC/pFo=";
#
#					 # Forward all the traffic via VPN.
#					 allowedIPs = [ "0.0.0.0/0" ];
#					 # Or forward only particular subnets
#					 #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];
#
#					 # Set this to the server IP and port.
#					 endpoint = "us-tx2.wg.ivpn.net:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
#
#					 # Send keepalives every 25 seconds. Important to keep NAT tables alive.
#					 persistentKeepalive = 25;
#				 }
#			 ];
#		 };
#  };




# Enable SSHD.
# Note: The service is read-only once enabled.

#  services.openssh = {
#		 enable = true;
#  #	passwordAuthentication = false; # default true
#  #	permitRootLogin = "yes";
#  #	challengeResponseAuthentication = false;
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
	alacritty
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
		## qt
		QT_QPA_PLATFORM = "wayland-egl";
		QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
		## efl
		ECORE_EVAS_ENGINE = "wayland_egl";
		ELM_ENGINE = "wayland_egl";
		## sdl
		SDL_VIDEODRIVER = "wayland";
		## java is bad
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
	
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
	};

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#		enable = true;
	#		enableSSHSupport = true;
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

