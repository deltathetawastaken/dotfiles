{ config, pkgs, inputs,... }:

{
  imports = [
    ./hardware.nix
    inputs.secrets.nixosModules.intelnuc
  ];

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
  services.nginx.virtualHosts."grafana" = {
    forceSSL = false;
    listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
    serverName = "graf1.local ${inputs.secrets.work.graf-url}";
    locations."/".extraConfig = ''
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_pass https://${inputs.secrets.work.graf-url};
    '';
    locations."/api/live/ws".extraConfig = ''
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_pass https://${inputs.secrets.work.graf-url};
    '';
  };

  services.nginx.virtualHosts."keycloak" = {
    forceSSL = false;
    listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
    serverName = "${inputs.secrets.work.keycloak}";
    locations."/".extraConfig = ''
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_pass https://${inputs.secrets.work.keycloak};
    '';
  };

  services.nginx.virtualHosts."kibana" = {
    forceSSL = false;
    listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
    serverName = "kibana.local ${inputs.secrets.work.kibana}";
    locations."/".extraConfig = ''
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_pass https://${inputs.secrets.work.kibana};
    '';
  };
  services.nginx.virtualHosts."zabbix" = {
    forceSSL = false;
    listen = [{port = 80;  addr="0.0.0.0"; ssl=false;}];
    serverName = "zabbix.local";
    serverAliases = [ "${inputs.secrets.work.zabbix-url}" ];
    locations."/".extraConfig = ''
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_pass https://${inputs.secrets.work.zabbix};
    '';
  };

  services.forgejo = {
    enable = true;
    settings = {
      service.DISABLE_REGISTRATION = true;
      server = {
        DOMAIN = inputs.secrets.hosts.intelnuc.forgejo.domain;
        DISABLE_SSH = true;
        HTTP_PORT = 3838;
        ROOT_URL = "https://${inputs.secrets.hosts.intelnuc.forgejo.domain}";
      };
    };
    database = {
      type = "sqlite3";
    };
  };

  services.cloudflared.enable = true;
  services.cloudflared.tunnels = {
    "intelnuc" = {
      default = "http_status:404";
      credentialsFile = "${config.sops.secrets.cloudflared.path}";
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = inputs.secrets.hosts.intelnuc.ntfy.url;
      listen-http = ":3333";
    };
  };

  system.stateVersion = "22.11";
}
