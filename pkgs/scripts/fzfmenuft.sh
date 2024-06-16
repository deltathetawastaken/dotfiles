#!/usr/bin/env bash

#coomented !/usr/bin/env bash
# fzfmenu - fzf as dmenu replacement

CONFIG="${XDG_CONFIG_HOME:-~/.config}/fzfmenu/fzfrc"
if [ -f "$CONFIG" ]; then
    # load config
    . "$CONFIG"
fi

awkVal() {
    awk -v Val="$1" 'BEGIN{FS=OFS=" "} {for(i=1;i<=NF;i++){if($i==Val){print $(i+1);next}}}'
}

input=$(mktemp -u --suffix .fzfmenu.input)
output=$(mktemp -u --suffix .fzfmenu.output)
mkfifo "$input"
mkfifo "$output"
chmod 600 $input $output

while getopts "fbip:l:w:" opt; do case "${opt}" in
    i) FZF_OPTS="$FZF_OPTS -$opt"  ;;
    l) FZF_OPTS="$FZF_OPTS --height $OPTARG" ;;
    p) FZF_OPTS="$FZF_OPTS --header $OPTARG" ;;
    w) TERM_OPTS="-into $OPTARG" ;;
    f|b) printf '%s\n' "${0##*/}: option $opt ignored" ;;
    *) printf '%s\n' "${0##*/}: invalid option $opt" >&2 ; exit 1 ;;
esac done
shift $(( OPTIND -1 ))

# add options from config and replace others if necesary
runHeight=$(printf '%s\n' $FZF_OPTS | awkVal "height")
if [ -z "$runHeight" ] || [ "${runHeight%\%}" -le 50 ]; then
    FZF_OPTS="$FZF_OPTS $FZF_HEIGHT"
fi

runPrompt=$(printf '%s\n' $FZF_OPTS | awkVal "heder")
if [ -z "$runPrompt" ]; then
    FZF_OPTS="$FZF_OPTS $FZF_HEADER"
fi

FZF_OPTS="$FZF_OPTS $FZF_MENU_OPTS"
FZF_OPTS="$FZF_OPTS $FZF_COLORS"

export FZF_OPTS

if [ -z "$FLOATING_TERMINAL" ]; then
    FLOATING_TERMINAL='footclient --title=clipboard_manager'
fi
if [ -z "$EXEC_FLAG" ]; then
    EXEC_FLAG=' '
fi

$FLOATING_TERMINAL $TERM_OPTS $EXEC_FLAG sh -c "cat $input | fzf $FZF_OPTS | tee $output" & disown

termPID=$!

# consume stdin into named pipe
cat > "$input"

for arg in "$@"; do
    # if it's a pipe then drain it to input
    [ -p "$arg" ] && { cat "$arg" > "$input"; };
done

# handle ctrl+c outside child terminal window
cleanup() {
    if kill -0 "$termPID" 2>/dev/null; then
        kill $termPID 2>/dev/null
    fi
    rm -f "$input $output"
}
trap cleanup EXIT

cat "$output"
