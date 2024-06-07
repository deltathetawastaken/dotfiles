{ lib, pkgs, inputs, self, homeSettings, ... }:

{
  imports = [ 
    ./hardware.nix
    "${self}/pkgs/gnome.nix"
    "${self}/pkgs/apps.nix"
    "${self}/pkgs/work.nix"
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

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
  };

  networking = {
    hostName = "huanan";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;
  system.stateVersion = "23.11"; # Did you read the comment?
}
