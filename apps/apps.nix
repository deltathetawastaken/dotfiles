{ pkgs, lib, inputs, stable, self, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  kitty_config = pkgs.writeText "kitty.conf" ''
    # See https://sw.kovidgoyal.net/kitty/conf.html
    shell_integration no-rc

    allow_remote_control password
    background #171717
    background_opacity 0.8
    color0 #3F3F3F
    color1 #705050
    color10 #72D5A3
    color11 #F0DFAF
    color12 #94BFF3
    color13 #EC93D3
    color14 #93E0E3
    color15 #FFFFFF
    color2 #60B48A
    color3 #DFAF8F
    color4 #9AB8D7
    color5 #DC8CC3
    color6 #8CD0D3
    color7 #DCDCCC
    color8 #709080
    color9 #DCA3A3
    foreground #DCDCCC
    hide_window_decorations yes
    remember_window_size yes
    remote_control_password kitty-notification-password-fish ls
  '';
in {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  users.users.delta.packages = (with pkgs; [
    git
    #chromium
    wl-clipboard
    wl-clipboard-x11
    (callPackage "${self}/derivations/audiorelay.nix" { })
    (callPackage "${self}/derivations/spotify.nix" { })
    #(callPackage ../derivations/nu_plugin_dns.nix { })
    xorg.xwininfo
    jq
    dropbox
    spotdl
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
    (vesktop.overrideAttrs (oldAttrs: {
      desktopItems = [ (pkgs.makeDesktopItem {
        name = "vesktop";
        desktopName = "Discord";
        exec = "vesktop %U";
        icon = "discord";
        startupWMClass = "Vesktop";
        genericName = "Internet Messenger";
        keywords = [ "discord" "vencord" "electron" "chat" ];
        categories = [ "Network" "InstantMessaging" "Chat" ];
      })];
    }))
    localsend
    trayscale
    fishPlugins.done
    monero-gui
    inputs.telegram-desktop-patched.packages.${pkgs.system}.default
    translate-shell
    tridactyl-native #firefox tridactyl addon
    ripgrep gh # for nvim
    lunarvim # text edit
    lexend # font from google (non-mono)
    jamesdsp easyeffects
    nmap
    wget
  ]);

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      DisplayBookmarksToolbar = "never";
      DNSOverHTTPS = {
        Enabled = false;
        ProviderURL = "https://mozilla.cloudflare-dns.com/dns-query";
        Locked = true;
      };
      languagePacks = [
        "ru" 
      ];

      Preferences = {
        "ui.key.menuAccessKeyFocuses" = lock-false;
        "signon.generation.enabled" = lock-false;
        "browser.compactmode.show" = lock-true;
        "browser.uidensity" = {
          Value = 1;
          Status = "Locked";
        };
        "mousewheel.with_alt.action" = {
          Value = "-1";
          Status = "Locked";
        };
        "browser.tabs.firefox-view" = lock-false;
        "browser.startup.homepage" = "https://ifconfig.me";
      };

      # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/17
      # about:debugging#/runtime/this-firefox
      ExtensionSettings = with builtins;
        let
          extension = shortId: uuid: { #for extensions from addons.mozilla
            name = uuid;
            value = {
              install_url =
                "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "normal_installed";
            };
          };
          extension_custom = link: uuid: { # for extensions from other sources
            name = uuid;
            value = {
              install_url =
                "${link}";
              installation_mode = "normal_installed";
            };
          };
        in listToAttrs [
          (extension_custom "https://tridactyl.cmcaine.co.uk/betas/tridactyl-latest.xpi" "{ec2a8a42-bef4-4036-96df-7f1423cf64ab}")
          (extension "ublock-origin" "uBlock0@raymondhill.net")
          (extension "container-proxy" "contaner-proxy@bekh-ivanov.me")
          (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
          (extension "darkreader" "addon@darkreader.org")
          (extension "firefox-color" "FirefoxColor@mozilla.com")
          (extension "multi-account-containers" "@testpilot-containers")
          (extension "jkcs" "{6d9f4f04-2499-4fed-ae4a-02c5658c5d00}")
          (extension "keepassxc-browser" "keepassxc-browser@keepassxc.org")
          (extension "new-window-without-toolbar"
            "new-window-without-toolbar@tkrkt.com")
          (extension "open-in-spotify-desktop"
            "{04a727ec-f366-4f19-84bc-14b41af73e4d}")
          (extension "search_by_image" "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}")
          (extension "single-file" "{531906d3-e22f-4a6c-a102-8057b88a1a63}")
          (extension "soundfixer" "soundfixer@unrelenting.technology")
          (extension "sponsorblock" "sponsorBlocker@ajay.app")
          (extension "tampermonkey" "firefox@tampermonkey.net")
          #(extension "torrent-control" "{e6e36c9a-8323-446c-b720-a176017e38ff}")
          (extension "unpaywall" "{f209234a-76f0-4735-9920-eb62507a54cd}")
          (extension "ctrl-number-to-switch-tabs" "{84601290-bec9-494a-b11c-1baa897a9683}")
          (extension "temporary-containers" "{c607c8df-14a7-4f28-894f-29e8722976af}")
        ];
    };
  };

  #programs.chromium = {
  #  enable = true;
  #  extensions = [
  #    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
  #  ];
  #};

  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  programs.virt-manager.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  
  programs.fish = {
    enable = true;
    
    shellAliases = {
      fru = "trans ru:en";
      fen = "trans en:ru";
      icat = "kitten icat";
    };
    shellInit = ''
      set -U __done_kitty_remote_control 1
      set -U __done_kitty_remote_control_password "kitty-notification-password-fish"
      set -U __done_notification_command "${pkgs.libnotify}/bin/notify-send --icon=kitty --app-name=kitty \$title \$argv[1]"
    '';
  };

  #programs.neovim = {
  #  enable = true;
  #  defaultEditor = true;
  #  configure = {
  #    customRC = ''
  #      :set mouse=a
  #    '';
  #  };
  #};

  programs.nixvim = {
    enable = true;
    plugins.lightline.enable = true;

    options= {

    };

  };

  
}
