# Bash library

creds() {
	test -n "$1" || { echo "usage: $0 <name>"; return 1; }
	local FILE="$HOME/.creds/$1"
	test -e "$FILE" || { echo "no creds matching $1"; return 1; }
	# shellcheck disable=SC1090 # Purposefully variable source.
	source "$FILE"
	echo "$1 credentials loaded"
}
