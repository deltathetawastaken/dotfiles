{ lib, pkgs, self, ... }:

{
  imports = [
    "${self}/apps/gnome.nix"
    "${self}/apps/hyprland"
  ];

  environment.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland";
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "16";
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
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = [ pkgs.xterm ];
  };
}