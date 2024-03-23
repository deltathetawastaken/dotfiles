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
    fishPlugins.tide
    fishPlugins.fzf-fish
    fishPlugins.sponge
    fd
    fzf #(pkgs.writeScriptBin "fzf" "${pkgs.fzf}/bin/fzf $@")
    sysz # systemctl with fzf
    grc
    bat
    nh
    any-nix-shell
    dnsutils
    inetutils
    killall
    (pkgs.writeScriptBin "reboot" ''read -p "Do you REALLY want to reboot? (y/N) " answer; [[ $answer == [Yy]* ]] && ${pkgs.systemd}/bin/reboot'')
  ];

  programs.command-not-found.enable = false;
  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "nh os switch";
      rollback = "sudo nixos-rebuild switch --rollback --flake ~/Documents/dotfiles/";
      haste = "HASTE_SERVER='https://haste.schizoposting.online' ${pkgs.haste-client}/bin/haste";
    };
    promptInit = ''
      set TERM "xterm-256color"
      set fish_greeting
      #${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      any-nix-shell fish --info-right | source 
      tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Few icons' --transient=No
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
}
