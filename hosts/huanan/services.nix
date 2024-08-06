{ pkgs, lib, inputs, ... }:
{
  services.tailscale = {
    enable = true;
    extraUpFlags = "--accept-dns=false";
  };
  services.syncthing.enable = true;
  services.blueman.enable = true;
  services.tumbler.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  services.printing.enable = true;
  services.pcscd.enable = true;

  services.udev.packages = [ 
    pkgs.gnome.gnome-settings-daemon
    pkgs.android-udev-rules
    pkgs.yubikey-personalization
  ];

  users.groups.cloudflared = { };
  users.users.cloudflared = {
    group = "cloudflared";
    isSystemUser = true;
  };
}