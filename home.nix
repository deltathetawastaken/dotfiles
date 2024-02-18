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

  imports = [
    #hyprland.homeManagerModules.default
    #./environment
    ./programs
    #./scripts
    #./themes
  ];
	
  programs.vscode = {
    enable = true;
    package = unstable.vscodium;
  };

  home.packages = with pkgs; [
    git
	firefox
	rustdesk
	#unstable.firefox
	#unstable.curl
	#unstable.egl-wayland
	unstable.chromium
    unstable.foot
    wl-clipboard
    wl-clipboard-x11
    (callPackage ./audiorelay.nix {})
    (callPackage ./spotify.nix {})    

    (unstable.telegram-desktop.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        (fetchpatch {
          url = "https://raw.githubusercontent.com/Layerex/telegram-desktop-patches/master/0001-Disable-sponsored-messages.patch";
          hash = "sha256-o2Wxyag6hpEDgGm8FU4vs6aCpL9aekazKiNeZPLI9po=";
        })
        (fetchpatch {
          url = "https://raw.githubusercontent.com/Layerex/telegram-desktop-patches/master/0002-Disable-saving-restrictions.patch";
          hash = "sha256-sQsyXlvhXSvouPgzYSiRB8ieICo3GDXWH5MaZtBjtqw=";
        })
        (fetchpatch {
          url = "https://raw.githubusercontent.com/Layerex/telegram-desktop-patches/master/0003-Disable-invite-peeking-restrictions.patch";
          hash = "sha256-8mJD6LOjz11yfAdY4QPK/AUz9o5W3XdupXxy7kRrbC8="; 
        })
        (fetchpatch {
          url = "https://raw.githubusercontent.com/Layerex/telegram-desktop-patches/master/0004-Disable-accounts-limit.patch";
          hash = "sha256-PZWCFdGE/TTJ1auG1JXNpnTUko2rCWla6dYKaQNzreg=";
        })
      ];
    }))
  ];

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
 
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
    ];
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
    scripts = with pkgs; [ 
      mpvScripts.autoload
      mpvScripts.cutter
    ];
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
      rebuild = "sudo nixos-rebuild switch --flake ~/Documents/dotfiles/";
      rollback = "sudo nixos-rebuild switch --rollback --flake ~/Documents/dotfiles/";
      run = "~/.local/share/run";
    };
    shellInit = ''
      any-nix-shell fish --info-right | source
    '';
  };

#  wayland.windowManager.hyprland = { 
#  	enable = true;
#  	#plugins = 
#
#  };
  

  xdg.dataFile."run" = {
    enable = true;
    executable = true;
    text = ''
      #!/bin/sh
      if [[ $# -eq 0 ]]; then
        echo "Error: Missing argument."
      else
        nix run nixpkgs#"$1" -- "''\${@:2}"
      fi
    '';
  };
}
