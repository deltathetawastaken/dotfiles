{ lib, pkgs, inputs, self, homeSettings, ... }:

{
  imports = [ 
    ./hardware.nix
    ./services.nix
    ../dlaptop/xorg.nix
    "${self}/pkgs/apps.nix"
    "${self}/pkgs/socks.nix"
    "${self}/pkgs/scripts.nix"
    "${self}/pkgs/work.nix"
    inputs.secrets.nixosModules.dlaptop
    inputs.home-manager.nixosModules.home-manager homeSettings
  ];

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_GB.UTF-8";

  services.xserver = {
    enable = true;
    videoDrivers = [ "noveau" ];
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager.gnome.enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = [ pkgs.xterm ];
  };

  systemd.services.NetworkManager-wait-online.enable = false; #just makes boot time longer
  networking = {
    hostName = "huanan";
    nameservers = [ "192.168.3.53" ];
    networkmanager.dns = "none"; 
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    iproute2.enable = true;
    firewall = {
      enable = false;
    };
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

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  services.openssh.enable = true;
  system.stateVersion = "23.11";
}
