{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.kernel.sysctl."net.core.rmem_max" = 2500000; #for quic

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  imports = [ 
    ./sops.nix
  ];

  users.users.intelnuc = {
    isNormalUser = true;
    description = "intelnuc";
    extraGroups = [ "networkmanager" "wheel" "docker"];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGL2UD0frl9F2OPBiPlSQqxDsuACbAVgwH24F0KT14L delta@dlaptop"
  ];

  programs.adb.enable = true;

  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    zenith
    pkgs.xorg.xauth
    docker docker-compose traefik
    lazydocker
    android-tools
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

  services.nginx.enable = true;
  services.nginx.virtualHosts."grafana_first" = {
    forceSSL = false;
    listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
    serverName = "graf1.local";
    locations."/".extraConfig = ''
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      include ${config.sops.templates."nginx-graf1.conf".path};
    '';
    locations."/api/live/ws".extraConfig = ''
      include ${config.sops.templates."nginx-graf1.conf".path};
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    '';
  };
  services.nginx.virtualHosts."grafana_second" = {
    forceSSL = false;
    listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
    serverName = "graf2.local";
    locations."/".extraConfig = ''
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      include ${config.sops.templates."nginx-graf2.conf".path};
    '';
    locations."/api/live/ws".extraConfig = ''
      include ${config.sops.templates."nginx-graf2.conf".path};
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    '';
  };
  services.nginx.virtualHosts."kibana" = {
    forceSSL = false;
    listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
    serverName = "kibana.local";
    locations."/".extraConfig = ''
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      include ${config.sops.templates."nginx-kibana.conf".path};
    '';
  };

  system.stateVersion = "22.11";
}
