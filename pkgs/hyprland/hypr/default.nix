{ config, lib, pkgs, inputs, stable, ... }:
# let
#   hyprshade = pkgs.hyprshade.overrideAttrs (oldAttrs: rec {
#     version = "4.0.0";
#     src = pkgs.fetchFromGitHub {
#       owner = "loqusion";
#       repo = "hyprshade";
#       rev = "refs/tags/${version}";
#       hash = "";
#     };
#   });
# in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.backupFileExtension = "backup-hm";

  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  users.users.delta.packages = with pkgs; [
    swww
    waybar
    swaynotificationcenter
    cliphist
    fzf
    hyprshot
    slurp
    grim
    swaylock
    hypridle
    libnotify
    brightnessctl
    pamixer
    # python3
    grimblast
    networkmanagerapplet
    hyprshade # hyprshade toggle blue-light-filter
    gammastep # gammastep -O 4500K
    hyprlock
    # wluma


  ];
  # environment.systemPackages = [
  #  inputs.hyprland-contrib.packages.${pkgs.system}.grimblast.override { license = licenses.gpl3; }
  #  inputs.hyprland-contrib.packages.${pkgs.system}.hdrop.override { license = licenses.gpl3; }
  # ];
  # xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

  home-manager.users.delta = {
    home.file.".config/hypr/colors".text = ''
      $background = rgba(1d192bee)
      $foreground = rgba(c3dde7ee)

      $color0 = rgba(1d192bee)
      $color1 = rgba(465EA7ee)  "https://github.com/zakk4223/hyprland-easymotion"

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
      # plugins = [
      #   "https://github.com/zakk4223/hyprland-easymotion"
      # ];
    };
    home.file.".config/hypr/env_var.conf".text = builtins.readFile ./env_var.conf;
    home.file.".config/hypr/media-binds.conf".text = builtins.readFile ./media-binds.conf;
    home.file.".config/hypr/hypridle.conf".text = builtins.readFile ./hypridle.conf;


  };
}
