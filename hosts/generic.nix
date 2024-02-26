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
      nix shell nixpkgs#"$1" -- "''${@:2}"
    fi
  '';
in {
  environment.sessionVariables = {
    FLAKE = "/home/delta/Documents/dotfiles";
  };

  users.users.delta = {
    isNormalUser = true;
    description = "delta";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
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
    unstable.nh
    any-nix-shell
  ];

  programs.command-not-found.enable = false;
  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "nh os switch";
      rollback = "sudo nixos-rebuild switch --rollback --flake ~/Documents/dotfiles/";
      shell = "~/.local/share/shell";
    };
    promptInit = ''
      set TERM "xterm-256color"
      set fish_greeting
      any-nix-shell fish --info-right | source
    '';
  };
  users.defaultUserShell = pkgs.fish;
  programs.tmux.enable = true;
}
