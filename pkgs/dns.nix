{ lib, ... }:
{
  networking.nameservers = lib.mkForce [ "127.0.0.1" ];

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
        do-ip6 = false;
        cache-max-ttl = 86400;
        cache-min-ttl = 1024;
        cache-max-negative-ttl = 86400;
        serve-expired = "yes";
        serve-expired-ttl = 86400;
        serve-expired-ttl-reset = "yes";
        prefetch = "yes";
        prefetch-key = "yes";
      };

      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "100.92.15.128"
            "192.168.150.2@53"
          ];
          forward-first = true;
        }
      ];

      remote-control = {
        control-enable = true;
        control-interface = "127.0.0.1";
        control-port = 8953;
      };
    };
  };

  # Not using unbound's dnscrypt so i can do it from novpn ns
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      server_names = [ "cloudflare" ];
      listen_addresses = [ "127.0.0.1:53" "192.168.150.2:53"];
    };
  };

  systemd.services.dnscrypt-proxy2 = {
    after = [ "novpn.service" "network-online.target" ];
    wants = [ "novpn.service" "network-online.target" ];
    bindsTo = [ "novpn.service" ];

    wantedBy = lib.mkForce [];
    serviceConfig = {
      StateDirectory = "dnscrypt-proxy";
      NetworkNamespacePath = "/run/netns/novpn";
    };
  };
}