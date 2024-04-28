function icat_auto
  set cols (math (tput cols) - 1)
  set lines (math (tput lines) - 1)
  kitty +kitten icat --place $cols"x"$lines"@0x0" $argv
end