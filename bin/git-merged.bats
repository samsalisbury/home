#!/usr/bin/env bats

set -Eeuo pipefail

run_ok() { RESULT="$("$@" 2>&1)" || { echo "FAILED: $RESULT"; return 1; }; echo "OK:" "$@"; }
write() { echo "$1" > "$2" && git add "$2" && git commit -m "$2: $1"; }
checkout() { git checkout "$1" -- || git checkout -b "$1" -- || return 1; }
current_branch() { git rev-parse --abbrev-ref HEAD; }
common_ancestor() { git merge-base "$(current_branch)" "$1"; }

squash() { git reset "$(common_ancestor "$1")" && git add . && git commit -m "squash $1"; }

merge_into()  { C="$(current_branch)" && git checkout "$1" -- && git merge  "$C"; }
rebase_onto() { C="$(current_branch)" && git checkout "$1" -- && git rebase "$C"; }
squash_onto() {
	C="$(current_branch)" && \
	git checkout -b "squashed-$C" && \
	squash "$1" && \
	git checkout "$1" -- && \
	git rebase "squashed-$C"
	# Delete the squashed branch so it doesn't show up as merged.
	git branch -D "squashed-$C"
}

setup() {
	unset GIT_DIR
	unset GIT_WORK_TREE
	cd "$BATS_TEST_TMPDIR"
	rm -rf "test-repo"
	mkdir test-repo
	cd test-repo
	git init
}

@test "detect merged" {
	run_ok checkout "a"
	run_ok write "1a" "a"

	run_ok checkout "b"
	run_ok write "1b" "b"

	run_ok merge_into "a"

	run git merged a
	[[ "$status" -eq 0 ]]
	[[ "$output" = "m b" ]]
}

@test "detect rebased" {
	skip "not implemented"
	run_ok checkout "a"
	run_ok write "1a" "a"
	run_ok write "2a" "a"

	run_ok checkout "b"
	run_ok write "1b" "b"
	run_ok write "2b" "b"

	run_ok rebase_onto "a"

	run git merged a
	[[ "$status" -eq 0 ]]
	[[ "$output" = "r b" ]] || { echo "GOT: $output"; return 1; }
}

@test "detect squashed" {
	run_ok checkout "a"
	run_ok write "1a" "a"
	run_ok write "2a" "a"

	run_ok checkout "b"
	run_ok write "1b" "b"
	run_ok write "2b" "b"

	run_ok squash_onto "a"

	run git merged a
	[[ "$status" -eq 0 ]]
	[[ "$output" = "s b" ]] || { echo "GOT: $output"; return 1; }
}
