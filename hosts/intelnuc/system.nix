{ config, pkgs, inputs, self, ... }: {
  imports =
    [ ./hardware.nix ./nginx-work.nix inputs.secrets.nixosModules.intelnuc ];

  system.autoUpgrade = {
    enable = true;
    flake = "github:deltathetawastaken/dotfiles";
    dates = "daily";
  };
  systemd.services.nixos-upgrade = { # 1 hour timeout, default is too low
    serviceConfig.TimeoutSec = 3600;
    serviceConfig.TimeoutStartUSec = 3600;
    serviceConfig.TimeoutStopUSec = 3600;
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.kernel.sysctl."net.core.rmem_max" = 2500000; # for quic

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.intelnuc = {
    isNormalUser = true;
    description = "intelnuc";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGL2UD0frl9F2OPBiPlSQqxDsuACbAVgwH24F0KT14L delta@dlaptop"
  ];

  programs.adb.enable = true;

  services.udev.packages = [ pkgs.android-udev-rules ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    zenith
    xorg.xauth
    docker
    docker-compose
    traefik
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
      Type = "simple";
    };
    script = "/home/delta/scripts/vpn-connect-WB";
    path = with pkgs; [ expect oath-toolkit openconnect ];
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
    database = { type = "sqlite3"; };
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
