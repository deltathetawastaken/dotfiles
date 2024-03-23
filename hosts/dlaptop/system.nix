# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, inputs, self, homeSettings, ... }:

{
  imports = [
    ./hardware.nix
    ./services.nix
    ./xorg.nix
    "${self}/apps/apps.nix"
    "${self}/apps/socks.nix"
    "${self}/apps/scripts.nix"
    "${self}/apps/work.nix"
    inputs.secrets.nixosModules.dlaptop
    inputs.home-manager.nixosModules.home-manager homeSettings
  ];

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_GB.UTF-8";

  networking = {
    hostName = "dlaptop";
    nameservers = [ "100.92.15.128" "fd7a:115c:a1e0::b21c:f80" ];
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

  programs.captive-browser = {
    browser = ''firejail --ignore="include whitelist-run-common.inc" --private --profile=chromium ${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/env XDG_CONFIG_HOME="$PREV_CONFIG_HOME" ${pkgs.chromium}/bin/chromium --user-data-dir=''${XDG_DATA_HOME:-$HOME/.local/share}/chromium-captive --proxy-server="socks5://$PROXY" --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost" --no-first-run --new-window --incognito -no-default-browser-check http://cache.nixos.org/' '';
    interface = "wlp1s0";
    enable = true;
  };
  
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
      CPU_BOOST_ON_BAT = 1;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 1;

      #Optional helps save long term battery health
      #START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      #STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

    };
  };

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
    openvpn
    any-nix-shell
    
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
    firefox
    tor-browser
    #inputs.anyrun.packages.${pkgs.system}.anyrun
    sops
    yubikey-manager-qt
    yubico-piv-tool
    yubioath-flutter
    yubikey-personalization
    yubikey-personalization-gui
    age-plugin-yubikey
    lua5_4
    nodejs_21
  ];

  programs.fish = {
    enable = true;
    
    shellAliases = {
      fru = "trans ru:en";
      fen = "trans en:ru";
      icat = "kitten icat";
    };
    shellInit = ''
      set -U __done_kitty_remote_control 1
      set -U __done_kitty_remote_control_password "kitty-notification-password-fish"
      set -U __done_notification_command 'notify-send --icon=kitty --app-name=kitty \$title \$argv[1] && '
    '';
  };
  
  system.stateVersion = "23.11"; # Don't forget the comment
}