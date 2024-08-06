{ pkgs, lib, ... }:

{
  # .nix for small config files that do not deserve separate folder

  home.file.".config/foot/foot.ini".text = ''
font=FiraCode Nerd Font Mono Light:size=7
#box-drawings-uses-font-glyphs=true
dpi-aware=true
resize-delay-ms=10
# csd.preferred = none

[tweak]
max-shm-pool-size-mb=2048
font-monospace-warn=false
box-drawing-solid-shades=true
[cursor]
style=beam
blink=false
[colors]
alpha=1

#maybe change theme to cat /usr/share/foot/themes/visibone idk

#foreground=cdd6f4 # Text
##background=1e1e2e # Base
#background=000000 # Base
#regular0=45475a   # Surface 1
#regular1=f38ba8   # red
#regular2=a6e3a1   # green
#regular3=f9e2af   # yellow
#regular4=89b4fa   # blue
#regular5=f5c2e7   # pink
#regular6=94e2d5   # teal
#regular7=bac2de   # Subtext 1
#bright0=585b70    # Surface 2
#bright1=f38ba8    # red
#bright2=a6e3a1    # green
#bright3=f9e2af    # yellow
#bright4=89b4fa    # blue
#bright5=f5c2e7    # pink
#bright6=94e2d5    # teal
#bright7=a6adc8    # Subtext 0

foreground=ffffff # Text
background=000000 # Base
regular0=666666   # Surface 1
regular1=cc6666   # red
regular2=66cc99   # green
regular3=cc9966   # yellow
regular4=6699cc   # blue
regular5=cc6699   # pink
regular6=66cccc   # teal
regular7=cccccc   # Subtext 1
bright0=999999    # Surface 2
bright1=ff9999    # red
bright2=99ffcc    # green
bright3=ffcc99    # yellow
bright4=99ccff    # blue
bright5=ff99cc    # pink
bright6=99ffff    # teal
bright7=ffffff    # Subtext 0
  '';
}
