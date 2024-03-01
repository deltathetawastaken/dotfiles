{ inputs, home, config, lib, ... }:

{

  dconf = {
    enable = true;
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
      };
      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = [ "<Shift><Super>s" ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Alt>Return";
        command = "/etc/profiles/per-user/delta/bin/kitty_wrapped";
        name = "kitty";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Control><Alt>x";
        command = "/etc/profiles/per-user/delta/bin/keepassxc";
        name = "keepassxc";
      };
      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
      };
      "org/gnome/mutter" = {
         experimental-features = [ "scale-monitor-framebuffer" ];
       };
      #"org/gnome/mutter" = {
      #  experimental-features = lib.mkForce [ ];
      #};
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-battery-timeout =
        300;
    };
  };
}
