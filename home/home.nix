{ unstable, inputs, home, config, lib, pkgs, specialArgs, ... }:

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

  programs.tmux.enable = true;

  programs.vscode = {
    enable = true;
    package = unstable.vscodium;
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
    rustdesk
    chromium
    wl-clipboard
    wl-clipboard-x11
    (callPackage ../derivations/audiorelay.nix { })
    (callPackage ../derivations/spotify.nix { })
    xorg.xwininfo
  ]) ++ (with unstable; [
    xfce.thunar
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
  ]) ++ ([
    inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
    inputs.telegram-desktop-patched.packages.${pkgs.system}.default
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

  programs.fish = {
    enable = true;

    shellAliases = {
      rebuild = "nh os switch";
      rollback = "sudo nixos-rebuild switch --rollback --flake ~/Documents/dotfiles/";
      shell = "~/.local/share/shell";
    };
    shellInit = ''
      any-nix-shell fish --info-right | source
    '';
  };

  xdg.dataFile."run" = {
    enable = true;
    executable = true;
    text = ''
      #!/bin/sh
      if [[ $# -eq 0 ]]; then
        echo "Error: Missing argument."
      else
        nix run nixpkgs#"$1" -- "''${@:2}"
      fi
    '';
  };

  xdg.dataFile."shell" = {
    enable = true;
    executable = true;
    text = ''
      #!/bin/sh
      if [[ $# -eq 0 ]]; then
        echo "Error: Missing argument."
      else
        nix shell nixpkgs#"$1" -- "''${@:2}"
      fi
    '';
  };
}
