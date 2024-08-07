{ config, pkgs, ... }: 
let
  # Helper function to create script binaries
  mkScriptBin = name: pkgs.writeScriptBin name (builtins.readFile ./${name}.sh);

  # List of script names
  scriptNames = [
    "fzfclipboard"
    "fzfmenuft"
    "swaylocksh"
    "hyprshade"
    "bluetoothcharge"
    "brightness"
    "volume" #TODO: remove absolute path from scripts using nix
    "powermenu"
  ];

  # Generate the script binaries
  scriptBins = map mkScriptBin scriptNames;

in {
  users.users.delta.packages = scriptBins;
}
