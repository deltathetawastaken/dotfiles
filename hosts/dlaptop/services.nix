{ pkgs, lib, inputs, nur, config, ... }:
{
  # users.users.delta.packages = [
  #   (pkgs.writeScriptBin "warp-cli" "${pkgs.cloudflare-warp}/bin/warp-cli $@")
  # ];

  # systemd.services.cloudflare-warp = {
  #   enable = true;
  #   description = "cloudflare warp service";
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Restart = "on-failure";
  #     RestartSec = "15";
  #   };
  #   script = "${pkgs.cloudflare-warp}/bin/warp-svc";

  #   postStart = ''
  #     while true; do
  #       set -e
  #       status=$(${pkgs.cloudflare-warp}/bin/warp-cli status || true)
  #       set +e
  #       if [[ "$status" != *"Unable to connect to CloudflareWARP daemon"* ]]; then
  #         ${pkgs.cloudflare-warp}/bin/warp-cli set-custom-endpoint 162.159.193.1:2408
  #         exit 0
  #       fi
  #       sleep 15
  #     done
  #   '';
  # };

  users.groups.cloudflared = { };
  users.users.cloudflared = {
    group = "cloudflared";
    isSystemUser = true;
  };

  services.cloudflared.enable = true;
  services.cloudflared.tunnels = {
    "dlaptop" = {
      default = "http_status:404";
      credentialsFile = "/run/secrets/cloudflared";
    };
  };

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [];
  services.tailscale = {
    enable = true;
    extraUpFlags = "--accept-dns=false";
  };
  services.syncthing.enable = true;
  #services.blueman.enable = true;
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
  services.udev.extraRules = ''
      # Suspend the system when battery level drops to 6% or lower
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-6]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"

      # # lock when yubi removed
      # ACTION=="remove",\
      #  ENV{ID_BUS}=="usb",\
      #  ENV{ID_MODEL_ID}=="0407",\
      #  ENV{ID_VENDOR_ID}=="1050",\
      #  ENV{ID_VENDOR}=="Yubico",\
      #  RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';
  
  systemd.services.cloudflared-tunnel-dlaptop.serviceConfig.Restart = lib.mkForce "on-failure";
  systemd.services.cloudflared-tunnel-dlaptop.serviceConfig.RestartSec = lib.mkForce 60;
  systemd.services.cloudflared-tunnel-dlaptop.wantedBy = lib.mkForce [];

  systemd.tmpfiles.rules = [
    "d /media/torrents 0775 qbit users"
  ];

  users.users.qbit = {
    group = "qbit";
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/qbit";
  };

  users.groups.qbit = {
    gid = 10000;
  };

  system.activationScripts."qbitnoxwebui" = ''
    if [ ! -d "/var/lib/qbit" ]; then
      mkdir -p /var/lib/qbit
      chown -R qbit:qbit /var/lib/qbit
    fi

    if [ ! -d "/var/lib/qbit/qbittorrent-webui-cjratliff.com" ]; then
      ${pkgs.git}/bin/git clone https://github.com/Carve/qbittorrent-webui-cjratliff.com /var/lib/qbit/qbittorrent-webui-cjratliff.com
      chown -R qbit:qbit /var/lib/qbit
    fi
  '';

  systemd.services.qbitnox = {
    enable = true;
    after = [ "novpn.service" "network-online.target" ];
    wants = [ "novpn.service" "network-online.target" "dnscrypt-proxy2.service" ];
    bindsTo = [ "novpn.service" ];

    serviceConfig = {
      Restart = "always";
      RuntimeMaxSec = 86400;
      User = "qbit";
      Group = "qbit";
      NetworkNamespacePath = "/run/netns/novpn";
      PrivateTmp = false;
      PrivateNetwork = false;
      RemoveIPC = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectHome = "yes";
      ProtectProc = "invisible";
      ProcSubset = "pid";
      ProtectSystem = "full";
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
      CapabilityBoundingSet = "";
      SystemCallFilter = [ "@system-service" ];
    };

    # script = "${config.nur.repos.xddxdd.qbittorrent-enhanced-edition-nox}/bin/qbittorrent-nox";
    script = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
  };

  systemd.services.novpn.wants = [ "qbitnox.service" ];


}