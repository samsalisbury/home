#!/usr/bin/env bash

# shellcheck disable=SC1090 # Ignore "Can't follow non-constant source."

#
# Header
#

# Begin overall benchmarking...
now() { perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)'; }
START="$(now)"

# Load config
CONF=.config/bash_profile.env
[[ -f "$CONF" ]] || printf "BENCH=true\nDEBUG=true\nTRACE=true\n" > $CONF
source "$CONF"

# Utilities
lower() { tr '[:upper:]' '[:lower:]'; }
os()  { [[ "$OS" == "$1" ]]; }
OS="$(uname | lower)"
has() { command -v "$1" > /dev/null 2>&1; }
dur() { perl -e 'printf("%.3f\n", ($ARGV[1] - $ARGV[0])/1000)' "$1" "$2"; }
since() { end="$(now)"; dur "$1" "$end"; }
bench() { local start; B=""
	if $BENCH && $DEBUG; then start="$(now)"; fi
	"$@"; code=$?
	if $BENCH && $DEBUG; then B=" ($(since "$start"))"; fi
	return "$code"
}
CTX="$(basename "${BASH_SOURCE[0]}")"
dbg() { $DEBUG || return 0; log "DEBUG: $CTX: $*"; }
trace() { $TRACE || return 0; log "TRACE: $CTX: $*"; }
log() { printf "%s\n" "$*" >&2; }
msg() { MSGS+=("$*"); }; MSGS=()
run() { trace "run: \$ $*"
	CTX="$CTX: run: $1" bench "$@" && { dbg "run: $1: succeeded$B"; return 0; }
	code=$?; dbg "run: $1: failed$B"; return $code;
}
include() { local code fn_name file="$1"
	# STOP is a special exit code meaning stop sourcing further files.
	STOP=13
	trace "src: $file"
	source "$file" || return $?
	fn_name="$(echo "${1##.bashrc.d/}" | sed -E 's/[[:digit:]]{2}\-(.*)\.bash/\1/')"
	run $fn_name && return 0
	(( code == STOP )) && MSG=dbg || MSG=log
	$MSG "$file failed with exit code $code, skipping remaining files."
	return $code
}
pathadd() {
	for P in "$@"; do
		test -d "$P" || { dbg "pathadd: skipping nonexistent path $P to PATH"; continue; }
		[[ ":$PATH:" == *":$P:"* ]] && { dbg "pathadd: skipping duplicate path $P to PATH"; continue; }
		PATH="$P:$PATH" && dbg "pathadd: adding $P to PATH"
	done
}

#
# Main
#

for f in .bashrc.d/*.bash; do
	include "$f" || break
done

#
# Footer
#
$BENCH && msg "Loaded .bash_profile in $(since "$START")s"

for M in "${MSGS[@]}"; do log "$M"; done
