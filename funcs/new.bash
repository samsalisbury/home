
log() { echo "==> $*" 1>&2; }

new() {
	(
		set -eu
		test -n "$1"
		if test -f "$1"; then
			echo "File '$1' already exists, opening as-is..."
			sleep 1
		else
			_new_based_on_extension "$1"
			sleep 1
		fi
	) && {
		if [[ "$EDITOR" = *vim ]]; then
			"$EDITOR" +\$ "$1"
		else
			"$EDITOR" "$1"
		fi
	}
}

_has_extension() { local EXT="$1"; local FILENAME="$2"
	grep -Eq "^.+${EXT}\$" <<< "$FILENAME"
}

_ext_map=()

_get_new_func_from_ext() { local FILENAME="$1"
	local LEN="${#_ext_map[@]}"
	for (( i=0; i<LEN; i+=2 )); do
		local EXT="${_ext_map[$i]}"
		if _has_extension "$EXT" "$FILENAME"; then
			echo "${_ext_map[((i+1))]}"
			return
		fi
	done
	# No match, so use the default new func.
	echo _new_bash_executable
}

_new_based_on_extension() { local FILENAME="$1"
	local FUNC
	FUNC="$(_get_new_func_from_ext "$FILENAME")"
	"$FUNC" "$FILENAME"
}

_new_file() { local FILENAME="$1"; local BODY="$2"
	echo -n "$BODY" | sed -E -e 's/^\t{2}(.*)$/\1/g' -e '/^\t$/d' | tail -n+2 > "$FILENAME"
}

_new_executable() { local FILENAME="$1"; local BODY="$2"
	_new_file "$FILENAME" "$BODY"
	chmod +x "$FILENAME"
}

# Filetype-specific funcs...

_new_bash_executable() {
	_new_executable "$1" '
		#!/usr/bin/env bash

		set -Eeuo pipefail

		echo "Hello World"
	'
}

_ext_map+=(
	.bash _new_bash_library
)
_new_bash_library() {
	# shellcheck disable=SC2016 # I don't want my printf to expand the $1
	_new_file "$1" '
		# Bash library

		my_new_func() {
			echo "$1"
		}
	'
}

_ext_map+=(
	.bats _new_bats_executable
)
_new_bats_executable() {
	_new_executable "$1" '
		#!/usr/bin/env bats

		set -Eeuo pipefail

		@"test number one" {
			echo "Hi!"
		}
	'
	printf '' > "$1"
	chmod +x "$1"
}
