{ inputs, home, config, lib, pkgs, specialArgs, ... }: 

let 
  ephemeralbrowser = pkgs.writeScriptBin "ephemeralbrowser" ''
    #!/usr/bin/env bash

    default_interface=$(${pkgs.iproute2}/bin/ip route show default | ${pkgs.gawk}/bin/awk '/default/ {print $5}')
    interfaces=$(${pkgs.iproute2}/bin/ip -o -4 addr show | ${pkgs.gawk}/bin/awk '$4 ~ /\/24/ {print $2}' | grep -v "wlp1s0" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/|/g')

    # The difference between default_interface and and default chose option is that default_interface is used to get dhcp from it, and default is for leave network as is without tweaking it (e.g. VPN/proxy/whatever)

    result=$(${pkgs.gnome.zenity}/bin/zenity --forms --title="Configuration" \
      --text="Please configure your settings" \
      --add-combo="Browser:" --combo-values="google_chrome|ungoogled_chromium|firefox" \
      --add-combo="Network Interface:" --combo-values="wlp1s0|default|"$interfaces \
      --add-combo="DNS Server:" --combo-values="dhcp|1.1.1.1|8.8.8.8|77.88.8.1")

    if [[ -z $result ]]; then
      exit 1
    fi

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
      browser_path="${pkgs.google-chrome}/bin/google-chrome-stable https://ifconfig.me"
      profile="google-chrome"
    elif [[ $browser == "ungoogled_chromium" ]]; then
      browser_path="${pkgs.ungoogled-chromium}/bin/chromium https://ifconfig.me"
      profile="chromium"
    elif [[ $browser == "firefox" ]]; then
      browser_path="${pkgs.firefox}/bin/firefox -no-remote https://ifconfig.me"
      profile="firefox"
    fi

    ${pkgs.libnotify}/bin/notify-send --icon=google-chrome-unstable "Ephemeral Browser" "$browser | $interface | $dns" 

    # FOR SOME FUCKING REASON https://github.com/netblue30/firejail/issues/2869#issuecomment-546579293
    if [[ $interface != "default" ]]; then
      firejail \
        --ignore='include whitelist-run-common.inc' \
        --blacklist='/var/run/nscd' \
        --private=/tmp/ephemeralbrowser \
        --profile="$profile" \
        --net="$interface" \
        --dns="$dns" \
        bash -c "$browser_path"
    else
      firejail \
        --ignore='include whitelist-run-common.inc' \
        --blacklist='/var/run/nscd' \
        --private=/tmp/ephemeralbrowser \
        --profile="$profile" \
        --dns="$dns" \
        bash -c "$browser_path"
    fi
  '';

  ephemeralbrowserDesktopItem = pkgs.makeDesktopItem {
    name = "ephemeralbrowser";
    desktopName = "Ephemeral Browser";
    icon = "google-chrome-unstable";
    exec = "/etc/profiles/per-user/delta/bin/ephemeralbrowser";
    type = "Application";
  };

  keepassxc = pkgs.writeScriptBin "keepassxc" ''
    #!/usr/bin/env bash
    ${pkgs.coreutils}/bin/cat /run/agenix/qqq | ${pkgs.keepassxc}/bin/keepassxc --pw-stdin ~/Dropbox/pswd.kdbx
  '';

  keepassxcDesktopItem = pkgs.makeDesktopItem {
    name = "org.keepassxc.KeePassXC";
    desktopName = "KeePassXC";
    icon = "keepassxc";
    exec = "/etc/profiles/per-user/delta/bin/keepassxc";
    type = "Application";
    startupWMClass = "keepassxc";
  };

  kitty_wrapped = pkgs.writeScriptBin "kitty_wrapped" ''
    #!/usr/bin/env bash
    pid=$(${pkgs.procps}/bin/pgrep "kitty")

    if [[ -z $pid ]]; then
      kitty --start-as maximized &
    else
      ${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Shell --object-path /de/lucaswerkmeister/ActivateWindowByTitle --method de.lucaswerkmeister.ActivateWindowByTitle.activateByWmClass 'kitty'
    fi
  '';

  autostart = pkgs.writeScriptBin "autostart" ''
    #!/usr/bin/env bash
    ${pkgs.coreutils}/bin/sleep 5
    ${pkgs.gtk3}/bin/gtk-launch dropbox.desktop
    ${pkgs.gtk3}/bin/gtk-launch org.keepassxc.KeePassXC.desktop
    exit 0
  '';

  autostartDesktopItem = pkgs.makeDesktopItem {
    name = "autostart";
    desktopName = "Autostart";
    icon = "app-launcher";
    exec = "/etc/profiles/per-user/delta/bin/autostart";
    type = "Application";
  };
in {
  home.packages = with pkgs; [
    ephemeralbrowser
    ephemeralbrowserDesktopItem
    keepassxc
    keepassxcDesktopItem
    kitty_wrapped
    autostart
    autostartDesktopItem
  ];
}