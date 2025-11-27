basics() {

	export SHIM_PATH="$HOME/bin/shims"

	# Add initial paths.
	pathadd "/opt/homebrew/bin"
	pathadd "/opt/homebrew/opt/ruby/bin"
	pathadd "$HOME/.local/share/bin" # Vendored binaries.
	pathadd "$HOME/.local/bin"       # Vendored binaries.
	pathadd "$HOME/bin"              # User binaries.
	pathadd "$SHIM_PATH"             # Shims for other programs.

	# Mac specific stuff
	os darwin && {
		export BASH_SILENCE_DEPRECATION_WARNING=1
	}

	# Set input mode to vi.
	set -o vi

	# Editor
	alias vim=nvim
	export VISUAL=nvim
	export EDITOR=$VISUAL

	# Don't attempt host completion. (This allows completion of filenames
	# beginning with @ which unfortunately we have to use sometimes.)
	shopt -u hostcomplete

	# Some scripts and Makefiles this to decide whether to clear the screen.
	export AUTOCLEAR=1

	# Bash history settings.
	HISTSIZE=10000 # in-memory history items
	HISTFILESIZE=2000000
	# Append to history instead of overwrite
	shopt -s histappend
	# Ignore redundant or space commands
	HISTCONTROL=ignoreboth
	# Ignore more
	HISTIGNORE='l:gs:gd:ls:ll:ls -lah:pwd:clear:history'
	# Set time format
	HISTTIMEFORMAT='%F %T '
	# Multiple commands on one line show up as a single line
	shopt -s cmdhist
	#export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
}

use_local_history() {
	local HIST_BASE="$HOME/.local/state/bash/sessions"
	local HIST_NAME="${PWD////%}"
	[[ -d "$HIST_BASE" ]] || mkdir -p "$HIST_BASE"
	local HIST_FILE="$HIST_BASE/$HIST_NAME.bash_history"
	export HISTFILE="$HIST_FILE"
}
