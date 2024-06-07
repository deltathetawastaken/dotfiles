{ pkgs, lib, inputs, stable, unstable, self, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  shwewo = inputs.shwewo.packages.${pkgs.system};
  overrides = import ./overrides.nix { 
    inherit inputs pkgs lib self stable unstable; 
  };
in {
  imports = [
    inputs.nixvim.nixosModules.nixvim
  ];

  #nixpkgs.overlays = [
  #  (self: super: {
  #    qt6 = super.qt6 // {
  #      qtwayland = super.qt6.qtwayland.overrideAttrs (oldAttrs: {
  #        patches = (oldAttrs.patches or []) ++ [
  #          ./patches/0004-fix-gtk4-embedding.patch
  #        ];
  #      });
  #    };
  #  }
  #  )
  #];

  users.users.delta.packages = (with pkgs; [
    alejandra
    pre-commit
    gitleaks
    git
    #chromium
    wl-clipboard
    wl-clipboard-x11
    #(callPackage ../derivations/nu_plugin_dns.nix { })
    (fishPlugins.callPackage ../derivations/fish/fish-functions.nix { })
    (callPackage ../derivations/opera-proxy.nix { })
    (callPackage ../derivations/hyprdrop/hyprdrop.nix { })
    xorg.xwininfo
    jq
    dropbox
    spotdl
    # xfce.thunar
    (pkgs.xfce.thunar.override { thunarPlugins = [pkgs.xfce.thunar-archive-plugin]; })
    #rustdesk-flutter
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
    localsend
    trayscale
    fishPlugins.done
    monero-gui
    translate-shell
    # tridactyl-native #firefox tridactyl addon
    ripgrep gh
    lexend # font from google (non-mono)
    ibm-plex
    fira-code
    iosevka-comfy.comfy
    # iosevka-comfy.comfy-duo
    iosevka-comfy.comfy-wide
    iosevka-comfy.comfy-wide-duo
    # iosevka-comfy.comfy-motion-duo
    jamesdsp easyeffects
    nmap
    wget
    shwewo.ephemeralbrowser
    shwewo.ruchrome
    shwewo.spotify
    #(pkgs.symlinkJoin {
    #  name = "ExprSelect";
    #  paths = [ shwewo.spotify ];
    #  buildInputs = [ pkgs.makeWrapper ];
    #  postBuild = ''
    #    wrapProgram $out/bin/spotify --set NIXOS_OZONE_WL 0
    #  '';
    #})
    shwewo.audiorelay
    # shwewo.tdesktop
    # _64gram 
    (pkgs.writeScriptBin "tlp" ''/run/wrappers/bin/sudo ${pkgs.tlp}/bin/tlp $@'')
    prismlauncher
    stable.teleport_12 #work
    tlrc #tldr
    boxbuddy
    stable.distrobox
    atool #unarchive
    open-interpreter
    overrides.diosevka
    # iosevka-bin
    # overrides.iosevka-comfy
    overrides.vesktop
    # overrides.input-font
    # overrides.input-fonts
    stable.peazip
    element-desktop
    qrtool
    appimage-run
    trayscale
    lf
    (pkgs.writeScriptBin "reboot" ''read -p "Do you REALLY want to reboot? (y/N) " answer; [[ $answer == [Yy]* ]] && ${pkgs.systemd}/bin/reboot'')
  ]);

  programs.firefox = {
    enable = true;
    package = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin;
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
        "browser.startup.homepage" = "about:blank";
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
          (extension "new-window-without-toolbar" "new-window-without-toolbar@tkrkt.com")
          (extension "open-in-spotify-desktop" "{04a727ec-f366-4f19-84bc-14b41af73e4d}")
          (extension "search_by_image" "{2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c}")
          (extension "single-file" "{531906d3-e22f-4a6c-a102-8057b88a1a63}")
          (extension "soundfixer" "soundfixer@unrelenting.technology")
          (extension "sponsorblock" "sponsorBlocker@ajay.app")
          (extension "tampermonkey" "firefox@tampermonkey.net")
          #(extension "torrent-control" "{e6e36c9a-8323-446c-b720-a176017e38ff}")
          (extension "unpaywall" "{f209234a-76f0-4735-9920-eb62507a54cd}")
          (extension "ctrl-number-to-switch-tabs" "{84601290-bec9-494a-b11c-1baa897a9683}")
          (extension "temporary-containers" "{c607c8df-14a7-4f28-894f-29e8722976af}")
          (extension "sidebery" "{609f7ec1-8818-4aa3-87ed-f40c1749e4d3}")
        ];
    };
  };

  #programs.chromium = {
  #  enable = true;
  #  extensions = [
  #    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
  #  ];
  #};

  programs.xfconf.enable = true;
  programs.virt-manager.enable = true;
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.noisetorch.enable = true;
  programs.gamemode.enable = true;
  programs.thunar.enable = true;
  # programs.thunar.plugins = with pkgs.xfce; [
  #   thunar-archive-plugin
  #   thunar-volman
  # ];
  
  programs.fish = {
    enable = true;
    
    shellAliases = {
      fru = "trans ru:en";
      fen = "trans en:ru";
      icat = "kitten icat";
    };
    interactiveShellInit = ''
      set -U __done_kitty_remote_control 1
      set -U __done_kitty_remote_control_password "kitty-notification-password-fish"
      set -U __done_notification_command "${pkgs.libnotify}/bin/notify-send --icon=kitty --app-name=kitty \$title \$argv[1]"

      function last_file_in_downloads
        echo "\"$(find ~/Downloads -type f -printf "%C@:%p\n" -not -regex ".*Downloads/torrent_incomplete/.*" -not -regex ".*Downloads/torrent/.*" | sort -rn | head -n 1 | cut -d ':' -f2-)\""
      end

      abbr -a --position anywhere lfd --function last_file_in_downloads

      function copy_clipboard
        echo '| wl-copy'
      end

      abbr -a --position anywhere CC --function copy_clipboard

      abbr -a --position command ya yazi
      abbr -a --position command ttlfix TTLfix
      abbr -a --position command syspend systemctl suspend
      abbr -a --position command suspend systemctl suspend
      abbr -- - 'cd -'
      abbr cdd 'cd ~/Downloads'


      function __pick_file
        fd --type f | fzf --ansi --disabled --query "$INITIAL_QUERY" \
            --bind "start:reload:$RG_PREFIX {q}" \
            --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            | tr ':' '\n' | head -n1
      end
      abbr -a !f --position command --function __pick_file

      function __pick_dir
        fd --type d | fzf
      end
      abbr -a !d --position command --function __pick_dir

      function last_history_item; echo $history[1]; end
      abbr -a !! --position anywhere --function last_history_item

      function __pick_grep
        set RG_PREFIX "rg --column --line-number --no-heading --color=always --smart-case"
        true | fzf --ansi --disabled --query "$INITIAL_QUERY" \
            --bind "start:reload:$RG_PREFIX {q}" \
            --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            | tr ':' '\n' | head -n1
      end
      abbr -a !g --position anywhere --function __pick_grep

      function range_expansion
          set -l value (string match --all --regex "\w*" $argv | string split ' ' --no-empty)
          set -l word_before_value
          set -l from_value
          set -l to_value

          math $value[1] &>/dev/null
          if test $status -ne 0
              # if first value is string
              set word_before_value $value[1]
              set from_value $value[2]
              set to_value $value[3]
          else
              # if first value is integer
              set from_value $value[1]
              set to_value $value[2]
          end

          echo "$word_before_value(seq $from_value $to_value)"
      end
      abbr --add range_expand_abbr --position anywhere --regex "\w*\{\d+\.\.\d+\}" --function range_expansion

      function copy_command_to_clipboard
          set -l current_command (commandline -b | string trim)
          printf "%s" $current_command | wl-copy
      end
      
      # Bind the function to Alt+R
      bind \er copy_command_to_clipboard
    '';
  };

  programs.yazi = {
    enable = true;
  };

  programs.nixvim = {
    enable = true;
    enableMan = false;
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        transparent = true
        ;
      };
    };
    globals.mapleader = ",";
    keymaps = [
      {
        key = ";";
        action = ":";
      }
      {
        key = "<leader>gg";
        action = "<cmd>Man<CR>";
        options = {
          silent = true;
          remap = false;
        };
      }
    ];
    plugins = {
      lightline = {
        enable = true;
        active = {
          left = [
            [
              "mode"
              "paste"
            ]
            [
              "readonly"
              "filename"
              "modified"
            ]
          ];
        };
      };
      which-key.enable = true;
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          nixd.enable = true;
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
        };
      };
      none-ls = {
        enable = true;
        sources = {
          diagnostics = {
            statix.enable = true;
          };
          formatting = {
            nixfmt.enable = true;
            markdownlint.enable = true;
            shellharden.enable = true;
            shfmt.enable = true;
          };
        };
      };
      nvim-tree = {
        enable = true;
        openOnSetupFile = true;
        autoReloadOnWrite = true;
      };
      lsp-lines = {
        enable = true;
        currentLine = true;
      };
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";

          "<C-p>" = {
            action = "git_files";
            options = {
              desc = "Telescope Git Files";
            };
          };
        };
        extensions.fzf-native = { enable = true; };
      };
      toggleterm = {
      enable = true;
        settings = {
          open_mapping = "[[<C-t>]]";

        };
      };
      
      treesitter = {
        enable = true;
        nixGrammars = true;
        indent = true;
      };
      treesitter-context.enable = true;
      rainbow-delimiters.enable = true;
      
      trouble.enable = true;
      wilder = {
        enable = true;
        modes = [ ":" "/" "?" ];
        renderer = "pumblend";
      };
      nvim-autopairs.enable = true;
    };

    options= {
      updatetime = 100; # Faster completion

      number = true;
      relativenumber = true;

      autoindent = true;
      # clipboard = "unnamedplus";
      clipboard = "unnamed,unnamedplus";
      expandtab = true;
      shiftwidth = 2;
      smartindent = true;
      tabstop = 2;

      ignorecase = true;
      incsearch = true;
      smartcase = true;
      wildmode = "list:longest";

      # swapfile = false;
      undofile = true; # Build-in persistent undo

      mouse = "a";

    };

  };

  
}
