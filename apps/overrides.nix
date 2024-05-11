{ pkgs, lib, inputs, stable, unstable, self, ... }:
let
vesktopDesktopItem = pkgs.makeDesktopItem {
    name = "vesktop";
    desktopName = "Discord";
    exec = "vesktop %U";
    icon = "discord";
    startupWMClass = "Vesktop";
    genericName = "Internet Messenger";
    keywords = [ "discord" "vencord" "electron" "chat" ];
    categories = [ "Network" "InstantMessaging" "Chat" ];
  };

in {
  diosevka = unstable.iosevka.override {
    privateBuildPlan = ''
      [buildPlans.IosevkaDiosevka]
      family = "Iosevka Diosevka"
      spacing = "quasi-proportional"
      serifs = "sans"
      noCvSs = true
      exportGlyphNames = true

      [buildPlans.IosevkaDiosevka.variants.design]
      capital-i = "short-serifed"
      capital-l = "serifless"
      capital-m = "hanging-serifless"
      capital-q = "crossing"
      capital-v = "straight-serifless"
      capital-w = "straight-serifless"
      e = "flat-crossbar"
      f = "flat-hook-serifless"
      i = "hooky"
      j = "flat-hook-serifless"
      l = "flat-tailed"
      r = "serifless"
      t = "flat-hook"
      w = "straight-flat-top-serifless"
      long-s = "flat-hook-tailed-middle-serifed"
      eszet = "longs-s-lig-bottom-serifed"
      capital-delta = "straight"
      lower-iota = "serifed-flat-tailed"
      lower-tau = "flat-tailed"
      cyrl-el = "straight"
      cyrl-em = "hanging-serifless"
      cyrl-en = "serifless"
      one = "no-base"
      two = "straight-neck-serifless"
      four = "semi-open-serifless"
      nine = "straight-bar"
      tilde = "low"
      asterisk = "penta-low"
      ascii-single-quote = "straight"
      paren = "flat-arc"
      brace = "curly"
      at = "compact"
      dollar = "interrupted"
      cent = "bar-interrupted"
      percent = "rings-continuous-slash"
      lig-equal-chain = "with-notch"

      [buildPlans.IosevkaDiosevka.variants.italic]
      f = "flat-hook-tailed"
      i = "serifed-flat-tailed"
      l = "serifed-flat-tailed"
      w = "straight-flat-top-motion-serifed"
      long-s = "flat-hook-tailed"
      eszet = "longs-s-lig-tailed-serifless"

      [buildPlans.IosevkaDiosevka.weights.Regular]
      shape = 400
      menu = 400
      css = 400

      [buildPlans.IosevkaDiosevka.weights.Bold]
      shape = 700
      menu = 700
      css = 700

      [buildPlans.IosevkaDiosevka.widths.Normal]
      shape = 500
      menu = 5
      css = "normal"
    '';
    set = "Diosevka"; 
  };

  # iosevka-comfy = pkgs.iosevka.overrideAttrs rec { 
  #           privateBuildPlan = builtins.readFile ./iosevka-comfy.toml; 
  #           set = "comfy-duo"; 
  #         };

  vesktop = (pkgs.symlinkJoin {
      name = "vesktop";
      paths = [ (unstable.vesktop.override { 
        electron = unstable.electron; 
        withSystemVencord = false; 
      }) ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        mkdir -p $out/share/applications
        ln -sf ${vesktopDesktopItem}/share/applications/* $out/share/applications
      '';
    });

  input-font = pkgs.callPackage ../derivations/input-font.nix { url = inputs.secrets.home.input-font.domain; };




}