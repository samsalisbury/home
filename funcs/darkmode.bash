
PALETTE_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/darkmode"
PALETTE_STATE="$PALETTE_STATE_DIR/color-palette"
export PALETTE_STATE_TMUX="$PALETTE_STATE_DIR/tmux-palette.conf"
mkdir -p "$(dirname "$PALETTE_STATE")"

# system-palette tells tmux to copy the system's color palette if possible,
# or to continue to respect the currently manually set pallette otherwise.
system-palette() {
	PALETTE="$(defaults read -g AppleInterfaceStyle 2> /dev/null || \
		cat "$PALETTE_STATE" || \
		echo Light)"
	[ "$PALETTE" = "Dark" ] && dark
	[ "$PALETTE" = "Light" ] && light
}

OSA_SCRIPT='tell application "System Events"'
OSA_SCRIPT+='to tell appearance preferences to set dark mode to'

set_macos_pallete() {
	[ "$1" = "dark" ] && MAC_MODE="true"
	[ "$1" = "light" ] && MAC_MODE="false"
	osascript -e "$OSA_SCRIPT $MAC_MODE"
}

maclight() {
	set_macos_pallete light
}

macdark() {
	set_macos_pallete dark
}

# light sets tmux to light mode.
light() {
	maclight
	MODE=Light
	BG="#FFFFFF"
	FG="#171717"
	BORDER=green
	HIGHLIGHT=magenta
	set_terminal_pallete
	match-brightness
}

# light sets tmux to dark mode.
dark() {
	macdark
	MODE=Dark
	BG="#171717"
	FG="#99FF33"
	BORDER=green
	HIGHLIGHT=magenta
	set_terminal_pallete
	match-brightness
}

set_terminal_pallete() {
	echo "$MODE" > "$PALETTE_STATE"

	WINDOW_STYLE="bg=$BG fg=$FG"

	# Write a config snippet for .tmux.conf to source. This avoids having to run a
	# shell command to set the color _after_ the pane has loaded, thus avoiding the
	# white flash.
	echo "set -g window-style '$WINDOW_STYLE'" > "$PALETTE_STATE_TMUX"

	# Update current tmux chrome.
	tmux set window-style             "$WINDOW_STYLE"
	tmux set pane-border-style        "bg=$BG fg=$BORDER"
	tmux set pane-active-border-style "bg=$BG fg=$HIGHLIGHT"
	
	# Update all the currently-open panes to the right colour palette.
	#PANES="$(tmux list-panes -a -F '#{pane_id}')"
	#for PANE in $PANES; do
	#	:
	#	#tmux select-pane -t "$PANE" -P "$WINDOW_STYLE"
	#done
}
