{ pkgs, lib, ... }:

{

  home.file.".config/hypr/shaders/extradark.glsl".text = builtins.readFile ./extradark.glsl;
  home.file.".config/hypr/shaders/noblue-light.glsl".text = builtins.readFile ./noblue-light.glsl;
  home.file.".config/hypr/shaders/noblue-smart.glsl".text = builtins.readFile ./noblue-smart.glsl;
  home.file.".config/hypr/shaders/noblue.glsl".text = builtins.readFile ./noblue.glsl;

}
