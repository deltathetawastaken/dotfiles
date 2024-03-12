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

  imports = [ 
    ./programs 
    ./theme.nix
    ./scripts.nix
    ./gnome.nix
  ];

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
    #(callPackage ../derivations/nu_plugin_dns.nix { })
    xorg.xwininfo
    jq
  ]) ++ (with unstable; [
    xfce.thunar
    rustdesk-flutter
    autossh
    scrcpy
    nixfmt
    btop
    htop
    foot
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
    nom
    vesktop
    firefox
  ]) ++ (with stable; [ 
    localsend
    trayscale
  ]) ++ ([
    # inputs.firefox.packages.${pkgs.system}.firefox-bin
  ]);


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

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = false;
    settings = {
      background = "#171717";
      foreground = "#DCDCCC";
      background_opacity = "0.8";
      remember_window_size = "yes";
      hide_window_decorations = "yes";
      remote_control_password = "kitty-notification-password-fish ls";
      allow_remote_control = "password";

      color0 = "#3F3F3F";
      color1 = "#705050";
      color2 = "#60B48A";
      color3 = "#DFAF8F";
      color4 = "#9AB8D7";
      color5 = "#DC8CC3";
      color6 = "#8CD0D3";
      color7 = "#DCDCCC";

      color8 = "#709080";
      color9 = "#DCA3A3";
      color10 = "#72D5A3";
      color11 = "#F0DFAF";
      color12 = "#94BFF3";
      color13 = "#EC93D3";
      color14 = "#93E0E3";
      color15 = "#FFFFFF";
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
