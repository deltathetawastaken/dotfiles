{ unstable, inputs, config, pkgs, lib, ... }:
let
  run = pkgs.writeScriptBin "run" ''
    #!/usr/bin/env bash
    if [[ $# -eq 0 ]]; then
      echo "Error: Missing argument"
    else
      NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#"$1" -- "''${@:2}"
    fi
  '';
  shell = pkgs.writeScriptBin "shell" ''
    #!/usr/bin/env bash
      packages=""
      for package in "$@"; do
        packages+="nixpkgs#$package "
      done
      packages=$(echo "$packages" | xargs)

      NIXPKGS_ALLOW_UNFREE=1 .any-nix-wrapper fish --impure $packages
  '';
  fzf = pkgs.fzf.overrideAttrs (oldAttrs: rec {
    postInstall = oldAttrs.postInstall + ''
      # Remove shell integrations
      rm -rf $out/share/fzf $out/share/fish $out/bin/fzf-share
    '' + (builtins.replaceStrings
      [
        ''
          # Install shell integrations
          install -D shell/* -t $out/share/fzf/
          install -D shell/key-bindings.fish $out/share/fish/vendor_functions.d/fzf_key_bindings.fish
          mkdir -p $out/share/fish/vendor_conf.d
          cat << EOF > $out/share/fish/vendor_conf.d/load-fzf-key-bindings.fish
            status is-interactive; or exit 0
            fzf_key_bindings
          EOF
        ''
      ]
      [""]
      oldAttrs.postInstall);
  });
in {
  environment.sessionVariables = {
    FLAKE = "/home/delta/Documents/dotfiles";
    TELEPORT_LOGIN= "${inputs.secrets.work.tp-login}";
  };
  environment.variables.EDITOR = "hx";


  users.users.delta = {
    isNormalUser = true;
    description = "delta";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "adbusers" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGL2UD0frl9F2OPBiPlSQqxDsuACbAVgwH24F0KT14L"
    ];
  };

    nix = {
      settings = {
        experimental-features = [ "flakes" "nix-command" ];
        auto-optimise-store = true;
        substituters = [ 
          "https://shwewo.cachix.org" 
          "https://anyrun.cachix.org"
          "https://hyprland.cachix.org"
          # "https://nyx.chaotic.cx/"
        ];
        trusted-public-keys = [ 
          "shwewo.cachix.org-1:84cIX7ETlqQwAWHBnd51cD4BeUVXCyGbFdtp+vLxKOo=" 
          "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          # "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        ];
      };
      package = unstable.nixVersions.latest;
    };

  nixpkgs.config.allowUnfree = true;
  boot.kernel.sysctl."kernel.sysrq" = 1;

  environment.systemPackages = with pkgs; [ 
    run
    shell
    git
    helix micro
    fishPlugins.grc grc
    fishPlugins.autopair
    zoxide #better fishPlugins.z
    starship # my fish promt
    fishPlugins.sponge
    fishPlugins.fzf-fish
    fishPlugins.puffer
    bat  #for fzf-fish plugin 
    fzf  #for fzf-fish plugin
    fd   #for fzf-fish plugin
    sysz # systemctl with fzf
    nh
    any-nix-shell
    dnsutils
    inetutils
    killall
    tree
    eza # it's faster then lsd 
    htop
    btop
    nix-search-cli
    nix-index
    doggo #dig for dns-over-*
    (pkgs.writeScriptBin "reboot" ''read -p "Do you REALLY want to reboot? (y/N) " answer; [[ $answer == [Yy]* ]] && ${pkgs.systemd}/bin/reboot'')
  ];

  

  programs.command-not-found.enable = false;
  programs.fish = {
    enable = true;
    useBabelfish = true;
    shellAliases = {
      rebuild = "nh os switch";
      rollback = "sudo nixos-rebuild switch --rollback --flake ~/Documents/dotfiles/";
      haste = "HASTE_SERVER='https://haste.schizoposting.online' ${pkgs.haste-client}/bin/haste";
      ls = "${pkgs.eza}/bin/exa --icons";
      tre = "${pkgs.eza}/bin/exa --tree";
      itree = "${pkgs.eza}/bin/exa --icons --tree";
      search = "nix-search -d -m 5 -p";
      unpack = "aunpack";
      where = "which";
      c = "cd";
    };
    promptInit = ''
      set TERM "xterm-256color"
      set fish_greeting
      export STARSHIP_CONFIG=/etc/starship.toml
      ${pkgs.zoxide}/bin/zoxide init fish | source
      source (${pkgs.starship}/bin/starship init fish --print-full-init | psub)
      any-nix-shell fish --info-right | source
    '';
  };

  programs.tmux.enable = true;
  programs.direnv.enable = true;
  programs.firejail.enable = true;
  
  security.wrappers = {
    firejail = {
      source = "${pkgs.firejail.out}/bin/firejail";
    };
  };

  users.defaultUserShell = pkgs.fish;
  security.rtkit.enable = true;
  boot.tmp.cleanOnBoot = true;

  environment.etc."starship.toml".text = ''
  add_newline = false
  '';

  environment.etc."htoprc".text = ''
    config_reader_min_version=3
    fields=0 48 46 47 49 1
    hide_kernel_threads=1
    hide_userland_threads=1
    hide_running_in_container=0
    shadow_other_users=0
    show_thread_names=0
    show_program_path=0
    highlight_base_name=1
    highlight_deleted_exe=1
    shadow_distribution_path_prefix=0
    highlight_megabytes=1
    highlight_threads=1
    highlight_changes=0
    highlight_changes_delay_secs=5
    find_comm_in_cmdline=1
    strip_exe_from_cmdline=1
    show_merged_command=0
    header_margin=1
    screen_tabs=1
    detailed_cpu_time=0
    cpu_count_from_one=0
    show_cpu_usage=1
    show_cpu_frequency=1
    show_cpu_temperature=1
    degree_fahrenheit=0
    update_process_names=0
    account_guest_in_cpu_meter=0
    color_scheme=6
    enable_mouse=1
    delay=15
    hide_function_bar=1
    header_layout=two_50_50
    column_meters_0=LeftCPUs Memory Swap
    column_meter_modes_0=1 1 1
    column_meters_1=RightCPUs Tasks LoadAverage Uptime
    column_meter_modes_1=1 2 2 2
    tree_view=0
    sort_key=46
    tree_sort_key=0
    sort_direction=-1
    tree_sort_direction=1
    tree_view_always_by_pid=0
    all_branches_collapsed=0
    screen:Main=PID USER PERCENT_CPU PERCENT_MEM TIME Command
    .sort_key=PERCENT_CPU
    .tree_sort_key=PID
    .tree_view_always_by_pid=0
    .tree_view=0
    .sort_direction=-1
    .tree_sort_direction=1
    .all_branches_collapsed=0
    screen:I/O=PID USER IO_PRIORITY IO_RATE IO_READ_RATE IO_WRITE_RATE PERCENT_SWAP_DELAY PERCENT_IO_DELAY Command
    .sort_key=PID
    .tree_sort_key=PID
    .tree_view_always_by_pid=0
    .tree_view=0
    .sort_direction=1
    .tree_sort_direction=1
    .all_branches_collapsed=0
  '';
}
