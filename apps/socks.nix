{ pkgs, lib, config, inputs, ... }:
let
  socksBuilder = attrs:
    {
      inherit (attrs) name;
      value = {
        enable = true;
        after = [ "novpn.service" "network-online.target" ];
        wants = [ "novpn.service" "network-online.target" ];
        bindsTo = [ "novpn.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = { 
          Restart = "on-failure"; 
          RestartSec = "15"; 
          Type = "simple"; 
          NetworkNamespacePath = "/run/netns/novpn"; 
          User = "socks"; 
          Group = "socks"; 
        };

        script = attrs.script;
        preStart = "while true; do ip addr show dev novpn1 | grep -q 'inet' && break; sleep 1; done";

        path = with pkgs; [ 
          iproute2 
          shadowsocks-libev 
          shadowsocks-v2ray-plugin 
          sing-box 
          wireproxy 
          (callPackage ../derivations/microsocks.nix {}) ];
      };
    };
  
 # IP of the proxies is 192.168.150.2
  
  socksed = [
    { name = "singbox-aus"; script = "sing-box run -c /run/secrets/singbox-aus";   } # port 4000
    { name = "socks-warp";  script = "wireproxy -c /etc/wireguard/warp0.conf";     } # port 3333
    { name = "socks-novpn"; script = "microsocks -i 192.168.150.2 -p 3334";        } # port 3334
  ];

  delete_rules = pkgs.writeScriptBin "delete_rules" ''
    #!${pkgs.bash}/bin/bash
    default_gateway=$(cat /etc/netns/novpn/default_gateway)
    default_interface=$(cat /etc/netns/novpn/default_interface)

    ip rule del fwmark 150 table 150
    ip rule del from 192.168.150.2 table 150
    ip rule del to 192.168.150.2 table 150
    ip route del default via $default_gateway dev $default_interface table 150
    ip route del 192.168.150.2 via 192.168.150.1 dev novpn0 table 150
    iptables -t nat -D POSTROUTING -o "$default_interface" -j MASQUERADE
  '';

  start_novpn = pkgs.writeScriptBin "start_novpn" ''
    #!${pkgs.bash}/bin/bash
    add_rules() {
      ip rule add fwmark 150 table 150
      ip rule add from 192.168.150.2 table 150
      ip rule add to 192.168.150.2 table 150
      ip route add default via $default_gateway dev $default_interface table 150 
      ip route add 192.168.150.2 via 192.168.150.1 dev novpn0 table 150
      iptables -t nat -A POSTROUTING -o "$default_interface" -j MASQUERADE
    }

    set_gateway() {
      default_interface_new=$(ip route | awk '/default/ {print $5; exit}')
      default_gateway_new=$(ip route | awk '/default/ {print $3; exit}')

      if [[ ! -z "$default_interface_new" && ! -z "$default_gateway_new" ]]; then
        default_interface=$default_interface_new
        default_gateway=$default_gateway_new
        echo "$default_gateway" > /etc/netns/novpn/default_gateway
        echo "$default_interface" > /etc/netns/novpn/default_interface
      fi
    }

    mkdir -p /etc/netns/novpn/
    echo "nameserver 1.1.1.1" > /etc/netns/novpn/resolv.conf
    echo "nameserver 1.1.0.1" >> /etc/netns/novpn/resolv.conf
    sysctl -wq net.ipv4.ip_forward=1

    ip link add novpn0 type veth peer name novpn1
    ip link set novpn1 netns novpn
    ip addr add 192.168.150.1/24 dev novpn0
    ip link set novpn0 up
    ip netns exec novpn ip link set lo up
    ip netns exec novpn ip addr add 192.168.150.2/24 dev novpn1
    ip netns exec novpn ip link set novpn1 up
    ip netns exec novpn ip route add default via 192.168.150.1

    set_gateway
    if [[ -z "$default_interface" ]]; then
      echo "No default interface"
      exit 1
    fi
    add_rules
    sleep 3

    ip monitor route | while read -r event; do
      case "$event" in
          'local '*)
            ${delete_rules}/bin/delete_rules
            set_gateway
            add_rules
          ;;
      esac
    done
  '';

  stop_novpn = pkgs.writeScriptBin "stop_novpn" ''
    #!${pkgs.bash}/bin/bash
    ${delete_rules}/bin/delete_rules
    rm -rf /etc/netns/novpn/
    ip link del novpn0
    ip netns del novpn
    rm -rf /var/run/netns/novpn/
  '';
in {
  users.users.socks = {
    group = "socks";
    isSystemUser = true;
  };

  users.groups.socks = {};
  systemd.services = builtins.listToAttrs (map socksBuilder socksed) // { 
    novpn = {
      enable = true;
      description = "novpn namespace";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      wants = map (s: "${s.name}.service") socksed ++ [ "network-online.target"];

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "15";
        ExecStart = "${start_novpn}/bin/start_novpn";
        ExecStop = "${stop_novpn}/bin/stop_novpn";
        StateDirectory = "novpn";
        Type = "simple";
      };
      
      preStart = "${stop_novpn}/bin/stop_novpn && ip netns add novpn";
      path = with pkgs; [ gawk iproute2 iptables sysctl coreutils ];
    };

    warp-svc = {
      enable = true;
      description = "Cloudflare Zero Trust Client Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "pre-network.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "15";
        DynamicUser = "no";
        # ReadOnlyPaths = "/etc/resolv.conf";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE";
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE";
        StateDirectory = "cloudflare-warp";
        RuntimeDirectory = "cloudflare-warp";
        LogsDirectory = "cloudflare-warp";
        ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      };

      postStart = ''
        while true; do
          set -e
          status=$(${pkgs.cloudflare-warp}/bin/warp-cli status || true)
          set +e

          if [[ "$status" != *"Unable to connect to CloudflareWARP daemon"* ]]; then
            ${pkgs.cloudflare-warp}/bin/warp-cli set-custom-endpoint 162.159.193.1:2408
            exit 0
          fi
          sleep 1
        done
      '';
    };

    tor.wantedBy = lib.mkForce [];
  };

  users.users.delta.packages = [
    (pkgs.writeScriptBin "nyx" ''sudo -u tor -g tor ${inputs.nixpkgs2105.legacyPackages."x86_64-linux".nyx}/bin/nyx $@'')
  ];

  services.tor = {
    enable = true;
    client = {
      enable = true;
      socksListenAddress = 9063;
    };
    settings = {
      Socks5Proxy = "192.168.150.2:3333";
      ControlPort = 9051;
      CookieAuthentication = true;
    };
  };
}

