{ pkgs, lib, inputs, unstable, ... }:
let
  gtk-theme = "adw-gtk3-dark";

  nerdfonts = (pkgs.nerdfonts.override {
    fonts = [
      #"Ubuntu"
      #"UbuntuMono"
      #"CascadiaCode"
      #"FantasqueSansMono"
      #"FiraCode"
      #"Mononoki"
      "Iosevka"
    ];
  });

  #cursor-theme = "Qogir";
  #cursor-package = pkgs.qogir-icon-theme;
in {
  home = {
    packages = with pkgs; [
      font-awesome
      whitesur-icon-theme
      colloid-icon-theme
      adw-gtk3
      nerdfonts
    ];
    #sessionVariables.XCURSOR_THEME = cursor-theme;
    #pointerCursor = {
    #  package = cursor-package;
    #  name = cursor-theme;
    #  size = 24;
    #  gtk.enable = true;
    #};
    file = {
      ".local/share/fonts" = {
        recursive = true;
        source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
      };
      ".fonts" = {
        recursive = true;
        source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
      };
      # ".config/gtk-4.0/gtk.css" = {
      #   text = ''
      #     window.messagedialog .response-area > button,
      #     window.dialog.message .dialog-action-area > button,
      #     .background.csd{
      #       border-radius: 0;
      #     }
      #   '';
      # };
    };
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    #font.name = "Iosevka Malie";
    #theme.name = gtk-theme;
    #cursorTheme = {
    #  name = cursor-theme;
    #  package = cursor-package;
    #};

    theme = {
      name = "Catppuccin-Mocha-Compact-Lavender-Dark";
      package = unstable.catppuccin-gtk.override {
        accents = [
          "lavender"
        ]; # You can specify multiple accents here to output multiple themes
        size = "compact";
        tweaks =
          [ "rimless" "black" ]; # You can also specify multiple tweaks here
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = lib.mkForce unstable.papirus-icon-theme;
    };
    gtk3.extraCss = ''
      headerbar, .titlebar,
      .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
        border-radius: 0;
      }
    '';
    gtk4.extraCss = ''
     window.messagedialog .response-area > button,
     window.dialog.message .dialog-action-area > button,
     .background.csd{
       border-radius: 0;
     }
    '';
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    #style.name = "kvantum-dark";
  };
}
