{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.kernel.sysctl."net.core.rmem_max" = 2500000; #for quic

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.intelnuc = {
    isNormalUser = true;
    description = "intelnuc";
    extraGroups = [ "networkmanager" "wheel" "docker"];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    zenith
    pkgs.xorg.xauth
    docker docker-compose traefik
    lazydocker
  ];

  networking = {
    firewall.enable = false;
    hostName = "intelnuc";
    networkmanager.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.adguardhome.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  systemd.services.grafanavpn = {
    enable = true;
    description = "grafana vpn";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "15";
      Type="simple";
    };
    script = "/home/delta/scripts/vpn-connect-WB";
    path = with pkgs; [
      expect
      oath-toolkit
      openconnect
    ];
  };

  systemd.services.grafanaforward_43 = {
    enable = true;
    description = "grafana forward";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "15";
      Type="simple";
      DynamicUser=true;
      Exec="${pkgs.redir}/bin/redir -n :2000 123.123.123.123:3000";
    };
  };

  systemd.services.grafanaforward_44 = {
    enable = true;
    description = "grafana forward";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "15";
      Type="simple";
      DynamicUser=true;
      Exec="${pkgs.redir}/bin/redir -n :2001 123.123.123.123:3000";
    };
  };

  system.stateVersion = "22.11";
}
