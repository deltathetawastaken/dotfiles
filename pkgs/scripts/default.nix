{ config, pkgs, ... }: 
let
  # Helper function to create script binaries
  mkScriptBin = name: pkgs.writeScriptBin name (builtins.readFile ./${name}.sh);

  # List of script names
  scriptNames = [
    "fzfclipboard"
    "fzfmenuft"
    "swaylock"
  ];

  # Generate the script binaries
  scriptBins = map mkScriptBin scriptNames;

in {
  users.users.delta.packages = scriptBins;
}
