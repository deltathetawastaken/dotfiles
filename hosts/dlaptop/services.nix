{ pkgs, lib, ... }:
{
  users.users.delta.packages = [
    (pkgs.writeScriptBin "warp-cli" "${pkgs.cloudflare-warp}/bin/warp-cli $@")
  ];

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

  services.cloudflared.enable = false;
  services.cloudflared.tunnels = {
    "dlaptop" = {
      default = "http_status:404";
      credentialsFile = "/run/secrets/cloudflared";
    };
  };

  services.tailscale.enable = true;
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
  # services.udev.extraRules = ''
  #     ACTION=="remove",\
  #      ENV{ID_BUS}=="usb",\
  #      ENV{ID_MODEL_ID}=="0407",\
  #      ENV{ID_VENDOR_ID}=="1050",\
  #      ENV{ID_VENDOR}=="Yubico",\
  #      RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  # '';
  
  systemd.services.cloudflared-tunnel-dlaptop.serviceConfig.Restart = lib.mkForce "on-failure";
  systemd.services.cloudflared-tunnel-dlaptop.serviceConfig.RestartSec = lib.mkForce 60;
}