{ inputs, home, config, lib, pkgs, specialArgs, ... }: 

let 
  ephemeralbrowser = pkgs.writeScriptBin "ephemeralbrowser" ''
    #!/usr/bin/env bash

    default_interface=$(${pkgs.iproute2}/bin/ip route show default | ${pkgs.gawk}/bin/awk '/default/ {print $5; exit}')
    interfaces=$(${pkgs.iproute2}/bin/ip -o -4 addr show | ${pkgs.gawk}/bin/awk '$4 ~ /\/24/ {print $2; exit}' | grep -v "wlp1s0" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/|/g')

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
      browser_path="${pkgs.ungoogled-chromium}/bin/chromium --user-data-dir=/tmp/ephemeralbrowser/.config/chromium https://ifconfig.me"
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
    icon = "browser";
    exec = "/etc/profiles/per-user/delta/bin/ephemeralbrowser";
    type = "Application";
  };

  googleChromeRussia = pkgs.writeScriptBin "google-chrome-russia" ''
    mkdir -p $HOME/.google-chrome-russia/.pki/nssdb/
    ${pkgs.nssTools}/bin/certutil -d sql:$HOME/.google-chrome-russia/.pki/nssdb -A -t "C,," -n "Russian Trusted Root" -i ${builtins.fetchurl {
      url = "https://gu-st.ru/content/lending/russian_trusted_root_ca_pem.crt";
      sha256 = "sha256:0135zid0166n0rwymb38kd5zrd117nfcs6pqq2y2brg8lvz46slk";
    }}
    ${pkgs.nssTools}/bin/certutil -d sql:$HOME/.google-chrome-russia/.pki/nssdb -A -t "C,," -n "Russian Trusted Sub CA" -i ${builtins.fetchurl {
      url = "https://gu-st.ru/content/lending/russian_trusted_sub_ca_pem.crt";
      sha256 = "sha256:19jffjrawgbpdlivdvpzy7kcqbyl115rixs86vpjjkvp6sgmibph";
    }}  
    firejail --blacklist="/var/run/nscd" --ignore="include whitelist-run-common.inc" --private=$HOME/.google-chrome-russia --net=$(${pkgs.iproute2}/bin/ip route | ${pkgs.gawk}/bin/awk '/default/ {print $5; exit}') --dns=77.88.8.1 --profile=google-chrome ${pkgs.google-chrome}/bin/google-chrome-stable --class=google-chrome-russia --app-id=google-chrome-russia
  '';

  googleChromeRussiaDesktopItem = pkgs.makeDesktopItem {
    name = "google-chrome-russia";
    desktopName = "Google Chrome Russia";
    startupWMClass = "google-chrome-russia";
    icon = "google-chrome-unstable";
    exec = "google-chrome-russia";
  };

  keepassxc = pkgs.writeScriptBin "keepassxc" ''
    #!/usr/bin/env bash
    ${pkgs.coreutils}/bin/base64 -d ${config.sops.secrets.qqq.path} | ${pkgs.keepassxc}/bin/keepassxc --pw-stdin ~/Dropbox/pswd.kdbx
    ${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Shell --object-path /de/lucaswerkmeister/ActivateWindowByTitle --method de.lucaswerkmeister.ActivateWindowByTitle.activateByWmClass 'org.keepassxc.KeePassXC'
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
      kitty --start-as maximized --single-instance &
    else
      ${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Shell --object-path /de/lucaswerkmeister/ActivateWindowByTitle --method de.lucaswerkmeister.ActivateWindowByTitle.activateByWmClass 'kitty'
    fi
  '';

  autostart = pkgs.writeScriptBin "autostart" ''
    #!/usr/bin/env bash
    ${pkgs.coreutils}/bin/sleep 5
    ${pkgs.gtk3}/bin/gtk-launch dropbox.desktop
    ${pkgs.gtk3}/bin/gtk-launch org.keepassxc.KeePassXC.desktop
    # gsettings set org.gnome.desktop.interface cursor-size 16
    exit 0
  '';

  autostartDesktopItem = pkgs.makeDesktopItem {
    name = "autostart";
    desktopName = "Autostart";
    icon = "app-launcher";
    exec = "/etc/profiles/per-user/delta/bin/autostart";
    type = "Application";
  };

  firefoxRussia = pkgs.writeScriptBin "firefox-russia" ''
    #!/usr/bin/env bash
    firejail --blacklist="/var/run/nscd" --ignore="include whitelist-run-common.inc" --net=$(${pkgs.iproute2}/bin/ip route | ${pkgs.gawk}/bin/awk '/default/ {print $5; exit}') --dns=77.88.8.1 firefox --class firefox-russia --name firefox-russia -P russia -no-remote
  '';

  firefoxRussiaDesktopItem = pkgs.makeDesktopItem {
    name = "firefox-russia";
    desktopName = "Firefox Russia";
    icon = "firefox-developer-edition";
    exec = "firefox-russia";
  };
in {
  users.users.delta.packages = [
    kitty_wrapped
    ephemeralbrowser  ephemeralbrowserDesktopItem
    keepassxc         keepassxcDesktopItem
    autostart         autostartDesktopItem
    firefoxRussia     firefoxRussiaDesktopItem
    googleChromeRussia googleChromeRussiaDesktopItem
  ];
}