{ inputs, config, pkgs, ... }: {
  imports = [
    inputs.nvchad4nix.homeManagerModule
  ];
  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      nixd
      nodePackages.bash-language-server
      # docker-compose-language-service
      # dockerfile-language-server-nodejs
      # emmet-language-server
      (python3.withPackages(ps: with ps; [
        python-lsp-server
        flake8
      ]))
      code-minimap
    ];
    extraConfig = ./extraConfig/mycfg;
    hm-activation = true;
    backup = false;
  };
}