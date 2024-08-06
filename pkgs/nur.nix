{ pkgs, lib, inputs, stable, unstable, self, ... }:
let
  deluge-theme = pkgs.fetchurl {
    url = "https://github.com/joelacus/deluge-web-dark-theme/raw/main/deluge_web_dark_theme.tar.gz";
    sha256 = "sha256-5DFZjk76P9Gbz+v+mRi/qm8WtU+Go7qdmEOxlOptHDM="; # Replace with the actual hash
  };

  deluge-with-theme = pkgs.deluge-gtk.overrideAttrs (oldAttrs: rec {
    postInstall = oldAttrs.postInstall + ''
      tar -xzvf ${deluge-theme} -C $out/lib/python3.11/site-packages/deluge/ui/web/
      substituteInPlace $out/lib/python3.11/site-packages/deluge/ui/web/index.html \
        --replace '</head>' '<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1"></head>'
    '';
  });

in
{
  environment.systemPackages = with pkgs; [
    deluge-with-theme
  ];
}