PALETTE_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/darkmode"
PALETTE_STATE="$PALETTE_STATE_DIR/color-palette"
export PALETTE_STATE_TMUX="$PALETTE_STATE_DIR/tmux-palette.conf"
mkdir -p "$(dirname "$PALETTE_STATE")"

# system-palette tells tmux to copy the system's color palette if possible,
# or to continue to respect the currently manually set palette otherwise.
system-palette() {
	local PALETTE
	# AppleInterfaceStyle is nil (thus errors) when in light mode. Otherwise
	# it returns "Dark". We return "Light" when it should be light.
	CMD=(defaults read -g AppleInterfaceStyle)
	PALETTE="$("${CMD[@]}" 2>/dev/null || cat "$PALETTE_STATE" || echo Light)"
	[ "$PALETTE" = "Dark" ] && dark
	[ "$PALETTE" = "Light" ] && light
}

get-darkmode() {
	local PALETTE
	CMD=(defaults read -g AppleInterfaceStyle)
	"${CMD[@]}" 2>/dev/null || cat "$PALETTE_STATE" || echo Light
}

reload-darkmode() {
	local NAME
	NAME="$(basename "${BASH_SOURCE[0]}")"
	FILEPATH="$HOME/funcs/$NAME"
	source "$FILEPATH"
}

set_macos_palette() {
	command -v osascript >/dev/null 2>&1 || {
		echo "Skipping macos palette, osascript not found." 1>&SC2086
		return 0
	}
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

# These commands' colours are controlled by environment variables.
# We can't alter these, or add aliases/functions to running shells.
# So the only way to reliably set their colours is to create an
# executable shim in the PATH.
set_command_colors() {
	create_env_shim ls "LSCOLORS='$LSCOLORS'"
	create_env_shim jq "JQ_COLORS='$JQ_COLORS'"
}

# create_env_shim ceates a shim executable that sets
# environment variables before calling the original command.
create_env_shim() {
	PROG="$1"
	shift
	[[ -z "$SHIM_PATH" ]] && {
		echo "SHIM_PATH not set; can't make colour shims." 1>&2
		return 1
	}
	mkdir -p "$SHIM_PATH"
	cat <<-EOF >"$SHIM_PATH/$PROG"
		#!/bin/bash
		PATH="$(sed -E "s|$SHIM_PATH:?||g" <<<"$PATH")"
		$@ $PROG "\$@"
	EOF
	chmod +x "$SHIM_PATH/$PROG"
}

set_terminal_palette() {
	echo "$MODE" >"$PALETTE_STATE"

	set_command_colors

	# Tell all nvims to update colorscheme.
	nvim-remote tell-all "<ESC>:colorscheme $COLORSCHEME<CR>:set background=$BACKGROUND<CR>"
	# Tell all nvimst to update lualine colorscheme.
	LUA="require('lualine').setup( { options = vim.tbl_deep_extend('force', require('lualine').get_config(), {theme='$LUALINE_THEME'}) } )"
	nvim-remote tell-all "<ESC>:lua $LUA<CR>"

	#
	#
	#
	# shellcheck disable=SC2086
	#for P in $(pgrep nvim); do kill -SIGUSR1 $P; done

	local WINDOW_STYLE="bg=$BG fg=$FG"

	# Write a config snippet for .tmux.conf to source. This avoids having to run a
	# shell command to set the color _after_ the pane has loaded, thus avoiding the
	# white flash.
	cat <<-EOF >"$PALETTE_STATE_TMUX"
		set -g window-style '$WINDOW_STYLE'
		set -g pane-border-style 'bg=$BG fg=$BORDER'
		set -g pane-active-border-style 'bg=$BG fg=$HIGHLIGHT'

		set -g status-style 'fg=$STATUS_FG,bold bg=$STATUS_BG'
		setw -g window-status-current-style fg=$STATUS_SELECTED

		set  window-style '$WINDOW_STYLE'
		set  pane-border-style 'bg=$BG fg=$BORDER'
		set  pane-active-border-style 'bg=$BG fg=$HIGHLIGHT'
	EOF

	tmux source-file "$PALETTE_STATE_TMUX"

	if command -v osascript >/dev/null 2>&1; then
		osascript <<-EOF
			tell application "Terminal"
			  set background color of selected tab of window 1 to $TERMINAL_BG
			end tell
		EOF
	fi

	# Set the style for each open window first.
	ORIG_WINDOW="$(tmux display-message -p '#I')"
	for W in $(tmux list-windows -a -F '#{window_id}'); do
		tmux select-window -t "$W" && tmux source-file "$PALETTE_STATE_TMUX"
	done
	tmux select-window -t "$ORIG_WINDOW"

	ORIG_PANE="$TMUX_PANE"
	ORIG_ZOOMED=false
	if tmux list-panes -F '#{window_zoomed_flag}' | grep -F -q 1; then
		ORIG_ZOOMED=true
	fi

	## Update all the currently-open panes to the right colour palette.
	PANES="$(tmux list-panes -a -F '#{pane_id}')"
	for PANE in $PANES; do
		tmux select-pane -t "$PANE" -P "$WINDOW_STYLE"
	done

	tmux select-pane -t "$ORIG_PANE"
	$ORIG_ZOOMED && tmux resize-pane -Z

}

maclight() {
	set_macos_palette light
}

macdark() {
	set_macos_palette dark
}

# light sets tmux to light mode.
light() {
	tmux setenv DARKMODE Light
	maclight
	MODE=Light
	BG="#FFFFFF"
	FG="#171717"
	BORDER=green
	HIGHLIGHT=magenta
	STATUS_BG=green
	STATUS_FG=white
	STATUS_SELECTED="brightwhite"
	BACKGROUND=light
	COLORSCHEME=github-sam
	LUALINE_THEME="ayu_light"
	TERMINAL_BG="{65000, 65000, 65000}"
	LSCOLORS="exfxcxdxbxegedabagacadah"
	JQ_COLORS="0;90:0;37:0;37:0;37:0;32:1;37:1;37:1;34"
	set_terminal_palette
	match-brightness >/dev/null 2>&1 || true
}

# light sets tmux to dark mode.
dark() {
	tmux setenv DARKMODE Dark
	local BLACK="#121212"
	macdark
	MODE=Dark
	BG="$BLACK"
	FG="#99FF33"
	BORDER=green
	HIGHLIGHT=magenta
	STATUS_BG=green
	STATUS_FG=black
	STATUS_SELECTED="$BLACK"
	BACKGROUND=dark
	COLORSCHEME=github
	LUALINE_THEME="tokyonight"
	TERMINAL_BG="{0, 0, 0}"
	LSCOLORS="Gxfxcxdxbxegedabagacad"
	JQ_COLORS="0;90:0;37:0;37:0;37:0;32:1;37:1;37:1;36"
	set_terminal_palette
	match-brightness >/dev/null 2>&1 || true
}

tmux-getenv() {
	tmux show-environment | grep -E "^$1=" | cut -d= -f2
}

if [[ -z "$(tmux-getenv DARKMODE)" ]]; then
	dark
fi
