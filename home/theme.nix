{ pkgs, lib, stable, unstable, ... }:
let
  gtk-theme = "adw-gtk3-dark";
  cursor-package = pkgs.bibata-cursors;
  cursor-theme = "Bibata-Modern-Classic";

  nerdfonts = (pkgs.nerdfonts.override {
    fonts = [
      #"Ubuntu"
      #"UbuntuMono"
      #"CascadiaCode"
      #"FantasqueSansMono"
      "FiraCode"
      #"Mononoki"
      "Iosevka"
      "IBMPlexMono"
      "NerdFontsSymbolsOnly"
    ];
  });
in {
  home = {
    packages = with pkgs; [
      font-awesome
      whitesur-icon-theme
      colloid-icon-theme
      adw-gtk3
      nerdfonts
    ];
  sessionVariables.XCURSOR_THEME = cursor-theme;
  pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = cursor-package;
    name = cursor-theme;
    # size = 16;
  };
    file = {
      ".local/share/fonts" = {
        recursive = true;
        source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
      };
      ".fonts" = {
        recursive = true;
        source = "${nerdfonts}/share/fonts/truetype/NerdFonts";
      };
    };
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    #font.name = "Iosevka Malie";
    cursorTheme = {
      name = cursor-theme;
      package = cursor-package;
    };

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
      # name = "Papirus";
      package = lib.mkForce stable.papirus-icon-theme;
    };
    # gtk3.extraCss = ''
    #   headerbar, .titlebar,
    #   .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
    #     border-radius: 0;
    #   }
    #   /* UNITE windowDecorations */
    #   @import url('/run/current-system/sw/share/gnome-shell/extensions/unite@hardpixel.eu/styles/gtk3/buttons-right/maximized.css');
    #   /* windowDecorations UNITE */
    #   headerbar, .titlebar,
    #   .csd:not(.popup):not(tooltip):not(messagedialog) decoration{
    #     border-radius: 0;
    #   }
    # '';
    # gtk4.extraCss = ''
    #  window.messagedialog .response-area > button,
    #  window.dialog.message .dialog-action-area > button,
    #  .background.csd{
    #    border-radius: 0;
    #  }
    #  /* UNITE windowDecorations */
    #  @import url('/run/current-system/sw/share/gnome-shell/extensions/unite@hardpixel.eu/styles/gtk4/buttons-right/maximized.css');
    #  /* windowDecorations UNITE */
    #  window.messagedialog .response-area > button,
    #  window.dialog.message .dialog-action-area > button,
    #  .background.csd{
    #    border-radius: 0;
    #  }
    # '';
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    #style.name = "kvantum-dark";
  };
}
