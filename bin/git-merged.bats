#!/usr/bin/env bats

set -Eeuo pipefail

setup() {
	unset GIT_DIR
	unset GIT_WORK_TREE
	cd "$BATS_TEST_TMPDIR"
	rm -rf "test-repo"
	mkdir test-repo
	cd test-repo
	git init
	ok checkout "main"
	ok write
	ok write
}

@test "detect 1 unmerged" {
	create_unmerged_branch unmerged1
	run git merged
	[[ "$status" -eq 0 ]]
	assert_output_contains_line "u unmerged1"
}

@test "detect 1 merged" {
	create_merged_branch merged1
	run git merged
	[[ "$status" -eq 0 ]]
	assert_output_contains_line "m merged1"
}

@test "detect 1 rebased" {
	create_rebased_branch rebased1
	run git merged
	[[ "$status" -eq 0 ]]
	assert_output_contains_line "r rebased1"
}

@test "detect 1 squashed" {
	create_squashed_branch squashed1
	run git merged
	[[ "$status" -eq 0 ]]
	assert_output_contains_line "s squashed1"
}

@test "detect one of each" {
	create_unmerged_branch 	unmerged1
	create_merged_branch   	merged1
	create_rebased_branch  	rebased1
	create_squashed_branch 	squashed1

	run git merged

	[[ "$status" -eq 0 ]]

	WANT_LINES=(
		"u unmerged1"
		"m merged1"
		"r rebased1"
		"s squashed1"
	)

	assert_output_contains_exact_lines "${WANT_LINES[@]}"
}

@test "detect two of each" {
	create_unmerged_branch 	unmerged1
	create_merged_branch   	merged1
	create_rebased_branch  	rebased1
	create_squashed_branch 	squashed1

	create_unmerged_branch 	unmerged2
	create_merged_branch   	merged2
	create_rebased_branch  	rebased2
	create_squashed_branch 	squashed2

	run git merged

	[[ "$status" -eq 0 ]] || {
		echo "OUTPUT='$output'"
		return 1
	}

	WANT_LINES=(
		"u unmerged1"
		"m merged1"
		"r rebased1"
		"s squashed1"
		"u unmerged2"
		"m merged2"
		"r rebased2"
		"s squashed2"
	)

	assert_output_contains_exact_lines "${WANT_LINES[@]}" || {
		echo "OUTPUT='$output'"
		return 1
	}
}

#
# Scenarios
#

create_unmerged_branch() { local NAME="$1" BASE="${2:-main}"
	ok checkout "$BASE"
	ok checkout "$NAME"
	ok write
	ok checkout "$BASE"
}

create_merged_branch() { local NAME="$1" BASE="${2:-main}"
	ok checkout "$BASE"
	ok checkout "$NAME"
	ok write
	ok merge_into "$BASE"
}

create_rebased_branch() { local NAME="$1" BASE="${2:-main}"
	ok checkout "$BASE"
	ok checkout "$NAME"
	ok write
	ok write
	ok checkout "$BASE"
	ok write
	ok checkout "$NAME"
	ok write
	ok rebase_onto "$BASE"
}

create_squashed_branch() { local NAME="$1" BASE="${2:-main}"
	ok checkout "$BASE"
	ok checkout "$NAME"
	ok write
	ok write
	ok squash_onto "$BASE"
}

#
# Assertions
#

assert_output_contains_line() { local LINE="$1"
	grep -E "^${LINE}\$" <<< "$output"
}

# assert_output_contains_exact_lines ensures that the output
# contains each line specified exactly and no more or less.
#
# It does not care what order the lines are in.
assert_output_contains_exact_lines() {
	local REMAINING=()
	IFS=$'\n' read -r -a REMAINING <<< "${output}"
	# HACK: Strip the first element from remaining which is
	# always an empty string for some reason.
	REMAINING=("${REMAINING[@]:1}")
	local GOT_COUNT="${#REMAINING[@]}"
	local WANT_COUNT="${#@}"
	local MISSING=()
	for L in "$@"; do
		if assert_output_contains_line "$L"; then
			# Delete the found line from remaining,
			# so any left can be reported as extra.
			REMAINING=( "${REMAINING[@]/"$L"}" )
			echo "REMAINING - '$L' == '${REMAINING[*]}'"
		else
			MISSING+=("$L")
		fi
	done
return 1
	if \
		[[ ${#MISSING[@]}   -eq 0 ]] &&
		[[ ${#REMAINING[@]} -eq 0 ]]; then
		return 0
	fi
		echo MISSING=${#MISSING[@]}
		echo REMAINING=${#REMAINING[@]}
	if [[ "${#MISSING[@]}" -ne 0 ]]; then
		echo "Lines missing from output:"
		for M in "${MISSING[@]}"; do
			echo "  '$M'"
		done
	fi
	if [[ ${#REMAINING[@]} -ne 0 ]]; then
		echo "Additional unexpected lines found:"
		for R in "${REMAINING[@]}"; do
			echo "  '$R'"
		done
	fi
	return 1
}

assert_output_exactly() { local WANT="$1"
	[[ "$output" == "$WANT" ]]
}

#
# Utils
#

# ok: log a command being run; hide output unless it fails.
ok() {
	RESULT="$("$@" 2>&1)" || {
		echo "FAILED: $RESULT"
		exit 1
	}
}

# write writes a file unique to this branch and increments the
# integer in contains by 1 and commits it to th curent branch.
write() {
	B="$(current_branch)"
	F="$B"
	C="$(cat "$F" 2> /dev/null || echo "0")"
	(( C++ ))
	echo "$C" > "$F"
	git add "$F"
	git commit -m "$B: set $F to $C"
}

checkout() { git checkout "$1" -- || git checkout -b "$1" -- || return 1; }
current_branch() { git rev-parse --abbrev-ref HEAD; }
common_ancestor() { git merge-base "$(current_branch)" "$1"; }

squash() { git reset "$(common_ancestor "$1")" && git add . && git commit -m "squash $1"; }

merge_into()  { C="$(current_branch)" && git checkout "$1" -- && git merge  "$C"; }

# onto performs an action moving commits from the current branch
# onto another branch. This is the opposite of the usual logic
# of performing operations on the local branch with respect to
# another branch. For these tests this semantic makes more
# sense than the usual way.
onto() { local BRANCH="$1"; shift
	C="$(current_branch)" && \
	git checkout -b "rebased-$C" && \
	"$@" "$BRANCH" && \
	git checkout "$BRANCH" -- && \
	git merge --ff-only "rebased-$C"
	git branch -D "rebased-$C"
}

rebase_onto() { onto "$1" git rebase; }

squash_onto() { onto "$1" squash; }
