{ lib, pkgs, self, ... }:

{
  imports = [
    "${self}/pkgs/gnome.nix"
    "${self}/pkgs/hyprland"
  ];

  environment.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = lib.mkDefault "wayland";
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_SIZE = "";
    EDITOR = "hx";
    BROWSER = "firefox";
    TERMINAL = "foot";
  };

  environment.variables = lib.mkForce {
    EDITOR = "hx";
    BROWSER = "firefox";
    TERMINAL = "foot";
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
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