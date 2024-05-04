{ config, lib, pkgs, inputs, stable, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  programs.hyprland.enable = true;
  users.users.delta.packages = with pkgs; [
   swww stable.waybar stable.swaynotificationcenter cliphist fzf hyprshot slurp grim swaylock hypridle libnotify brightnessctl
  ];
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

  home-manager.users.delta = {
    home.file.".config/hypr/colors".text = ''
      $background = rgba(1d192bee)
      $foreground = rgba(c3dde7ee)

      $color0 = rgba(1d192bee)
      $color1 = rgba(465EA7ee)
      $color2 = rgba(5A89B6ee)
      $color3 = rgba(6296CAee)
      $color4 = rgba(73B3D4ee)
      $color5 = rgba(7BC7DDee)
      $color6 = rgba(9CB4E3ee)
      $color7 = rgba(c3dde7ee)
      $color8 = rgba(889aa1ee)
      $color9 = rgba(465EA7ee)
      $color10 = rgba(5A89B6ee)
      $color11 = rgba(6296CAee)
      $color12 = rgba(73B3D4ee)
      $color13 = rgba(7BC7DDee)
      $color14 = rgba(9CB4E3ee)
      $color15 = rgba(c3dde7ee)
    '';
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      extraConfig = builtins.readFile ./hyprland.conf;
    };
  };
}