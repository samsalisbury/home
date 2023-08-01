# shellcheck disable=SC2317 # Functions defined inside functions are fine.

creds() {

	# This function redefines itself on first run.
	creds() {
		test -n "$1" || { echo "usage: $0 <name>"; return 1; }
		local FILE="$HOME/.creds/$1"
		test -e "$FILE" || { echo "no creds matching $1"; return 1; }
		# shellcheck disable=SC1090 # Purposefully variable source.
		source "$FILE"
		echo "$1 credentials loaded"
	}

	# GitHub - auto-load credentials if available.
	gh() {
		local BIN
		BIN="$(which gh)"
		(
			creds github > /dev/null 2>&1
			"$BIN" "$@"
		)
	}
	
	# Git - auto-load github credentials if available.
	git() {
		local BIN
		BIN="$(which git)"
		(
			creds github > /dev/null 2>&1
			"$BIN" "$@"
		)
	}
}
