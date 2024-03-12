{ unstable, inputs, config, pkgs, ... }:
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
    if [[ $# -eq 0 ]]; then
      echo "Error: Missing argument."
    else
      NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#"$1" -- "''${@:2}"
    fi
  '';
in {
  environment.sessionVariables = {
    FLAKE = "/home/delta/Documents/dotfiles";
  };

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
      ];
      trusted-public-keys = [ 
        "shwewo.cachix.org-1:84cIX7ETlqQwAWHBnd51cD4BeUVXCyGbFdtp+vLxKOo=" 
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s=" 
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  boot.kernel.sysctl."kernel.sysrq" = 1;

  environment.systemPackages = with pkgs; [ 
    run
    shell
    git
    micro
    nano
    fishPlugins.grc
    fishPlugins.autopair
    fishPlugins.z
    #fishPlugins.tide
    #fishPlugins.hydro
    fishPlugins.fzf-fish
    fishPlugins.sponge
    grc
    unstable.nh
    any-nix-shell
    dnsutils
    inetutils
    killall
  ];

  programs.command-not-found.enable = false;
  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "nh os switch";
      rollback = "sudo nixos-rebuild switch --rollback --flake ~/Documents/dotfiles/";
      haste = "HASTE_SERVER='https://haste.delch.workers.dev' ${pkgs.haste-client}/bin/haste";
    };
    promptInit = ''
      set TERM "xterm-256color"
      set fish_greeting
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source  
      #tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Few icons' --transient=No 
    '';
  };
  users.defaultUserShell = pkgs.fish;
  programs.tmux.enable = true;
}
