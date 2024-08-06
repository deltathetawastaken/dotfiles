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

        #disable logging
        log-local-actions = "no";
        log-queries = "no";
        log-replies = "no";
        log-servfail = "no";
        logfile = "/dev/null";
        verbosity = 0;

        #fix local domains
        neg-cache-size = "4M";
        unblock-lan-zones = "yes";
        insecure-lan-zones = "yes";

        #speed
        infra-cache-slabs = 2;
        num-threads = 1;
        minimal-responses = "yes";

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
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    };
  };

  # systemd.services.dnscheck = {
  #   enable = true;
  #   after = [ "novpn.service" "network-online.target" ];
  #   wants = [ "novpn.service" "network-online.target" ];

  #   serviceConfig = {
  #     Type="oneshot";
  #     RuntimeMaxSec = 30;
  #     User = "delta";
  #     Group = "users";
  #     PrivateNetwork = false;
  #   };
  
  #   script = ''
  #     #!usr/bin/env bash

  #     DNS_SERVER="100.92.15.128"

  #     check_host() {
  #         ping -c 1 -W 5 $1 >/dev/null 2>&1
  #         return $?
  #     }

  #     if check_host $DNS_SERVER; then
  #         sudo systemctl stop dnscrypt-proxy2
  #     else
  #         sudo systemctl start dnscrypt-proxy2
  #     fi
  #   '';
  # };
  # systemd.timers.dnscheck = {
  #   enable = true;
  #   timerConfig = {
  #     OnBootSec = "2min";
  #     OnUnitActiveSec = "3min";
  #   };
  # };
}