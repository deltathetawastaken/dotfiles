{ pkgs, lib, ... }: 
let
  nginxConfig = pkgs.writeText "nginx_config" ''
    pid /tmp/.nginx-work.pid;
    error_log /dev/stdout info;
    daemon off;
    master_process off;
    events {}

    http {
      include ${pkgs.mailcap}/etc/nginx/mime.types;
      include ${pkgs.nginx}/conf/fastcgi.conf;
      include ${pkgs.nginx}/conf/uwsgi_params;

      access_log /dev/stdout;
      error_log /dev/stdout info;
      types_hash_max_size 4096;
      default_type application/octet-stream;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
      client_max_body_size 10m;
      server_tokens off;

      map $http_upgrade $connection_upgrade {
        default upgrade;
        '''       close;
      }
      
      server {
        listen 127.0.0.1:80 ;
        server_name graf1.local ;
        
        location / {
          proxy_set_header        Host $host;
          proxy_set_header        X-Real-IP $remote_addr;
          proxy_pass              http://123.123.123.123:3000;
        }
        
        location /api/live/ws {
          proxy_pass http://123.123.123.123:3000;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      }

      server {
        listen 127.0.0.1:80;
        server_name graf2.local;
        
        location / {
          proxy_set_header        Host $host;
          proxy_set_header        X-Real-IP $remote_addr;
          proxy_pass              http://123.123.123.123:3000;
        }
        
        location /api/live/ws {
          proxy_pass http://123.123.123.123:3000;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        }
      }

      server {
        listen 127.0.0.1:80 ;
        server_name kibana.local ;
        
        location / {
          proxy_set_header        Host $host;
          proxy_set_header        X-Real-IP $remote_addr;
          proxy_pass              http://123.123.123.123:5601;
        }
      }
    }
  '';

  namespacedWork = pkgs.writeScriptBin "namespaced_work" ''
    #!/usr/bin/env bash
    NETNS_NAME="work"
    NETNS_NAMESERVER_1="1.1.1.1"
    NETNS_NAMESERVER_2="1.1.0.1"

    VETH0_NAME="work0"
    VETH1_NAME="work1"
    VETH0_IP="192.168.240.1"
    VETH1_IP="192.168.240.2"

    ########################################################################################################################

    if ip netns | grep -q "$NETNS_NAME"; then
      echo "This script is already running!"
      exit 1
    fi

    MAIN_PID=$$
    RUNNING=true

    get_default_interface() {
      default_gateway=$(ip route | awk '/default/ {print $3}')
      default_interface=$(ip route | awk '/default/ {print $5}')

      if [[ -z "$default_interface" ]]; then
        echo "No default interface, are you connected to the internet?"
        exit 1
      fi

      echo "Default gateway: $default_gateway"
      echo "Default interface: $default_interface"

      read -p "Continue? [Y/n] " choice

      if [[ $choice =~ ^[Nn]$ ]]; then
        echo "Exiting..."
        exit 0
      fi
    }

    purge_rules() { # Run only before deleting namespace
      ip rule del fwmark 135 table 135
      ip rule del from $VETH1_IP table 135
      ip rule del to $VETH1_IP table 135
      ip route del default via $default_gateway dev $default_interface table 135
      ip route del $VETH1_IP via $VETH0_IP dev $VETH0_NAME table 135
    }

    create_rules() { # Run after creating namespace
      ip rule add fwmark 135 table 135
      ip rule add from $VETH1_IP table 135
      ip rule add to $VETH1_IP table 135
      ip route add default via $default_gateway dev $default_interface table 135
      ip route add $VETH1_IP via $VETH0_IP dev $VETH0_NAME table 135
    }

    delete_netns() {
      rm -rf /etc/netns/$NETNS_NAME/

      purge_rules
      iptables -t nat -D POSTROUTING -o "$default_interface" -j MASQUERADE

      ip link del $VETH0_NAME
      ip netns del $NETNS_NAME
    }

    create_netns() {
      if ip netns | grep -q "$NETNS_NAME"; then
        delete_netns
      fi

      mkdir -p /etc/netns/$NETNS_NAME/
      echo "nameserver $NETNS_NAMESERVER_1" > /etc/netns/$NETNS_NAME/resolv.conf
      echo "nameserver $NETNS_NAMESERVER_2" >> /etc/netns/$NETNS_NAME/resolv.conf
      sysctl -wq net.ipv4.ip_forward=1
      iptables -t nat -A POSTROUTING -o "$default_interface" -j MASQUERADE

      ip netns add $NETNS_NAME
      ip link add $VETH0_NAME type veth peer name $VETH1_NAME
      ip link set $VETH1_NAME netns $NETNS_NAME
      ip addr add $VETH0_IP/24 dev $VETH0_NAME
      ip link set $VETH0_NAME up
      ip netns exec $NETNS_NAME ip link set lo up
      ip netns exec $NETNS_NAME ip addr add $VETH1_IP/24 dev $VETH1_NAME
      ip netns exec $NETNS_NAME ip link set $VETH1_NAME up
      ip netns exec $NETNS_NAME ip route add default via $VETH0_IP
      ip netns exec $NETNS_NAME sysctl -w net.ipv4.ip_unprivileged_port_start=80

      create_rules

      export NETNS_NAME
      timeout 3s bash -c 'ip netns exec $NETNS_NAME sudo -u nobody curl -s ipinfo.io | sudo -u nobody ${pkgs.jq}/bin/jq -r "\"IP: \(.ip)\nCity: \(.city)\nProvider: \(.org)\""'

      if [ $? -eq 124 ]; then
        echo "Timed out, is something wrong?"
        kill -INT -$MAIN_PID
      fi
    }

    ########################################################################################################################

    cleanup() {
      if [ "$RUNNING" = true ]; then
        RUNNING=false
        echo "Terminating all processes inside of $NETNS_NAME namespace..."
        pids=$(find -L /proc/[1-9]*/task/*/ns/net -samefile /run/netns/$NETNS_NAME | cut -d/ -f5) &> /dev/null
        kill -SIGINT -$pids &> /dev/null
        kill -SIGTERM -$pids &> /dev/null
        echo "Waiting 3 seconds before SIGKILL..."
        sleep 3
        kill -SIGKILL -$pids &> /dev/null
        delete_netns
        echo "Exiting..."
        exit 0
      fi
    }

    ########################################################################################################################

    ip_monitor() {
      sleep 2 # wait before they actually start to make sense
      ip monitor route | while read -r event; do
        case "$event" in
            'local '*)
              default_gateway_new=$(ip route | awk '/default/ {print $3}')

              if [[ ! -z "$default_gateway_new" ]]; then
                if [[ ! "$default_gateway_new" == "$default_gateway" ]]; then
                  echo "New gateway $default_gateway_new, stopping"
                  kill -INT -$MAIN_PID
                fi
              fi

              echo "Network event detected, readding rules"
              purge_rules
              create_rules
            ;;
        esac
      done
    };

    ping() {
      local connected=true;
      while true; do
        if ip netns exec $NETNS_NAME ping -c 1 -W 1 $NETNS_NAMESERVER_1 &> /dev/null; then
          if [ "$connected" = false ]; then
            echo "Connection restored"
          fi
          connected=true
        else
          connected=false
          echo "No ping from $NETNS_NAMESERVER_1, are we connected to the internet?"
        fi
        sleep 15
      done
    }

    ########################################################################################################################

    vpn() {
      ip netns exec $NETNS_NAME /home/delta/scripts/vpn-connect-WB
    }

    nginx() {
      ip netns exec $NETNS_NAME sudo -u delta -g users ${pkgs.nginx}/bin/nginx -c ${nginxConfig}
    }

    firefox() {
      sudo -E -u delta -g users firejail --ignore='include whitelist-run-common.inc' --blacklist='/var/run/nscd' --profile=firefox --hosts-file=${hostsNoRemote} --netns=work firefox -P work -no-remote --class firefoxwork --name firefoxwork
    }

    start_subshell() {
      local function_name=$1
      (
        "$function_name" &
        wait
      ) &
    }

    get_default_interface
    trap cleanup INT
    create_netns
    start_subshell "ip_monitor"
    start_subshell "ping"
    start_subshell "vpn"
    start_subshell "nginx"
    start_subshell "firefox"
    wait
  '';

  hostsNoRemote = pkgs.writeText "hosts_no_remote" ''
    127.0.0.1 graf1.local graf2.local kibana.local
  '';
  
  hostsRemote = pkgs.writeText "host_remote" ''
    100.92.15.128 graf1.local graf2.local kibana.local
  '';

  kittyWork = pkgs.writeScriptBin "kittywork" ''
    ${pkgs.kitty}/bin/kitty --class kittywork ${pkgs.tmux}/bin/tmux new-session -s work sh -c "sudo -E ${namespacedWork}/bin/namespaced_work || sleep inf"
  '';

  kittyWorkDesktopItem = pkgs.makeDesktopItem {
    name = "kittywork";
    desktopName = "Kitty Work";
    icon = "kitty";
    exec = "kittywork";
  };

  firefoxWork = pkgs.writeScriptBin "firefoxwork" ''
    choice=$(${pkgs.gnome.zenity}/bin/zenity --list --title="Select Remote Option" --text="Choose an option:" --column="Options" "remote" "no-remote" "no-remote-resume" --width=250 --height=300)
    
    if [[ $choice == "no-remote" ]]; then
      ${pkgs.gtk3}/bin/gtk-launch kittywork
    elif [[ $choice == "no-remote-resume" ]]; then
      firejail --ignore='include whitelist-run-common.inc' --blacklist='/var/run/nscd' --profile=firefox --hosts-file=${hostsNoRemote} --netns=work firefox -P work -no-remote --class firefoxwork --name firefoxwork
    elif [[ $choice == "remote" ]]; then
      firejail --ignore='include whitelist-run-common.inc' --blacklist='/var/run/nscd' --profile=firefox --hosts-file=${hostsRemote} ${pkgs.firefox}/bin/firefox -P work -no-remote --class firefoxwork --name firefoxwork
    else
      exit 1
    fi
  '';

  firefoxWorkDesktopItem = pkgs.makeDesktopItem {
    name = "firefoxwork";
    desktopName = "Firefox Work";
    icon = "firefox-nightly";
    exec = "firefoxwork";
    startupWMClass = "firefoxwork";
  };
in
{
  users.users.delta.packages = with pkgs; [
    kittyWork
    kittyWorkDesktopItem
    firefoxWork
    firefoxWorkDesktopItem
  ];
}