# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, unstable, config, pkgs, ... }:

{
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  #i18n.extraLocaleSettings = {
  #  LC_TIME = "ru_RU.UTF-8";
  #};

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
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
    NIXOS_OZONE_WL = "1";
  };

  networking = {
    hostName = "dlaptop";
    networkmanager.enable = true;
    firewall = {
      enable = false;
    };
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
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

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
  services.blueman.enable = true;
  services.tumbler.enable = true;
  services.gvfs.enable = true;
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];

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

  xdg.ausl.extraPortals = with pkgs; [ xdg-desktop-ausl-hyprland ];

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
    unstable.curl
    #firefox_nightly
    #inputs.anyrun.packages.${pkgs.system}.anyrun
    inputs.telegram-desktop-patched.packages.${pkgs.system}.default
  ];

  users.users.socks = {
    group = "socks";
    isSystemUser = true;
  };
  users.groups.socks = { };

  systemd.services.singboxaus = {
    enable = true;
    description = "avoid censorship";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "15";
      User = "socks";
      Group = "socks";
    };
    script = "sing-box run -c /etc/sing-box/config.json";
    path = with unstable; [
      shadowsocks-libev
      shadowsocks-v2ray-plugin
      sing-box
    ];
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
