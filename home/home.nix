{ stable, unstable, inputs, home, config, lib, pkgs, specialArgs, ... }:
{
  home.username = "delta";
  home.stateVersion = "23.11";

  imports = [ 
    ./theme.nix
  ];

  #services.blueman-applet.enable = true;
  #services.network-manager-applet.enable = true;
  programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      
      extensions = with pkgs.vscode-extensions; [
        matklad.rust-analyzer
        jnoortheen.nix-ide
      ];
      enableUpdateCheck = false;
      userSettings = {
        "window.titleBarStyle" = "custom";
        "nix.enableLanguageServer"= true;
        #"nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.serverSettings" = {
          nil = {
            formatting = {
              command = [ "${pkgs.alejandra}/bin/alejandra" ];
            };
          };
        };
      };
    };

  programs.git = {
    enable = true;
    userName  = "delta";
    userEmail = "delta@example.com";
  };

  #xdg.desktopEntries = {
  #  maestral = {
  #    name = "Maestral";
  #    icon = "maestral";
  #    exec =
  #      ''sh -c "QT_QPA_PLATFORM=xcb ${pkgs.maestral-gui}/bin/maestral_qt"'';
  #    type = "Application";
  #  };
  #};


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

  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    #"ifconfig.co/json"
    commandLineArgs = [
      "--ignore-gpu-blocklist"
      "--disable-gpu-driver-bug-workarounds"
      #"--use-gl=egl"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization,UseOzonePlatform"
      #"--disable-features=UseChromeOSDirectVideoDecoder"
      #"--use-angle=vulkan"
      #"--enable-unsafe-webgpu"
      "--enable-features=Vulkan"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      {
        id = "dcpihecpambacapedldabdbpakmachpb"; # bypasss paywalls
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml";
      }
      #{
      #  id = "aaaaaaaaaabbbbbbbbbbcccccccccc";
      #  crxPath = "/home/share/extension.crx";
      #  version = "1.0";
      #}
    ];
  };

  programs.helix = {
    enable = true;

    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
    }];
    themes = {
      fleet_dark_transparent = {
        "inherits" = "fleet_dark";
        "ui.background" = { };
      };
    };

    settings = {
        theme = "fleet_dark_transparent";

        editor = {
          line-number = "relative";
          mouse = true;
          lsp.display-messages = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          file-picker.hidden = false;
        };

      keys.normal = {
      space.space = "file_picker";
      space.w = ":w";
      space.q = ":q";
      esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };

  #programs.dircolors.enable = true;
}
