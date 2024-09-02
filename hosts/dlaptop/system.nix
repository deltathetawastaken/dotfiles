# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, inputs, self, homeSettings, config, stable, ... }:

{
  imports = [
    ./hardware.nix
    ./services.nix
    ./xorg.nix
    
    "${self}/pkgs/apps.nix"
    # "${self}/pkgs/nur.nix"
    "${self}/pkgs/socks.nix"
    "${self}/pkgs/scripts.nix"
    "${self}/pkgs/work.nix"
    "${self}/pkgs/dns.nix"

    inputs.secrets.nixosModules.dlaptop
    inputs.home-manager.nixosModules.home-manager homeSettings
    inputs.chaotic.nixosModules.default
  ];


  services.blueman.enable = true;

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LANGUAGE = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  documentation.man.enable = false;
  documentation.nixos.enable = false;


  # networking.timeServers = "time.cloudflare.com";
  services.chrony = {
    enable = true;
    servers = [
      "time.cloudflare.com"
      # "server 0.pool.ntp.org"
      # "server 1.pool.ntp.org"
      # "server 2.pool.ntp.org"
      # "server 3.pool.ntp.org"
      # "pool.ntp.org"
    ];
    serverOption = "iburst";
    enableNTS = true;
#    extraConfig = ''
#      minpoll 6
#      maxpoll 14
#    '';
  };


  networking = {
    hostName = "dlaptop";
    # nameservers = [ "1.1.1.1" ];
    nameservers = [ "127.0.0.1" ];
    networkmanager.dns = lib.mkForce "none"; 
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

  systemd.services.network-addresses-wlp1s0.wantedBy = lib.mkForce [];

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

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";



      #Optional helps save long term battery health
      #START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      #STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

    };
  };

  services.ananicy = {
    enable = true;
    package = stable.ananicy-cpp;
    rulesProvider = pkgs.ananicy-cpp-rules;
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


  sound.enable = true;
  hardware.pulseaudio.enable = false;
 
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
     oci-containers.containers = {
      cloudflare-warp = {
        # image = "caomingjun/warp --sysctl net.ipv6.conf.all.disable_ipv6=0 --sysctl net.ipv4.conf.all.src_valid_mark=1 --cap-add NET_ADMIN,mknod --device /dev/net/tun --security-opt=\"label=disable\" --network ns:/var/run/netns/novpn";
        image = "caomingjun/warp --sysctl net.ipv6.conf.all.disable_ipv6=0 --sysctl net.ipv4.conf.all.src_valid_mark=1 --cap-add NET_ADMIN,mknod --security-opt=\"label=disable\" --network ns:/var/run/netns/novpn";
        ports = [
          "1080:1080"
          "1081:1081"
        ];
        environment = {
          # GOST_ARGS =  " -L=socks5://:1081 -F=socks5://0.0.0.0:1082 & warp-cli mode proxy & warp-cli proxy port 1082";
          GOST_ARGS =  " -L=socks5://:1080";
          BETA_FIX_HOST_CONNECTIVITY="1";
        };
        volumes = [
          "warp:/var/lib/cloudflare-warp"
        ];
        environment = {
          WARP_SLEEP = "2";
        };
        extraOptions = [ "--privileged" ];
      }; # do sudo rm /dev/net/tun; sudo modprobe tun before running contaner if it doesnt work
    };
    spiceUSBRedirection.enable = true;
    libvirtd.enable = true;
    waydroid.enable = true;
  };
  systemd.services.waydroid-container.wantedBy = lib.mkForce [];

  environment.systemPackages = with pkgs; [
    config.nur.repos.ataraxiasjel.waydroid-script
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

    # rocmPackages.rocm-smi #gpu support in btop
  ];
  
    environment.etc."htoprc".text = lib.mkForce ''
    config_reader_min_version=3
    fields=0 48 46 47 49 1
    hide_kernel_threads=1
    hide_userland_threads=1
    hide_running_in_container=0
    shadow_other_users=0
    show_thread_names=0
    show_program_path=0
    highlight_base_name=1
    highlight_deleted_exe=1
    shadow_distribution_path_prefix=0
    highlight_megabytes=1
    highlight_threads=1
    highlight_changes=0
    highlight_changes_delay_secs=5
    find_comm_in_cmdline=1
    strip_exe_from_cmdline=1
    show_merged_command=0
    header_margin=1
    screen_tabs=1
    detailed_cpu_time=0
    cpu_count_from_one=0
    show_cpu_usage=1
    show_cpu_frequency=1
    show_cpu_temperature=1
    degree_fahrenheit=0
    update_process_names=0
    account_guest_in_cpu_meter=0
    color_scheme=6
    enable_mouse=1
    delay=15
    hide_function_bar=1
    header_layout=two_50_50
    column_meters_0=LeftCPUs Memory Swap
    column_meter_modes_0=1 1 1
    column_meters_1=RightCPUs Tasks LoadAverage Uptime
    column_meter_modes_1=1 2 2 2
    tree_view=0
    sort_key=46
    tree_sort_key=0
    sort_direction=-1
    tree_sort_direction=1
    tree_view_always_by_pid=0
    all_branches_collapsed=0
    screen:Main=PID USER NICE PERCENT_CPU PERCENT_MEM TIME Command
    .sort_key=PERCENT_CPU
    .tree_sort_key=PID
    .tree_view_always_by_pid=0
    .tree_view=0
    .sort_direction=-1
    .tree_sort_direction=1
    .all_branches_collapsed=0
    screen:I/O=PID USER IO_PRIORITY IO_RATE IO_READ_RATE IO_WRITE_RATE PERCENT_SWAP_DELAY PERCENT_IO_DELAY Command
    .sort_key=PID
    .tree_sort_key=PID
    .tree_view_always_by_pid=0
    .tree_view=0
    .sort_direction=1
    .tree_sort_direction=1
    .all_branches_collapsed=0
  '';

  system.stateVersion = "23.11"; # Don't forget the comment
}