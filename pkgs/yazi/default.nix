{
  pkgs,
  lib,
  ...
}: {
  programs.yazi = {
    enable = true;
    # enableFishIntegration = true;
  };
  home.file.".config/yazi/yazi.toml".text = ''
    [[manager.prepend_keymap]]
    on   = [ "l" ]
    run  = "plugin --sync smart-enter"
    desc = "Enter the child directory, or open the file"
    [[manager.prepend_keymap]]
    on   = [ "p" ]
    run  = "plugin --sync smart-paste"
    desc = "Paste into the hovered directory or CWD"
    [[manager.prepend_keymap]]
    on   = [ "<C-s>" ]
    run  = 'shell "$SHELL" --block --confirm'
    desc = "Open shell here"
    [[manager.prepend_keymap]]
    on  = [ "T" ]
    run = "plugin --sync max-preview"

  '';
  home.file.".config/yazi/plugins/smart-enter.yazi/init.lua".text = ''
    return {
    	entry = function()
    		local h = cx.active.current.hovered
    		ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
    	end,
    }
  '';
  home.file.".config/yazi/plugins/smart-paste.yazi/init.lua".text = ''
    return {
    	entry = function()
    		local h = cx.active.current.hovered
    		if h and h.cha.is_dir then
    			ya.manager_emit("enter", {})
    			ya.manager_emit("paste", {})
    			ya.manager_emit("leave", {})
    		else
    			ya.manager_emit("paste", {})
    		end
    	end,
    }
  '';
  home.file.".config/yazi/plugins/max-preview.yazi/init.lua".text = ''
    local function entry(st)
      if st.old then
        Manager.layout, st.old = st.old, nil
      else
        st.old = Manager.layout
        Manager.layout = function(self, area)
          self.area = area

          return ui.Layout()
            :direction(ui.Layout.HORIZONTAL)
            :constraints({
              ui.Constraint.Percentage(0),
              ui.Constraint.Percentage(0),
              ui.Constraint.Percentage(100),
            })
            :split(area)
        end
      end
      ya.app_emit("resize", {})
    end

    return { entry = entry }
  '';
}
