# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, inputs, self, homeSettings, ... }:

{
  imports = [
    ./hardware.nix
    ./services.nix
    ./xorg.nix
    "${self}/pkgs/apps.nix"
    "${self}/pkgs/socks.nix"
    "${self}/pkgs/scripts.nix"
    "${self}/pkgs/work.nix"
    inputs.secrets.nixosModules.dlaptop
    inputs.home-manager.nixosModules.home-manager homeSettings
  ];

  services.blueman.enable = true;

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LANGUAGE = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  networking = {
    hostName = "dlaptop";
    nameservers = [ "1.1.1.1" ];
    #nameservers = [ "100.92.15.128" "fd7a:115c:a1e0::b21c:f80" ];
    networkmanager.dns = "none"; 
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    interfaces.wlp1s0.proxyARP = true;
    iproute2.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        # qbittorrent
        4780 
        # audiorelay
        59100
        # localsend
        53317
        #syncthing
        22000
      ];
      allowedUDPPorts = [
        # audiorelay
        59100
        59200
        # localsend
        53317
        #syncthing
        22000
        21027
      ];
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ]; # kde connect
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
      checkReversePath = "loose";
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  
  security = {
    sudo.wheelNeedsPassword = false;
    pam.loginLimits = [{ #needed for swaylock
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }];
    pam.services.swaylock = { };
  };

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";

      CPU_SCALING_MAX_FREQ_ON_AC = 6600000;
      CPU_SCALING_MAX_FREQ_ON_BAT = 1600000;

      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      #Trubo boost control
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      #GPU
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
      RADEON_DPM_PERF_LEVEL_ON_AC= "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT= "low";


      RESTORE_DEVICE_STATE_ON_STARTUP = 1;
      DEVICES_TO_ENABLE_ON_STARTUP = "bluetooth wifi";

      NMI_WATCHDOG = 0;


      #Optional helps save long term battery health
      #START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      #STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

    };
  };

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    wireplumber.configPackages = [
	    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
	    	bluez_monitor.properties = {
	    		["bluez5.enable-sbc-xq"] = true,
	    		["bluez5.enable-msbc"] = true,
	    		["bluez5.enable-hw-volume"] = true,
	    		["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
	    	}
	    '')
    ];
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
      KernelExperimental = true;
    };
  };
  # hardware.enableAllFirmware = true;


  sound.enable = true;
  hardware.pulseaudio.enable = false;
 
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    spiceUSBRedirection.enable = true;
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    multipath-tools #ZFS in LUKS mount

    openvpn
    any-nix-shell
    comma
    
    #work scripts
    openconnect
    oath-toolkit
    expect

    # Thunar stuff
    ffmpegthumbnailer
    webp-pixbuf-loader
    freetype
    poppler
    f3d
    nufraw-thumbnailer

    android-tools
    tor-browser
    #inputs.anyrun.packages.${pkgs.system}.anyrun
    sops
    yubikey-manager-qt
    yubico-piv-tool
    yubioath-flutter
    yubikey-personalization
    yubikey-personalization-gui
    age-plugin-yubikey
    age
    rage
    lua5_4
    nodePackages_latest.nodejs

    rocmPackages.rocm-smi #gpu support in btop
  ];
  
  system.stateVersion = "23.11"; # Don't forget the comment
}