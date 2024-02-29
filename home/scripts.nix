{ inputs, home, config, lib, pkgs, specialArgs, ... }: 

let 
  ephemeralbrowser = pkgs.writeScriptBin "ephemeralbrowser" ''
  #!/usr/bin/env bash

  default_interface=$(${pkgs.iproute2}/bin/ip route show default | ${pkgs.gawk}/bin/awk '/default/ {print $5}')
  interfaces=$(${pkgs.iproute2}/bin/ip -o -4 addr show | ${pkgs.gawk}/bin/awk '$4 ~ /\/24/ {print $2}' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/|/g')

  # The difference between default_interface and and default chose option is that default_interface is used to get dhcp from it, and default is for leave network as is without tweaking it (e.g. VPN/proxy/whatever)

  result=$(${pkgs.gnome.zenity}/bin/zenity --forms --title="Configuration" \
    --text="Please configure your settings" \
    --add-combo="Browser:" --combo-values="google_chrome|chromium" \
    --add-combo="Network Interface:" --combo-values="default|"$interfaces \
    --add-combo="DNS Server:" --combo-values="dhcp|1.1.1.1|8.8.8.8|77.88.8.1")

  browser=$(${pkgs.coreutils}/bin/echo "$result" | cut -d'|' -f1)
  interface=$(${pkgs.coreutils}/bin/echo "$result" | cut -d'|' -f2)
  dns=$(${pkgs.coreutils}/bin/echo "$result" | cut -d'|' -f3)

  if [[ $dns == "dhcp" ]]; then
    ${pkgs.coreutils}/bin/echo "Getting DNS from DHCP..."
    dns=$(${pkgs.networkmanager}/bin/nmcli device show $default_interface | ${pkgs.gnugrep}/bin/grep 'IP4.DNS\[1\]' | ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.gawk}/bin/awk '{print $2}')
    ${pkgs.coreutils}/bin/echo "DHCP's dns is $dns"
  fi

  ${pkgs.coreutils}/bin/mkdir -p /tmp/ephemeralbrowser

  if [[ $browser == "google_chrome" ]]; then
    browser_path="${pkgs.google-chrome}/bin/google-chrome-stable"
    profile="google-chrome"
  elif [[ $browser == "chromium" ]]; then
    browser_path="${pkgs.chromium}/bin/chromium"
    profile="chromium"
  fi

  ${pkgs.libnotify}/bin/notify-send --icon=google-chrome-unstable "Ephemeral Browser" "$browser | $interface | $dns" 

  if [[ $interface != "default" ]]; then
    firejail --ignore='include whitelist-run-common.inc' \
      --private=/tmp/ephemeralbrowser \
      --profile="$profile" \
      --net="$interface" \
      --dns="$dns" \
      "$browser_path" https://ifconfig.me
  else
    firejail --ignore='include whitelist-run-common.inc' \
      --private=/tmp/ephemeralbrowser \
      --profile="$profile" \
      --dns="$dns" \
      "$browser_path" https://ifconfig.me
  fi
  '';

  keepassxc = pkgs.writeScriptBin "keepassxc" ''
    #!/usr/bin/env bash
    ${pkgs.coreutils}/bin/cat /run/agenix/precise | ${pkgs.keepassxc}/bin/keepassxc --pw-stdin ~/Dropbox/pswd.kdbx
  '';
in {
  home.packages = with pkgs; [
    ephemeralbrowser
    keepassxc
  ];

  xdg.desktopEntries = {
    keepassxc = {
      name = "KeePassXC";
      icon = "keepassxc";
      exec = "/etc/profiles/per-user/cute/bin/keepassxc";
      type = "Application";
    };
    ephemeralbrowser = {
      name = "Ephemeral Browser";
      icon = "google-chrome-unstable";
      exec = "/etc/profiles/per-user/cute/bin/ephemeralbrowser";
      type = "Application";
    };
    autostart = {
      name = "Autostart";
      icon = "app-launcher";
      exec = "/etc/profiles/per-user/cute/bin/autostart"; # this is needed due to nix stuff, the path is going to be changed every time i update autostart script
      type = "Application";
    };
  };
  
}

