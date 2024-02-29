# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, unstable, config, pkgs, ... }:

{
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
    #pam.services.swaylock = { };
    rtkit.enable = true;
  };

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
  services.xserver.videoDrivers = ["nvidia"]; 
 
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "huanan";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.wayland = false;

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.printing.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
    curl
    inputs.telegram-desktop-patched-unstable.packages.${pkgs.system}.default
  ];

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

  services.openssh.enable = true;
  networking.firewall.enable = false;
  system.stateVersion = "23.11"; # Did you read the comment?
}