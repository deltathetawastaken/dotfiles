{ pkgs, lib, ... }:

{
  programs.helix = {
    enable = true;

    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
    }];
    themes = {
      fleet_dark_transparent = {
        "inherits" = "fleet_dark";
        "ui.background" = { };
      };
    };

    settings = {
        theme = "fleet_dark_transparent";

        editor = {
          line-number = "relative";
          mouse = true;
          lsp.display-messages = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          file-picker.hidden = false;
        };

      keys.normal = {
      space.space = "file_picker";
      space.w = ":w";
      space.q = ":q";
      esc = [ "collapse_selection" "keep_primary_selection" ];
      C-f = [":new" ":insert-output lf -selection-path=/dev/stdout" "split_selection_on_newline" "goto_file" "goto_last_modification" "goto_last_modified_file" ":buffer-close!" ":redraw"];
      # C-d = [":new" ":insert-output /home/delta/scripts/temp/yazi-choser.sh -selection-path=/dev/stdout" "split_selection_on_newline" "goto_file" "goto_last_modification" "goto_last_modified_file" ":buffer-close!" ":redraw"];

      };
    };

    extraPackages = [ pkgs.marksman pkgs.nil pkgs.nodePackages.bash-language-server];
  };

  #programs.dircolors.enable = true;

  home.file.".config/yazi/filetree_config/yazi.toml".text = ''
    [manager]
    ratio = [ 0, 8, 0 ]
    [[manager.prepend_keymap]]
    on   = [ "l" ]
    run  = "plugin --sync smart-enter"
    desc = "Enter the child directory, or open the file"
  '';
  home.file.".config/yazi/filetree_config/plugins/smart-enter.yazi/init.lua".text = builtins.readFile ./init.lua;
}
