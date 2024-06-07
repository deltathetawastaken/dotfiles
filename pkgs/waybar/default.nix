{ pkgs, lib, ... }:

{
  home.file.".config/waybar/config.jsonc".text = builtins.readFile ./config-offline.jsonc;
  home.file.".config/waybar/style.css".text = builtins.readFile ./style.css;
  home.file.".config/waybar/mesu.jsonc".text = builtins.readFile ./mesu.jsonc;

}