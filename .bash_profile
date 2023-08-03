#!/usr/bin/env bash

# shellcheck disable=SC1090 # Ignore "Can't follow non-constant source."

#
# Header
#

# Begin overall benchmarking...
now() { perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)'; }
$SILENT || {
	START="$(now)"
}
# Load config
CONF=~/.config/bash_profile.env
writeconf() {
	mkdir -p "$(dirname "$CONF")"
	{
		echo "SILENT=${SILENT:-false}"
		echo "BENCH=${BENCH:-false}"
		echo "DEBUG=${DEBUG:-false}"
		echo "TRACE=${TRACE:-false}"
	} > "$CONF"
}
readconf() {
	[[ -f "$CONF" ]] || writeconf
	source "$CONF"
}
readconf

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
reload() { source ~/.bash_profile; }
CTX="$(basename "${BASH_SOURCE[0]}")"
dbg() { $DEBUG || return 0; log "DEBUG: $CTX: $*"; }
bnc() { $BENCH || return 0; log "BENCH: $CTX: $*"; }
trace() { $TRACE || return 0; log "TRACE: $CTX: $*"; }
log() { printf "%s\n" "$*" >&2; }
msg() { $SILENT && return 0; MSGS+=("$*"); }; MSGS=()
run() { trace "run: \$ $*"
	CTX="$CTX: run: $1" bench "$@" && { dbg "run: $1: succeeded$B"; return 0; }
	code=$?; dbg "run: $1: failed$B"; return $code;
}

benchmark() { clear; local B="$BENCH"; bench_on; reload 2>&1 | ts -i "%.S"; BENCH="$B"; writeconf; }
bench_on() { BENCH=true; writeconf; }
bench_off() { BENCH=false; writeconf; }
debug_on() { DEBUG=true; writeconf; }
debug_off() { DEBUG=false; TRACE=false; writeconf; }

include() { local code start fn_name file="$1" filename
	# STOP is a special exit code meaning stop sourcing further files.
	STOP=13
	filename="$(basename "$file")"
	trace "include: $file"
	$BENCH && start="$(now)"
	source "$file" || return $?
	trace "include: $file: sourced"
	fn_name="$(sed -E 's/[[:digit:]]{2}\-(.*)\.bash/\1/' <<< "$filename")"
	$BENCH && bnc "$filename $(since "$start")"
	run $fn_name && return 0
	(( code == STOP )) && MSG=dbg || MSG=log
	$MSG "$file failed with exit code $code, skipping remaining files."
	return "$code"
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

for f in ~/.bashrc.d/*.bash; do
	include "$f" || { msg "Errors encountered, see above."; break; }
done

#
# Footer
#
$SILENT || {
	msg "Loaded .bash_profile in $(since "$START")s"
	for M in "${MSGS[@]}"; do log "$M"; done
}

