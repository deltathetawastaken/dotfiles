{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./hyprland-environment.nix
  ];

  home.packages = with pkgs; [ 
    waybar
    swww
  ];
  
  #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    #nvidiaPatches = true;
    extraConfig = ''
            
            # Setup monitors
        # Setup monitors
        # See https://wiki.hyprland.org/Configuring/Monitors/
        #monitor=,preferred,auto,1.066667
        #monitor=,preferred,90,1.066667
        monitor=eDP-1,preferred,auto,1
        #monitor=eDP-1,preferred,auto,1.066667
        #source = ~/.config/hypr/monitors.conf
        #source = ~/.config/hypr/workspaces.conf

        # Dual monitor example on G15 Strix
        # eDP-1 is the built in monitor while DP-1 is external
        # Both monitors here are at 1440 and 165Hz
        # DP-1 is on the left and  eDP-1 is on the right
        #monitor=DP-1,2560x1440@165,0x0,1
        #monitor=eDP-1,2560x1440@165,2560x0,1

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more

        # Execute your favorite apps at launch
        exec-once = ~/.config/hypr/xdg-ausl-hyprland
        exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
        exec-once = swww init
        exec-once = sh -c "sleep 1 && swww clear"
        #exec-once = swww img Downloads/PC\ Wallpapers/gifpixel/rooftop.gif
        #exec-once = mpvpaper '*' -o "video-scale-y=1.1 --gpu-context=wayland --vo=gpu --hwdec=vaapi-copy" videowork/bgloop.webm

        exec-once = waybar
        #exec-once = ags

        #exec = /usr/bin/hyprland-per-window-layout
        exec-once = blueman-applet
        exec-once = nm-applet --indicator
        exec-once = wl-paste --watch cliphist store
        #exec = ~/.config/HyprV/hyprv_util setbg
        exec-once = pypr

        exec-once = foot -s
        exec-once = thunar --daemon
        exec-once = swayidle -d
        exec-once = hyprctl setcursor Bibata-Modern-Classic 16

        exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once=systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

        env = NIX_REMOTE,daemon
        exec-once = export XDG_DATA_DIRS=$HOME/.nix-profile/share:$XDG_DATA_DIRS

        #env = QT_QPA_PLATFORMTHEME,qt5ct
        env = QT_AUTO_SCREEN_SCALE_FACTOR,1
        env = QT_QPA_PLATFORM,wayland;xcb
        env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

        #env = GTK_THEME,Catppuccin-Macchiato-Rosewater-dark:dark
        #env = GTK_THEME,Catppuccin-Macchiato-Rosewater-dark:light
        env = GDK_BACKEND,wayland,x11

        env = XDG_CURRENT_DESKTOP,Hyprland
        env = XDG_SESSION_TYPE,wayland
        env = XDG_SESSION_DESKTOP,Hyprland




        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input {
            kb_layout = us,ru
            kb_variant =
            kb_model =
            kb_options=grp:caps_toggle
            kb_rules =



            follow_mouse = 1
            mouse_refocus = false

            touchpad {
                natural_scroll = no
                #disable_while_typing = false
            }

            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        }

        general {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more

            gaps_in = 0
            gaps_out = 0
            border_size = 1
            no_border_on_floating = true
            cursor_inactive_timeout = 3
            #no_cursor_warps = true
            
            #col.active_border = rgba(7287fdee) rgba(179299ee) 45deg
            col.active_border = rgba(7287fdee)
            #col.active_border=rgb(cdd6f4)
            col.inactive_border = rgba(595959aa)

            layout = dwindle
            #layout = master
        }

        Binds {
            scroll_event_delay = 0
            workspace_back_and_forth = true
            workspace_center_on = 1
        }

        XWayland {
            force_zero_scaling = true
        }

        misc {
            disable_hyprland_logo = yes
            focus_on_activate = yes
            #key_press_enables_dpms = true

            # Whether Hyprland should focus an app that requests to be focused
            focus_on_activate = true

            #config autoreload
            #disable_autoreload = true
            #no_vfr = false
            #render_ahead_of_time = yes
            new_window_takes_over_fullscreen = 2
            no_direct_scanout = false
        }



        decoration {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more

            rounding = 5
            
            blur {
                enabled = true
                size = 7
                passes = 4
                new_optimizations = true
            }

            blurls = lockscreen

            drop_shadow = yes
            shadow_range = 4
            shadow_render_power = 3
            col.shadow = rgba(1a1a1aee)
        }

        animations {
            enabled = yes

            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
            bezier = myBezier, 0.10, 0.9, 0.1, 1.05

            animation = windows, 1, 7, myBezier, slide
            animation = windowsOut, 1, 7, myBezier, slide
            animation = border, 1, 10, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 6, default
        }

        dwindle {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = yes # you probably want this
            #force_split = 2
            permanent_direction_override = true
            smart_split = false
            no_gaps_when_only = 1
        }

        master {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            new_is_master = false
            no_gaps_when_only = 1
            allow_small_split = true
        }

        gestures {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            #workspace_swipe_direction_lock = off
            workspace_swipe = true
            workspace_swipe_fingers = 3
            workspace_swipe_cancel_ratio = 0.15
        }

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
        device:epic mouse V1 {
            sensitivity = -0.5
        }

        # Example windowrule v1
        #windowrule = float, ^(kitty)$
        windowrule = float,^(pavucontrol)$
        windowrule = float,^(blueman-manager)$
        windowrule = float,^(nm-connection-editor)$
        #windowrule = float,^(chromium)$
        windowrule = float,^(thunar)$
        windowrule = float, title:^(btop)$
        windowrule = float, title:^(update-sys)$

        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        # rules below would make the specific app transparent
        windowrulev2 = opacity 0.8 0.8,class:^(kitty)$
        windowrulev2 = animation popin,class:^(kitty)$,title:^(update-sys)$
        windowrulev2 = animation popin,class:^(thunar)$
        #windowrulev2 = opacity 0.8 0.8,class:^(thunar)$
        #windowrulev2 = opacity 0.8 0.8,class:^(VSCodium)$
        #windowrulev2 = animation popin,class:^(chromium)$
        windowrulev2 = move cursor -3% -105%,class:^(wofi)$
        windowrulev2 = noanim,class:^(wofi)$
        windowrulev2 = opacity 0.8 0.6,class:^(wofi)$
        #sway-launcher
        windowrulev2 = float,class:^(kitty)$,title:^(sway-launcher-desktop)$
        windowrulev2 = noanim,class:^(kitty)$,title:^(sway-launcher-desktop)$
        windowrulev2 = stayfocused,class:^(kitty)$,title:^(sway-launcher-desktop)$
        #windowrulev2 = float,class:^(wezterm)$,title:^(sway-launcher-desktop)$
        #windowrulev2 = noanim,class:^(wezterm)$,title:^(sway-launcher-desktop)$
        #windowrulev2 = stayfocused,class:^(wezterm)$,title:^(sway-launcher-desktop)$
        windowrulev2 = float,class:^(swlauncher)$
        windowrulev2 = noanim,class:^(swlauncher)$
        windowrulev2 = stayfocused,class:^(swlauncher)$
        windowrulev2 = center,class:^(swlauncher)$
        windowrulev2 = size 28% 50%,class:^(swlauncher)$

        windowrulev2 = float,class:^(clipmanager)$
        windowrulev2 = noanim,class:^(clipmanager)$
        windowrulev2 = stayfocused,class:^(clipmanager)$
        windowrulev2 = center,class:^(clipmanager)$
        windowrulev2 = size 60% 45%,class:^(clipmanager)$

        #foot clipboard-manager
        windowrulev2 = float,title:^(clipboard_manager)$
        windowrulev2 = noanim,title:^(clipboard_manager)$
        windowrulev2 = stayfocused,title:^(clipboard_manager)$
        windowrulev2 = center,title:^(clipboard_manager)$
        windowrulev2 = size 45% 45%,title:^(clipboard_manager)$

        #foot applauncher app_launcher
        windowrulev2 = float,title:^(app_launcher)$
        windowrulev2 = noanim,title:^(app_launcher)$
        windowrulev2 = stayfocused,title:^(app_launcher)$
        windowrulev2 = center,title:^(app_launcher)$
        windowrulev2 = size 28% 50%,title:^(app_launcher)$

        #foot emoji_manager
        windowrulev2 = float,title:^(emoji_manager)$
        windowrulev2 = noanim,title:^(emoji_manager)$
        windowrulev2 = stayfocused,title:^(emoji_manager)$
        windowrulev2 = center,title:^(emoji_manager)$
        windowrulev2 = size 35% 50%,title:^(emoji_manager)$

        windowrulev2 = noanim,class:^(__screenshoter)$
        windowrulev2 = float,class:^(__screenshoter)$

        #steam
        windowrulev2 = stayfocused, title:^()$,class:^(steam)$
        windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$
        windowrulev2 = noblur, class:^(steam)$
        windowrulev2 = noshadow, class:^(steam)$

        windowrule = noblur,^(firefox)$ # disables blur for firefox

        #layerrules
        #layerrule = noanim, swaync-notification-window

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        $mainMod = SUPER

        bind = $mainMod, G, exec, /home/delta/.config/hypr/changeLayout.sh
        #master layout
        bind = $mainMod, I, layoutmsg, addmaster
        bind = $mainMod SHIFT, I, layoutmsg, removemaster
        bind = $mainMod, U, layoutmsg, orientationleft
        bind = $mainMod SHIFT, U, layoutmsg, orientationright
        bind = $mainMod, Y, layoutmsg, orientationcenter
        bind = $mainMod, O, layoutmsg, swapwithmaster

        #dwindle layout
        bind = $mainMod, I, layoutmsg, preselect d
        bind = $mainMod, O, layoutmsg, preselect n
        bind = $mainMod, U, togglesplit

        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        #bind = $mainMod, Q, exec, kitty  #open the terminal
        bind = $mainMod, RETURN, exec, footclient  #open the terminal
        bind = $mainMod SHIFT, RETURN, exec, alacritty  #open the terminal
        bind = $mainMod, Q, exec, wezterm #open the terminal
        #bind = $mainMod, Q, exec, alacritty  #open the terminal
        bind = $mainMod SHIFT, Q, exec, alacritty  #open the terminal
        bind = $mainMod CONTROL, Q, exec, wezterm start #--always-new-process  #open the terminal

        bind = $mainMod, F1, exec, ~/.config/hypr/gamemode.sh
        env = HYPRGAPSMODE
        bind = $mainMod, F2, exec, ~/.config/hypr/gapsmode.sh

        bind = $mainMod, B, exec, swaync-client --toggle-panel # notify center
        bind = ALT, B, exec, swaync-client --close-latest # close lathest notify

        bind = $mainMod, F4, killactive, # close the active window
        bind = $mainMod, TAB, killactive, # close the active window
        bind = $mainMod SHIFT, TAB, killactive, # close the active window
        bind = $mainMod, Escape, exec, /home/delta/scripts/swaylock # Lock the screen
        bind = $mainMod, M, exec, wlogout --protocol layer-shell # show the logout window
        bind = $mainMod SHIFT, M, exit, # Exit Hyprland all together no (force quit Hyprland)
        bind = $mainMod, E, exec, thunar # Show the graphical file browser
        bind = $mainMod, V, togglefloating, # Allow a window to float
        #bind = $mainMod, SPACE, exec, wofi # Show the graphical app launcher
        #bind = $mainMod, SPACE, exec, kitty /usr/bin/
        her-desktop # Show the graphical app launcher
        #bind = $mainMod, SPACE, exec, alacritty --class=swlauncher -e /usr/bin/sway-launcher-desktop #& hyprctl switchxkblayout at-translated-set-2-keyboard 0# Show the graphical app launcher
        #bind = $mainMod, SPACE, exec, footclient --title=app_launcher sh -c "TERMINAL=footclient sway-launcher-desktop" & hyprctl switchxkblayout at-translated-set-2-keyboard 0# Show the graphical app launcher
        bind = $mainMod, SPACE, exec, anyrun & hyprctl switchxkblayout at-translated-set-2-keyboard 0# Show the graphical app launcher
        bind = $mainMod SHIFT, SPACE, exec, footclient --title=app_launcher sh -c "TERMINAL=footclient sway-launcher-desktop" & hyprctl switchxkblayout at-translated-set-2-keyboard 0# Show the graphical app launcher

        #bind = $mainMod CONTROL, SPACE, swapactiveworkspaces # Swaps the active workspaces between two monitors
        bind =  ALT, SPACE, exec, pypr shift_monitors +1 # K R A S I V O



        bind = $mainMod, P, pseudo, # dwindle
        #bind = $mainMod, J, togglesplit, # dwindle
        #bind = $mainMod, S, exec, grim -g "$(slurp)" - | tee >(swappy -f -) | wl-copy # take a screenshot
        bind = $mainMod, S, exec, hyprshot -m region --clipboard-only -s # take a screenshot
        bind = $mainMod, Print, exec, /home/delta/scripts/screenshoter.sh # take a screenshot
        bind = ,Print , exec, wl-paste | swappy -f - # take a screenshot
        #bind = $mainMod, S, exec, /home/delta/screenshoter.sh # take a screenshot
        #bind = $mainMod, S, exec, hyprshot -m output -s -c --clipboard-only # take a screenshot
        #bind = ALT, V, exec, cliphist list | wofi -dmenu | cliphist decode | wl-copy # open clipboard manager
        #bind = ALT, V, exec, cliphist list | /home/delta/scripts/fzfmenu | cliphist decode | wl-copy # open clipboard manager
        bind = ALT, V, exec, cliphist list | /home/delta/scripts/fzfmenuft | cliphist decode | wl-copy && wtype -M ctrl v -m ctrl # open clipboard manager
        bind = $mainMod, R, exec, footclient --title=emoji_manager sh -c "~/scripts/shmoji/shmoji fzf | wl-copy" & hyprctl switchxkblayout at-translated-set-2-keyboard 0
        #bind = $mainMod, T, exec, ~/.config/HyprV/hyprv_util vswitch # switch HyprV version
        bind = $mainMod, X, togglesplit, # dwindle
        bind = $mainMod, C, fullscreen, 1 # fs
        bind = $mainMod SHIFT, C, fullscreen, 0 # fs
        bind = $mainMod, F, fakefullscreen # fs
        bind = $mainMod CONTROL, C, fakefullscreen # fs
        #bind = $mainMod, Z, maximize, # fs

        # Move focus with mainMod + arrow keys
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d

        bind = $mainMod, H, movefocus, l
        bind = $mainMod, J, movefocus, d
        bind = $mainMod, K, movefocus, u
        bind = $mainMod, L, movefocus, r

        #bind = $mainMod, shift H, movefocus, l
        bind = $mainMod SHIFT, J, workspace, e-1
        bind = $mainMod SHIFT, K, workspace, e+1
        #bind = $mainMod, L, movefocus, r

        # Switch workspaces with mainMod + [0-9]
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        bind = $mainMod SHIFT, 1, movetoworkspace, 1
        bind = $mainMod SHIFT, 2, movetoworkspace, 2
        bind = $mainMod SHIFT, 3, movetoworkspace, 3
        bind = $mainMod SHIFT, 4, movetoworkspace, 4
        bind = $mainMod SHIFT, 5, movetoworkspace, 5
        bind = $mainMod SHIFT, 6, movetoworkspace, 6
        bind = $mainMod SHIFT, 7, movetoworkspace, 7
        bind = $mainMod SHIFT, 8, movetoworkspace, 8
        bind = $mainMod SHIFT, 9, movetoworkspace, 9
        bind = $mainMod SHIFT, 0, movetoworkspace, 10

        # Move active window silently to a workspace with mainMod + CONTROL + [0-9]
        bind = $mainMod CONTROL, 1, movetoworkspacesilent, 1
        bind = $mainMod CONTROL, 2, movetoworkspacesilent, 2
        bind = $mainMod CONTROL, 3, movetoworkspacesilent, 3
        bind = $mainMod CONTROL, 4, movetoworkspacesilent, 4
        bind = $mainMod CONTROL, 5, movetoworkspacesilent, 5
        bind = $mainMod CONTROL, 6, movetoworkspacesilent, 6
        bind = $mainMod CONTROL, 7, movetoworkspacesilent, 7
        bind = $mainMod CONTROL, 8, movetoworkspacesilent, 8
        bind = $mainMod CONTROL, 9, movetoworkspacesilent, 9
        bind = $mainMod CONTROL, 0, movetoworkspacesilent, 10

        # Scroll through existing workspaces with mainMod + scroll
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up, workspace, e-1

        bind = $mainMod, bracketright, workspace, e+1
        bind = $mainMod, bracketleft, workspace, e-1

        # Scroll through windows workspaces with mainMod + scroll
        bind = $mainMod SHIFT, mouse_down, cyclenext
        bind = $mainMod SHIFT, mouse_up, cyclenext, prev

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        #Move/resize windows with arrowkeys
        binde = $mainMod CTRL, right, resizeactive, 10 0
        binde = $mainMod CTRL, left, resizeactive, -10 0
        binde = $mainMod CTRL, up, resizeactive, 0 -10
        binde = $mainMod CTRL, down, resizeactive, 0 10

        #Move windows between grid with hjkl
        bind = $mainMod CTRL, h, movewindow, l
        bind = $mainMod CTRL, j, movewindow, d 
        bind = $mainMod CTRL, k, movewindow, u
        bind = $mainMod CTRL, l, movewindow, r

        # Move grid window between grid with arrows
        bind = $mainMod SHIFT, left, movewindow, l
        bind = $mainMod SHIFT, right, movewindow, r
        bind = $mainMod SHIFT, up, movewindow, u
        bind = $mainMod SHIFT, down, movewindow, d 

        #bind = $mainMod SHIFT, H, swapwindow, left
        #bind = $mainMod SHIFT, J, swapwindow, down
        #bind = $mainMod SHIFT, K, swapwindow, up
        #bind = $mainMod SHIFT, L, swapwindow, right


        # Move floating window wsad-like (change to vim keybinds later)
        binde = $mainMod SHIFT CTRL, H, moveactive, -30 0
        binde = $mainMod SHIFT CTRL, J, moveactive, 0 30
        binde = $mainMod SHIFT CTRL, K, moveactive, 0 -30
        binde = $mainMod SHIFT CTRL, L, moveactive, 30 0 

        # Move grid window between grid
        #bind = $mainMod SHIFT, A, movewindow, l
        #bind = $mainMod SHIFT, D, movewindow, r
        #bind = $mainMod SHIFT, W, movewindow, u
        #bind = $mainMod SHIFT, S, movewindow, d 

        #bind = $mainMod SHIFT, H, movewindow, l
        #bind = $mainMod SHIFT, J, movewindow, d
        #bind = $mainMod SHIFT, K, movewindow, u
        #bind = $mainMod SHIFT, L, movewindow, r 

        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf
        source = ~/.config/hypr/media-binds.conf
        source = ~/.config/hypr/env_var.conf

        '';
  };

      home.file.".config/hypr/colors".text = ''
$background = rgba(1d192bee)
$foreground = rgba(c3dde7ee)

$color0 = rgba(1d192bee)
$color1 = rgba(465EA7ee)
$color2 = rgba(5A89B6ee)
$color3 = rgba(6296CAee)
$color4 = rgba(73B3D4ee)
$color5 = rgba(7BC7DDee)
$color6 = rgba(9CB4E3ee)
$color7 = rgba(c3dde7ee)
$color8 = rgba(889aa1ee)
$color9 = rgba(465EA7ee)
$color10 = rgba(5A89B6ee)
$color11 = rgba(6296CAee)
$color12 = rgba(73B3D4ee)
$color13 = rgba(7BC7DDee)
$color14 = rgba(9CB4E3ee)
$color15 = rgba(c3dde7ee)
    '';
}
