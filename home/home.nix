{ lib, pkgs, ... }:
{
  home.username = "delta";
  home.stateVersion = "23.11";

  imports = [ 
    ./theme.nix
    ../pkgs/helix
    ../pkgs/yazi
    ../pkgs/waybar
  ];

  #services.blueman-applet.enable = true;
  #services.network-manager-applet.enable = true;
  programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        b4dm4n.vscode-nixpkgs-fmt
        usernamehw.errorlens
        eamodio.gitlens
        kamadorueda.alejandra
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.47.2";
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      }
      #{
      #  name = "popping-and-locking-vscode";
      #  publisher = "hedinne";
      #  version = "2.0.11";
      #  sha256 = "7ZH9l4jySPo1jMZnylTPK6o+XZnxUtrpYIiY9xVPuRw=";
      #}
      {
        name = "tokyo-night";
        publisher = "enkia";
        version = "1.0.6";
        sha256 = "sha256-VWdUAU6SC7/dNDIOJmSGuIeffbwmcfeGhuSDmUE7Dig=";
      }
      {
        name = "bracket-select";
        publisher = "chunsen";
        version = "2.0.2";
        sha256 = "sha256-2+42NJWAI0cz+RvmihO2v8J/ndAHvV3YqMExvnl46m4=";
      }
    ];
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      userSettings = {
        # "files.autoSave" = "onFocusChange";
        "window.titleBarStyle" = "custom";
        # "workbench.colorTheme" = "Popping and Locking";
        "workbench.colorTheme" = "Tokyo Night";
        "terminal.external.linuxExec" = "kitty";
        "editor.guides.bracketPairs" = "active";
        "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
        "editor.fontFamily" = "'FiraCode Nerd Font'";
        "editor.fontLigatures" = "'ss01', 'ss02', 'ss06', 'ss08',  'cv14', 'cv04' , 'tnum'";
        "editor.fontWeight" = "450";
        "nix.enableLanguageServer"= true;
        #"nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.serverSettings" = {
          #nil = {
          #  formatting = {
          #    command = [ "${pkgs.alejandra}/bin/alejandra" ];
          #  };
          #};
        };
        "alejandra.program" = "${pkgs.alejandra}/bin/alejandra";
        "[nix]" = {
           "editor.defaultFormatter" = "kamadorueda.alejandra";
           "editor.formatOnPaste" = false;
           "editor.formatOnSave" = false;
           "editor.formatOnType" = false;
        };
        "nixfmt.path" = "${pkgs.alejandra}/bin/alejandra"; #alejandra addon is broken so i just use nixfmt addon with alejandra lol
        "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
      };
    };
  
  home.activation = {
    copy_unlink = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      [ ! -e /home/delta/.config/Code/User/settings.json ] || unlink /home/delta/.config/Code/User/settings.json
    '';  #create RW vscode settings so all hotkeys work (wrap_lines and etc)
    copy_unlink2 = lib.hm.dag.entryAfter ["onFilesChange"] ''
      rm -f /home/delta/.config/Code/User/settings.json.rw
      cp -f /home/delta/.config/Code/User/settings.json /home/delta/.config/Code/User/settings.json.rw
      ln -sf /home/delta/.config/Code/User/settings.json.rw /home/delta/.config/Code/User/settings.json
      chmod +rw /home/delta/.config/Code/User/settings.json.rw
    '';
    hypr_copy_unlink = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      [ ! -e /home/delta/.config/hypr/hyprland.conf ] || unlink /home/delta/.config/hypr/hyprland.conf
    '';  #create RW hyprland config so i can change settings without rebuild (maybe move monitor defenitions to a separate file instead?)
    hypr_link_copy = lib.hm.dag.entryAfter ["onFilesChange"] ''
      ln -sf /home/delta/Documents/dotfiles/pkgs/hyprland/hypr/hyprland.conf /home/delta/.config/hypr/hyprland.conf
    '';  
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
    # shellIntegration.enableFishIntegration = false;
    settings = {
      background = "#171717";
      foreground = "#DCDCCC";
      background_opacity = "0.8";
      remember_window_size = "no";
      hide_window_decorations = "yes";
      remote_control_password = "kitty-notification-password-fish ls, kitty-password-scripts ls set-tab-* resize-* send-text";
      allow_remote_control = "password";
      font_family= "FiraCode";
      font_features = "FiraCode +ss01 +ss02 +ss06 +ss08 +cv14 +cv03 +tnum";

      repaint_delay = 8; #comment out if flickers
      input_delay = 0;
      sync_to_monitor = "no";

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
    package = pkgs.brave.override {
      vulkanSupport = true;
    };
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
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      #{
      #  id = "aaaaaaaaaabbbbbbbbbbcccccccccc";
      #  crxPath = "/home/share/extension.crx";
      #  version = "1.0";
      #}
    ];
  };

  home.file.".config/btop/btop.conf".text = ''
    #? Config file for btop v. 1.3.2

    #* Name of a btop++/bpytop/bashtop formatted ".theme" file, "Default" and "TTY" for builtin themes.
    #* Themes should be placed in "../share/btop/themes" relative to binary or "$HOME/.config/btop/themes"
    color_theme = "adapta"

    #* If the theme set background should be shown, set to False if you want terminal background transparency.
    theme_background = True

    #* Sets if 24-bit truecolor should be used, will convert 24-bit colors to 256 color (6x6x6 color cube) if false.
    truecolor = True

    #* Set to true to force tty mode regardless if a real tty has been detected or not.
    #* Will force 16-color mode and TTY theme, set all graph symbols to "tty" and swap out other non tty friendly symbols.
    force_tty = False

    #* Define presets for the layout of the boxes. Preset 0 is always all boxes shown with default settings. Max 9 presets.
    #* Format: "box_name:P:G,box_name:P:G" P=(0 or 1) for alternate positions, G=graph symbol to use for box.
    #* Use whitespace " " as separator between different presets.
    #* Example: "cpu:0:default,mem:0:tty,proc:1:default cpu:0:braille,proc:0:tty"
    presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty"

    #* Set to True to enable "h,j,k,l,g,G" keys for directional control in lists.
    #* Conflicting keys for h:"help" and k:"kill" is accessible while holding shift.
    vim_keys = False

    #* Rounded corners on boxes, is ignored if TTY mode is ON.
    rounded_corners = True

    #* Default symbols to use for graph creation, "braille", "block" or "tty".
    #* "braille" offers the highest resolution but might not be included in all fonts.
    #* "block" has half the resolution of braille but uses more common characters.
    #* "tty" uses only 3 different symbols but will work with most fonts and should work in a real TTY.
    #* Note that "tty" only has half the horizontal resolution of the other two, so will show a shorter historical view.
    graph_symbol = "braille"

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_cpu = "default"

    # Graph symbol to use for graphs in gpu box, "default", "braille", "block" or "tty".
    graph_symbol_gpu = "default"

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_mem = "default"

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_net = "default"

    # Graph symbol to use for graphs in cpu box, "default", "braille", "block" or "tty".
    graph_symbol_proc = "default"

    #* Manually set which boxes to show. Available values are "cpu mem net proc" and "gpu0" through "gpu5", separate values with whitespace.
    shown_boxes = "cpu mem net proc"

    #* Update time in milliseconds, recommended 2000 ms or above for better sample times for graphs.
    update_ms = 100

    #* Processes sorting, "pid" "program" "arguments" "threads" "user" "memory" "cpu lazy" "cpu direct",
    #* "cpu lazy" sorts top process over time (easier to follow), "cpu direct" updates top process directly.
    proc_sorting = "cpu lazy"

    #* Reverse sorting order, True or False.
    proc_reversed = False

    #* Show processes as a tree.
    proc_tree = False

    #* Use the cpu graph colors in the process list.
    proc_colors = True

    #* Use a darkening gradient in the process list.
    proc_gradient = True

    #* If process cpu usage should be of the core it's running on or usage of the total available cpu power.
    proc_per_core = False

    #* Show process memory as bytes instead of percent.
    proc_mem_bytes = True

    #* Show cpu graph for each process.
    proc_cpu_graphs = True

    #* Use /proc/[pid]/smaps for memory information in the process info box (very slow but more accurate)
    proc_info_smaps = False

    #* Show proc box on left side of screen instead of right.
    proc_left = False

    #* (Linux) Filter processes tied to the Linux kernel(similar behavior to htop).
    proc_filter_kernel = False

    #* In tree-view, always accumulate child process resources in the parent process.
    proc_aggregate = False

    #* Sets the CPU stat shown in upper half of the CPU graph, "total" is always available.
    #* Select from a list of detected attributes from the options menu.
    cpu_graph_upper = "Auto"

    #* Sets the CPU stat shown in lower half of the CPU graph, "total" is always available.
    #* Select from a list of detected attributes from the options menu.
    cpu_graph_lower = "iowait"

    #* If gpu info should be shown in the cpu box. Available values = "Auto", "On" and "Off".
    show_gpu_info = "Auto"

    #* Toggles if the lower CPU graph should be inverted.
    cpu_invert_lower = True

    #* Set to True to completely disable the lower CPU graph.
    cpu_single_graph = False

    #* Show cpu box at bottom of screen instead of top.
    cpu_bottom = False

    #* Shows the system uptime in the CPU box.
    show_uptime = True

    #* Show cpu temperature.
    check_temp = True

    #* Which sensor to use for cpu temperature, use options menu to select from list of available sensors.
    cpu_sensor = "Auto"

    #* Show temperatures for cpu cores also if check_temp is True and sensors has been found.
    show_coretemp = True

    #* Set a custom mapping between core and coretemp, can be needed on certain cpus to get correct temperature for correct core.
    #* Use lm-sensors or similar to see which cores are reporting temperatures on your machine.
    #* Format "x:y" x=core with wrong temp, y=core with correct temp, use space as separator between multiple entries.
    #* Example: "4:0 5:1 6:3"
    cpu_core_map = ""

    #* Which temperature scale to use, available values: "celsius", "fahrenheit", "kelvin" and "rankine".
    temp_scale = "celsius"

    #* Use base 10 for bits/bytes sizes, KB = 1000 instead of KiB = 1024.
    base_10_sizes = False

    #* Show CPU frequency.
    show_cpu_freq = True

    #* Draw a clock at top of screen, formatting according to strftime, empty string to disable.
    #* Special formatting: /host = hostname | /user = username | /uptime = system uptime
    clock_format = "%X"

    #* Update main ui in background when menus are showing, set this to false if the menus is flickering too much for comfort.
    background_update = True

    #* Custom cpu model name, empty string to disable.
    custom_cpu_name = ""

    #* Optional filter for shown disks, should be full path of a mountpoint, separate multiple values with whitespace " ".
    #* Begin line with "exclude=" to change to exclude filter, otherwise defaults to "most include" filter. Example: disks_filter="exclude=/boot /home/user".
    disks_filter = ""

    #* Show graphs instead of meters for memory values.
    mem_graphs = True

    #* Show mem box below net box instead of above.
    mem_below_net = False

    #* Count ZFS ARC in cached and available memory.
    zfs_arc_cached = True

    #* If swap memory should be shown in memory box.
    show_swap = True

    #* Show swap as a disk, ignores show_swap value above, inserts itself after first disk.
    swap_disk = True

    #* If mem box should be split to also show disks info.
    show_disks = True

    #* Filter out non physical disks. Set this to False to include network disks, RAM disks and similar.
    only_physical = True

    #* Read disks list from /etc/fstab. This also disables only_physical.
    use_fstab = True

    #* Setting this to True will hide all datasets, and only show ZFS pools. (IO stats will be calculated per-pool)
    zfs_hide_datasets = False

    #* Set to true to show available disk space for privileged users.
    disk_free_priv = False

    #* Toggles if io activity % (disk busy time) should be shown in regular disk usage view.
    show_io_stat = True

    #* Toggles io mode for disks, showing big graphs for disk read/write speeds.
    io_mode = False

    #* Set to True to show combined read/write io graphs in io mode.
    io_graph_combined = False

    #* Set the top speed for the io graphs in MiB/s (100 by default), use format "mountpoint:speed" separate disks with whitespace " ".
    #* Example: "/mnt/media:100 /:20 /boot:1".
    io_graph_speeds = ""

    #* Set fixed values for network graphs in Mebibits. Is only used if net_auto is also set to False.
    net_download = 100

    net_upload = 100

    #* Use network graphs auto rescaling mode, ignores any values set above and rescales down to 10 Kibibytes at the lowest.
    net_auto = True

    #* Sync the auto scaling for download and upload to whichever currently has the highest scale.
    net_sync = True

    #* Starts with the Network Interface specified here.
    net_iface = ""

    #* Show battery stats in top right if battery is present.
    show_battery = True

    #* Which battery to use if multiple are present. "Auto" for auto detection.
    selected_battery = "Auto"

    #* Show power stats of battery next to charge indicator.
    show_battery_watts = True

    #* Set loglevel for "~/.config/btop/btop.log" levels are: "ERROR" "WARNING" "INFO" "DEBUG".
    #* The level set includes all lower levels, i.e. "DEBUG" will show all logging info.
    log_level = "WARNING"

    #* Measure PCIe throughput on NVIDIA cards, may impact performance on certain cards.
    nvml_measure_pcie_speeds = True

    #* Horizontally mirror the GPU graph.
    gpu_mirror_graph = True

    #* Custom gpu0 model name, empty string to disable.
    custom_gpu_name0 = ""

    #* Custom gpu1 model name, empty string to disable.
    custom_gpu_name1 = ""

    #* Custom gpu2 model name, empty string to disable.
    custom_gpu_name2 = ""

    #* Custom gpu3 model name, empty string to disable.
    custom_gpu_name3 = ""

    #* Custom gpu4 model name, empty string to disable.
    custom_gpu_name4 = ""

    #* Custom gpu5 model name, empty string to disable.
    custom_gpu_name5 = ""
  '';

}
