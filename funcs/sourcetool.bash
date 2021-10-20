# sourcetool installs a source-code based tool by checking out its repo
# into a specified directory at a specified commit.
# TODO: Consider making this dir read-only since it's not meant to be used
#       as a dev directory.
# TODO: Detect modified files and error out if found.
# TODO: Detect new files and error out if found.
# TODO: Detect if downgrading and warn if so.
# TODO: Detect non-ff upgrades and warn if so.
# TODO: Detect if upgrades available and inform user.
sourcetool() {
	local DIR REPO REVISION
	DIR="$1"
	REPO="$2"
	REVISION="$3"
	if ! [ -d "$DIR" ]; then
		mkdir -p "$DIR"
		git clone "$REPO" "$DIR"
		(
			cd "$DIR"
			git reset --hard "$REVISION"
		)
	fi
}
