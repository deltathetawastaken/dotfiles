{ lib, pkgs, self, config, ... }:
let 
 greetdSessions = pkgs.writeText "sessions" ''
 Hyprland 2>&1 > /dev/null:gnome-shell --wayland:gnome-shell --x11
 '';
in 
{
  imports = [
    "${self}/pkgs/gnome.nix"
    "${self}/pkgs/hyprland"
  ];

  environment.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = lib.mkDefault "wayland";
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_SIZE = "";
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "foot";
    WLR_DRM_NO_MODIFIERS = 1; # fixes graphical glitches on amd laptop
  };

  environment.variables = lib.mkForce {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "foot";
  };

  security = {
    polkit.enable = true;
    pam.services.greetd.enableGnomeKeyring = true;
    rtkit.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # command = ''${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --cmd --cmd "Hyprland 2>&1 > /dev/null"'';
        command = ''${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --time --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --cmd "Hyprland 2>&1 > /dev/null"'';
        user = "greeter";
      };
      gnome_x11_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd gnome-shell --x11";
        user = "greeter";
      };
      gnome_wayland_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd gnome-shell --wayland";
        user = "greeter";
      };
    };
  };
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYHangup = true;
    TTYVTDisallocate = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    displayManager = {
      # gdm.enable = true;
      # autoLogin = {
      #   enable = false;
      #   user = "delta";
      # };
      # ly.enable = true;
    };
    desktopManager.gnome.enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = [ pkgs.xterm ];
  };
}
