
PALETTE_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/darkmode"
PALETTE_STATE="$PALETTE_STATE_DIR/color-palette"
export PALETTE_STATE_TMUX="$PALETTE_STATE_DIR/tmux-palette.conf"
mkdir -p "$(dirname "$PALETTE_STATE")"

# system-palette tells tmux to copy the system's color palette if possible,
# or to continue to respect the currently manually set pallette otherwise.
system-palette() {
	local PALETTE
	# AppleInterfaceStyle is nil (thus errors) when in light mode. Otherwise
	# it returns "Dark". We return "Light" when it should be light.
	PALETTE="$(defaults read -g AppleInterfaceStyle 2> /dev/null || \
		cat "$PALETTE_STATE" || \
		echo Light)"
	[ "$PALETTE" = "Dark" ] && dark
	[ "$PALETTE" = "Light" ] && light
}

set_macos_pallete() {
	local MODE="$1" MAC_MODE
	[ "$MODE" = "dark" ] && MAC_MODE="true"
	[ "$MODE" = "light" ] && MAC_MODE="false"
	osascript - <<-EOF
		tell application "System Events"
			tell appearance preferences
				set dark mode to $MAC_MODE
			end tell
		end tell
	EOF
}

set_terminal_pallete() {
	echo "$MODE" > "$PALETTE_STATE"

	# Tell all nvims to update appearance.
	# shellcheck disable=SC2086
	for P in $(pgrep nvim); do kill -SIGUSR1 $P; done

	local WINDOW_STYLE="bg=$BG fg=$FG"

	# Write a config snippet for .tmux.conf to source. This avoids having to run a
	# shell command to set the color _after_ the pane has loaded, thus avoiding the
	# white flash.
	cat <<-EOF > "$PALETTE_STATE_TMUX"
		set -g window-style '$WINDOW_STYLE'
		set -g pane-border-style 'bg=$BG fg=$BORDER'
		set -g pane-active-border-style 'bg=$BG fg=$HIGHLIGHT'

		set  window-style '$WINDOW_STYLE'
		set  pane-border-style 'bg=$BG fg=$BORDER'
		set  pane-active-border-style 'bg=$BG fg=$HIGHLIGHT'
	EOF

	tmux source-file "$PALETTE_STATE_TMUX"

	ORIG_WINDOW="$(tmux display-message -p '#I')"
	for W in $(tmux list-windows -a -F '#{window_id}'); do
		tmux select-window -t "$W" && tmux source-file "$PALETTE_STATE_TMUX"
	done
	tmux select-window -t "$ORIG_WINDOW"

	## Update all the currently-open panes to the right colour palette.
	PANES="$(tmux list-panes -a -F '#{pane_id}')"
	for PANE in $PANES; do
		tmux select-pane -t "$PANE" -P "$WINDOW_STYLE"
	done
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
	match-brightness || true
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
	match-brightness || true
}
