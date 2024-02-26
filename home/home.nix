{ stable, unstable, inputs, home, config, lib, pkgs, specialArgs, ... }:

{
  home.username = "delta";
  home.stateVersion = "23.11";

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  imports = [ ./programs ./theme.nix ];

  services.blueman-applet.enable = true;
  services.network-manager-applet.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      brettm12345.nixfmt-vscode
    ];
  };

  xdg.desktopEntries = {
    maestral = {
      name = "Maestral";
      icon = "maestral";
      exec =
        ''sh -c "QT_QPA_PLATFORM=xcb ${pkgs.maestral-gui}/bin/maestral_qt"'';
      type = "Application";
    };
  };

  home.packages = (with pkgs; [
    git
    chromium
    wl-clipboard
    wl-clipboard-x11
    (callPackage ../derivations/audiorelay.nix { })
    (callPackage ../derivations/spotify.nix { })
    xorg.xwininfo
  ]) ++ (with unstable; [
    xfce.thunar
    rustdesk-flutter
    nixfmt
    btop
    htop
    foot
    kitty
    keepassxc
    alacritty
    dig
    nwg-displays
    nwg-drawer
    imagemagick
    fastfetch
    hyfetch
    pavucontrol
    wget
    wlogout
    swaylock
    swayidle
    nom
    vesktop
  ]) ++ (with stable; [ 
    localsend
  ]) ++ ([
    inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
  ]);

  dconf = {
    enable = true;
    settings = {
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-battery-timeout =
        300;
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
  };

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto";
      slang = "en,eng";
      alang = "en,eng";
      subs-fallback = "default";
      subs-with-matching-audio = "yes";
      save-position-on-quit = "yes";
    };
    scripts = with pkgs; [ mpvScripts.autoload mpvScripts.cutter ];
    scriptOpts = {
      autoload = {
        disabled = "no";
        images = "no";
        videos = "yes";
        audio = "yes";
        additional_image_exts = "list,of,ext";
        additional_video_exts = "list,of,ext";
        additional_audio_exts = "list,of,ext";
        ignore_hidden = "yes";
      };
    };
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "intelnuc" = {
        hostname = "192.168.3.53";
      };
      "huanan" = {
        hostname = "192.168.3.106";
      };
    };
  };
}
