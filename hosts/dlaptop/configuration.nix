# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, stable, unstable, config, pkgs, age, lib, ... }:

{
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    #LC_TIME = "ru_RU.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # age.rekey = {
  #   hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGL2UD0frl9F2OPBiPlSQqxDsuACbAVgwH24F0KT14L delta@dlaptop";
  #   #masterIdentities = [ "/home/delta/.ssh/id_ed25519" ];
  #   masterIdentities = [ "/home/delta/.secrets/key.txt" ];
  #   storageMode = "local";
  #   localStorageDir = ../../secrets/rekeyed/${config.networking.hostName};
  # };

  sops = {
    defaultSopsFile = ../../secrets/example.yaml;
    #defaultSopsFile = ../../.sops.yaml;
    #age.sshKeyPaths = [ "/home/delta/.ssh/id_ed25519" ];
    age.keyFile = "/home/delta/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";

    secrets.example-key = {};
    secrets."myservice/my_subdir/my_secret" = {};
  };



  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };

  nixpkgs.overlays = [
    (final: prev: {
      gnome = prev.gnome.overrideScope' (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs (old: {
          src = pkgs.fetchgit {
            url = "https://gitlab.gnome.org/vanvugt/mutter.git";
            # GNOME 45: triple-buffering-v4-45
            rev = "0b896518b2028d9c4d6ea44806d093fd33793689";
            sha256 = "sha256-mzNy5GPlB2qkI2KEAErJQzO//uo8yO0kPQUwvGDwR4w=";
          };
        });
      });
    })
  ];

  environment.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland";
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
    NIXOS_OZONE_WL = "1";
  };

  #services.dnscrypt-proxy2 = {
  #  enable = true;
  #  settings = {
  #    ipv6_servers = true;
  #    require_dnssec = true;
  #    server_names = [ "cloudflare" ];
  #  };
  #};

  users.groups.no-net = {};
  #services.connman.wifi.backend = "iwd";
  networking = {
    hostName = "dlaptop";
    nameservers = [ "100.92.15.128" "fd7a:115c:a1e0::b21c:f80" ];
    networkmanager.dns = "none"; 
    networkmanager.enable = true;
    #wireless.iwd.enable = true;
    #networkmanager.wifi.backend = "iwd";
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
      extraCommands = ''
        iptables -A OUTPUT -m owner --gid-owner no-net -j REJECT
      '';
    };
  };

  services.cloudflared.enable = false;
  services.cloudflared.tunnels = {
    "dlaptop" = {
      default = "http_status:404";
      credentialsFile = "/run/agenix/cloudflared";
    };
  };
  
  systemd.services.cloudflared-tunnel-dlaptop.serviceConfig.Restart = lib.mkForce "on-failure";
  systemd.services.cloudflared-tunnel-dlaptop.serviceConfig.RestartSec = lib.mkForce 60;

  programs.captive-browser = {
    browser = ''firejail --ignore="include whitelist-run-common.inc" --private --profile=chromium ${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/env XDG_CONFIG_HOME="$PREV_CONFIG_HOME" ${pkgs.chromium}/bin/chromium --user-data-dir=''${XDG_DATA_HOME:-$HOME/.local/share}/chromium-captive --proxy-server="socks5://$PROXY" --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost" --no-first-run --new-window --incognito -no-default-browser-check http://cache.nixos.org/' '';
    interface = "wlp1s0";
    enable = true;
  };
  
  security = {
    sudo.wheelNeedsPassword = false;
    wrappers = {
      firejail = { 
        source = "${pkgs.firejail.out}/bin/firejail"; 
      };
    };
    pam.loginLimits = [{
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }];
    pam.services.swaylock = { };
    rtkit.enable = true;
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

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
    displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = false;
        user = "delta";
      };
    };
    desktopManager.gnome.enable = true;
    layout = "us";
    xkbVariant = "";
    excludePackages = [ pkgs.xterm ];
  };

  services.gnome = {
    gnome-browser-connector.enable = false;
    gnome-initial-setup.enable = false;
    gnome-online-accounts.enable = false;
  };

  services.flatpak.enable = true;
  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  sound = {
    enable = true;
    extraConfig = "\n";
  };
  hardware.pulseaudio.enable = false;

  services.tailscale.enable = true;
  services.syncthing.enable = true;
  services.blueman.enable = true;
  services.tumbler.enable = true;
  services.gvfs.enable = true;
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon  pkgs.android-udev-rules ];

  programs.thunar.enable = true;
  programs.firejail.enable = true;
  programs.hyprland.enable = true;
  programs.xfconf.enable = true;
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];

  environment = {
    gnome.excludePackages = [
      #pkgs.gnome-connections
      #pkgs.gnome-console
      pkgs.gnome-text-editor
      pkgs.gnome-tour
      #pkgs.gnome.adwaita-icon-theme
      pkgs.gnome.epiphany # browser
      #pkgs.gnome.evince # pdf + office files
      #pkgs.gnome.file-roller #archive explorer
      pkgs.gnome.geary
      pkgs.gnome.gnome-backgrounds
      pkgs.gnome.gnome-calendar
      pkgs.gnome.gnome-characters
      pkgs.gnome.gnome-clocks
      pkgs.gnome.gnome-contacts
      pkgs.gnome.gnome-font-viewer
      pkgs.gnome.gnome-logs
      pkgs.gnome.gnome-maps
      pkgs.gnome.gnome-music
      #pkgs.gnome.gnome-themes-extra
      pkgs.gnome.gnome-weather
      #pkgs.gnome.nautilus
      pkgs.gnome.simple-scan
      pkgs.gnome.sushi
      pkgs.gnome.totem
      pkgs.gnome.yelp
      pkgs.orca
    ];
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    spiceUSBRedirection.enable = true;
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.activate-window-by-title
    gnomeExtensions.unite
    gnomeExtensions.tailscale-qs
    gnomeExtensions.gsconnect
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.tiling-assistant
    #gnomeExtensions.wintile-windows-10-window-tiling-for-gnome
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.syncthing-indicator
    gnome.gnome-tweaks
    
    mojave-gtk-theme
    adw-gtk3
    any-nix-shell
    openconnect
    oath-toolkit
    expect
    ffmpegthumbnailer
    webp-pixbuf-loader
    freetype
    poppler
    f3d
    nufraw-thumbnailer
    android-tools
    #firefox_nightly
    #inputs.anyrun.packages.${pkgs.system}.anyrun
    inputs.telegram-desktop-patched-unstable.packages.${pkgs.system}.default
    inputs.agenix.packages.x86_64-linux.default
    # inputs.ragenix.packages.x86_64-linux.default
    sops
    ];

  users.users.socks = {
    group = "socks";
    isSystemUser = true;
  };
  users.groups.socks = { };

  systemd.services.singbox-aus = {
    enable = true;
    description = "avoid censorship";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "15";
      User = "socks";
      Group = "socks";
    };
    script = "sing-box run -c /run/agenix/singbox-aus";
    path = with unstable; [
      shadowsocks-libev
      shadowsocks-v2ray-plugin
      sing-box
    ];
  };

  #config.services.openssh.hostKeys = [ "/home/delta/.ssh/id_ed25519" ];

  systemd.services.NetworkManager-wait-online.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
