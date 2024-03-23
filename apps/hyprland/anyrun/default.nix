{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  
  home-manager.users.delta.imports = [
    inputs.anyrun.homeManagerModules.default
  ];

  home-manager.users.delta.programs.anyrun = {
    enable = true;

    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        #inputs.anyrun-nixos-options.packages.${pkgs.system}.default
        applications
        rink
        #shell
        symbols
        #translate
      ];

      width.fraction = 0.3;
      y.absolute = 15;
      hidePluginInfo = true;
      closeOnClick = true;
    };

    extraCss = ''
      @define-color bg-col  rgba(30, 30, 46, 0.7);
      @define-color bg-col-light rgba(150, 220, 235, 0.7);
      @define-color border-col rgba(30, 30, 46, 0.7);
      @define-color selected-col rgba(150, 205, 251, 0.7);
      @define-color fg-col #D9E0EE;
      @define-color fg-col2 #F28FAD;

      * {
        transition: 200ms ease;
        font-family: "Iosevka Nerd Font";
        font-size: 1.3rem;
      }

      #window {
        background: transparent;
      }

      #plugin,
      #main {
        border: 3px solid @border-col;
        color: @fg-col;
        background-color: @bg-col;
      }
      /* anyrun's input window - Text */
      #entry {
        color: @fg-col;
        background-color: @bg-col;
      }

      /* anyrun's ouput matches entries - Base */
      #match {
        color: @fg-col;
        background: @bg-col;
      }

      /* anyrun's selected entry - Red */
      #match:selected {
        color: @fg-col2;
        background: @selected-col;
      }

      #match {
        padding: 3px;
        border-radius: 3px;
      }

      #entry, #plugin:hover {
        border-radius: 3px;
      }

      box#main {
        background: rgba(30, 30, 46, 0.7);
        border: 1px solid @border-col;
        border-radius: 3px;
        padding: 5px;
      }
    '';


    extraConfigFiles."applications.ron".text = ''
      Config(
        desktop_actions: false,
        max_entries: 5,
        terminal: Some("footclient"),
      )
    '';

    extraConfigFiles."dictonary.ron".text = ''
      Config(
        prefix: ";",
        max_entries: 5,
      )
    '';
    extraConfigFiles."randr.ron".text = ''
      Config(
        prefix: ":dp",
        max_entries: 5, 
      )    
    '';

    extraConfigFiles."translate.ron".text = ''
      Config(
        prefix: ":",
        language_delimiter: ">",
        max_entries: 3,
      ) 
    '';
  };
}
