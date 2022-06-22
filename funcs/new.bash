
log() { echo "==> $*" 1>&2; }

new() {
	(
		set -eu
		test -n "$1"
		if test -f "$1"; then
			log "File '$1' already exists, opening as-is..."
		else
			local DIR
			DIR="$(dirname "$1")"
			[[ -d "$DIR" ]] || mkdir -p "$DIR"
			_new_based_on_extension "$1"
		fi
	) && {
		sleep 1 # Pause so log messages can be seen.
		if [[ "$EDITOR" = *vim ]]; then
			"$EDITOR" +\$ "$1"
		else
			"$EDITOR" "$1"
		fi
	}
}

_has_extension() { local EXT="$1"; local FILENAME="$2"
	grep -Eq "^.*${EXT}\$" <<< "$FILENAME"
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
	log "Creating new file: $1"
	TRIMMED="$(echo -n "$BODY" | sed -E -e 's/^\t{2}(.*)$/\1/g' -e '/^\t$/d' | tail -n +2)"
	echo -n "$TRIMMED" > "$FILENAME"
}

_new_executable() { local FILENAME="$1"; local BODY="$2"
	_new_file "$FILENAME" "$BODY"
	log "Making it executable..."
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

		@test "new test" {
			echo "Hi!"
		}
	'
}

_ext_map+=(
	Makefile    _new_makefile
	GNUmakefile _new_makefile
)
_new_makefile() {
	_new_file "$1" '
		SHELL := /usr/bin/env bash -euo pipefail -c

		target:
			@echo recipe
	'
}


_get_go_package() {
	local FILE="$1"
	local DIR
	DIR="$(dirname "$1")"

	# First see if there's a package already in this dir.
	local GOFILE
	if GOFILE="$(find "$DIR" -name "*.go" -maxdepth 1 -mindepth 1 2> /dev/null | head -n1)"; then
		log "Found go file '$GOFILE' in $DIR/"
		if [[ -n "$GOFILE" ]]; then
			if PACKAGE="$(ggrep -Pom 1 '^package \K\w+' "$GOFILE")"; then
				log "Package '$PACKAGE' found in $DIR"
				echo "$PACKAGE"
				return 0
			else
				log "No package found in '$GOFILE'"
			fi
		else
			log "No go files found in $DIR/"
		fi
	fi

	# If not, is this file called 'main.go'?
	if [[ "$FILE" = "main.go" ]]; then
		log "File is 'main.go' so using package name 'main'"
		echo "main"
		return 0
	fi

	# Otherwise us the directory's name.
	local DIRNAME
	if DIRNAME="$(basename "$(realpath "$DIR")")"; then
		log "Using directory name '$DIRNAME' as go package name."
		echo "$DIRNAME"
		return 0
	fi
	log "Error: Unable to guess package name for $1"
	return 1
}

_ext_map+=(
	_test.go _new_go_test
)
_new_go_test() {
	local PACKAGE
	PACKAGE="$(_get_go_package "$1")" || return 1
	_new_file "$1" '
		package '"$PACKAGE"'

		import "testing"

		func TestBlahBlah(t *testing.T) {
			t.Log("Hi!")
		}
	'
}

_ext_map+=(
	.go _new_go_file
)
_new_go_file() {
	local PACKAGE
	PACKAGE="$(_get_go_package "$1")" || return 1
	_new_file "$1" '
		package '"$PACKAGE"'

		// TODO
	'
}

