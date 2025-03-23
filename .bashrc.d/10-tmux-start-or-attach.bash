# tmux-start-or-attach starts a new tmux session and attaches to items
# if there are no tmux sessions in progress.
# If there are tmux sessions in progress and any of them are unattached,
# then it attaches to the first unattached session.
# If there are sessions and they are all attached, it doesn't start tmux
# at all and just provides a plain shell.
tmux-start-or-attach() {
	has tmux || {
		dbg "Tmux is not installed so do nothing."
		return 0
	}
	[[ -z "$VSCODE_SHELL_LOGIN" ]] || {
		dbg "Inside VSCode so don't launch tmux."
		return 0
	}
	[[ -z "${TMUX:-}" ]] || {
		set_window_title "$(current_session_name)"
		dbg "We are inside TMUX already so do nothing."
		return 0
	}
	local LSFMT SESSIONS UNATTACHED ALL_ATTACHED=false
	LSFMT="#{session_name}|#{?session_attached,attached,not attached}"
	SESSIONS="$(tmux ls -F "$LSFMT" 2>/dev/null)" || {
		dbg "No tmux sessions are running, start one."
		tmux -2 || return 1
		return "${STOP:?}"
	}
	UNATTACHED="$(grep 'not attached$' <<<"$SESSIONS" | head -n 1 | cut -d '|' -f1)" || {
		ALL_ATTACHED=true
	}
	[[ -n "$UNATTACHED" ]] || {
		ALL_ATTACHED=true
	}
	$ALL_ATTACHED && {
		dbg "All sessions are attached, just let the user know tmux is running."
		echo "You have tmux sessions running:"
		tmux ls || return 1
		return 0
	}
	dbg "We have at least one unattached session... Attach to it."
	set_window_title "$UNATTACHED"
	tmux -2 attach -t "$UNATTACHED"
	return "${STOP:?}"
}

current_session_name() { tmux display-message -p '#S'; }

set_window_title() {
	local TITLE="$1"
	has osascript || return 0
	cat <<-EOF | osascript
		tell application "Terminal"
			set custom title of front window to "$TITLE"
		end
	EOF
}
