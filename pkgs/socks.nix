{ pkgs, lib, inputs, ... }:
let
  nixpkgs2305 = import inputs.nixpkgs2305 { system = "${pkgs.system}"; config = { allowUnfree = true; }; };
  socksBuilder = { name, script, autostart ? true, socketConfig ? null }:
    {
      inherit name;
      value = {
        enable = true;
        after = [ "novpn.service" "network-online.target" ];
        wants = [ "novpn.service" "network-online.target" ];
        bindsTo = [ "novpn.service" ];
        wantedBy = if autostart then [ "multi-user.target" ] else [ ];

        serviceConfig = { 
          Restart = "on-failure"; 
          RestartSec = "15"; 
          Type = "simple"; 
          NetworkNamespacePath = "/run/netns/novpn"; 
          User = "socks"; 
          Group = "socks"; 
        };

        script = script;
        preStart = "while true; do ip addr show dev novpn1 | grep -q 'inet' && break; sleep 1; done";

        path = with pkgs; [ 
          iproute2 
          shadowsocks-libev 
          shadowsocks-v2ray-plugin 
          sing-box 
          wireproxy
          gost
          (callPackage ../derivations/opera-proxy.nix { })
          ];
      };
    };
  
  socksed = [ # IP of the proxies is 192.168.150.2
    { name = "singbox-aus"; script = "sing-box run -c /run/secrets/singbox-aus";} # port 4000
    { name = "socks-warp" ; script = "wireproxy -c /etc/wireguzard/cproxy.conf"; } # port 3333
    { name = "socks-novpn"; script = "gost -L socks5://192.168.150.2:3334";     } # port 3334
    { name = "opera-socks"; 
    script = "sing-box run -c ${opera-singboxcfg} & opera-proxy -bootstrap-dns https://1.1.1.1/dns-query -bind-address 192.168.150.2:18088"; 
    autostart = false;
    socketConfig = { port = "3335"; idleStopSec = "180s"; };
    } # port 3335
  ];

  socketsServiceGenerator = { name, port, idleStopSec }: {
    inherit name;
    value = {
      description = "Socket activation for ${name}";
      wantedBy = [ "sockets.target" ];

      socketConfig = {
        ListenStream = "${port}";
        IdleStopSec = idleStopSec;
      };
    };
  };

  opera-singboxcfg = pkgs.writeText "opera-singboxcfg" ''
  {
    "log": {
      "disabled": true,
      "output": "stdout"
    },
    "inbounds": [
      {
        "type": "socks",
        "listen": "192.168.150.2",
        "listen_port": 3335,
        "sniff": true,
        "sniff_override_destination": true
      }
    ],
    "outbounds": [
      {
        "type": "http",
        "server": "192.168.150.2",
        "server_port": 18088
      }
    ]
  }
  '';

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

  socketsBuilder = socketsServiceGenerator;
  withSockets = lib.filter (s: lib.hasAttr "socketConfig" s) socksed;

  enabledSocksed = lib.filter (s: !lib.hasAttr "autostart" s || s.autostart) socksed;
in {
  users.users.socks = {
    group = "socks";
    isSystemUser = true;
  };

  users.groups.socks = {};

  systemd.sockets = builtins.listToAttrs (map (s: socketsBuilder {
    name = s.name;
    port = s.socketConfig.port;
    idleStopSec = s.socketConfig.idleStopSec;
  }) withSockets);

  systemd.services = builtins.listToAttrs (map socksBuilder socksed) // { 
    novpn = {
      enable = true;
      description = "novpn namespace";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      wants = map (s: "${s.name}.service") enabledSocksed ++ [ "network-online.target"];

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "15";
        ExecStart = "${start_novpn}/bin/start_novpn";
        ExecStop = "${stop_novpn}/bin/stop_novpn";
        StateDirectory = "novpn";
        Type = "simple";
      };

      postStart = ''
      gost -L=tcp://0.0.0.0:4780/192.168.150.2:4780 &>/dev/null &
      '';

      preStart = "${stop_novpn}/bin/stop_novpn && ip netns add novpn";
      path = with pkgs; [ gost gawk iproute2 iptables sysctl coreutils ];
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
        ExecStart = "${nixpkgs2305.cloudflare-warp}/bin/warp-svc";
      };

      postStart = ''
        while true; do
          set -e
          status=$(${nixpkgs2305.cloudflare-warp}/bin/warp-cli status || true)
          set +e

          if [[ "$status" != *"Unable to connect to CloudflareWARP daemon"* ]]; then
            ${nixpkgs2305.cloudflare-warp}/bin/warp-cli set-custom-endpoint 162.159.193.1:2408
            exit 0
          fi
          sleep 1
        done
      '';
    };

    tor.wantedBy = lib.mkForce [];
  };

  environment.systemPackages = [
    (pkgs.writeScriptBin "warp-cli" "${nixpkgs2305.cloudflare-warp}/bin/warp-cli $@")
    (pkgs.writeScriptBin "nyx" ''sudo -u tor -g tor ${inputs.nixpkgs2105.legacyPackages."${pkgs.system}".nyx}/bin/nyx $@'')
    (pkgs.writeScriptBin "tor-warp" ''
      if [[ "$1" == "start" ]]; then
        echo "Starting..."
        warp-cli set-mode proxy
        warp-cli set-proxy-port 4000
        sudo systemctl start tor
      elif [[ "$1" == "stop" ]]; then
        echo "Stopping..."
        warp-cli set-mode warp
        sudo systemctl stop tor
      else
        echo "Error: specify start or stop"
      fi
    '')
  ];

  services.tor = {
    enable = true;
    client = {
      enable = true;
      socksListenAddress = 9050;
    };
    settings = {
      # UseBridges = true;
      # ClientTransportPlugin = "snowflake exec ${pkgs.snowflake}/bin/client";
      # Bridge = "snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://snowflake-broker.torproject.net.global.prod.fastly.net/ fronts=www.shazam.com,www.cosmopolitan.com,www.esquire.com ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn";
      Socks5Proxy = "localhost:4000"; # requires setting warp-svc to proxy mode: warp-cli set-mode proxy && warp-cli set-proxy-port 4000
      ControlPort = 9051;
      CookieAuthentication = true;
    };
  };
}

