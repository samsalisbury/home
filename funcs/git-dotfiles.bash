_gdf_log() { echo "git_dotfiles: $*" 1>&2; }
_gdf_err() {
	_gdf_log "error: $*"
	echo 1
}

GDF_SHELL=(/bin/bash -l)

# git_dotfiles is used for managing dotfiles directly using git.
#
# It creates an alias which launches a new bash shell configured to use
# a custom dot git directory. Use of this custom dot git means that other
# git repositories inside the same filesystem tree are conveniently ignored
# by git operations.
#
# This function should be called from your .bash_profile or .bashrc
#
# E.g.
#
#   git_dotfiles home "$HOME"
#   git_dotfiles system /
git_dotfiles() {
	local NAME="${1:?}" WORKTREE="${2:?}"
	[[ -n "$NAME" ]] || return "$(_gdf_err "name not specified")"
	[[ -n "$WORKTREE" ]] || return "$(_gdf_err "worktree not specified")"

	local ALIAS="$NAME"
	local CUSTOM_DOT_GIT="$WORKTREE/$NAME.git"

	# If this shell has been launched by the above alias...
	if [[ "$GIT_DIR" = "$CUSTOM_DOT_GIT" ]]; then
		_gdf_configure_shell "$NAME" "$WORKTREE"
	else
		# Create the alias to launch a new shell for interacting with this git repo.
		# shellcheck disable=SC2139 # We want the alias definition to be expanded right now.
		alias "$ALIAS=_gdf_launch_shell '$NAME' '$WORKTREE'"
	fi
}

_gdf_launch_shell() {
	local NAME="${1:?}" WORKTREE="${2:?}" CUSTOM_DOT_GIT
	CUSTOM_DOT_GIT="$WORKTREE/$NAME.git"
	[[ -d "$WORKTREE" ]] || return "$(_gdf_err "worktree '$WORKTREE' is not a directory")"
	# If the worktree is not writable by the current user, we'll launch the shell with sudo...
	local SUDO
	[[ -w "$WORKTREE" ]] || SUDO=sudo
	_gdf_init_repo "$NAME" "$WORKTREE" || return 1
	$SUDO /usr/bin/env GIT_DIR="$CUSTOM_DOT_GIT" GIT_WORK_TREE="$WORKTREE" "${GDF_SHELL[@]}"
}

# _gdf_init_repo ensures the worktree is set up as a git repo. It uses subshell semantics
# so it doesn't affect the current shell session.
_gdf_init_repo() (
	local NAME="${1:?}" WORKTREE="${2:?}" CUSTOM_DOT_GIT CUSTOM_DOT_GITIGNORE
	CUSTOM_DOT_GIT="$WORKTREE/$NAME.git"
	CUSTOM_DOT_GITIGNORE="$WORKTREE/$NAME.gitignore"
	cd "$WORKTREE" || return "$(_gdf_err "failed to CD to worktree '$WORKTREE'")"
	export GIT_DIR="$CUSTOM_DOT_GIT"
	[[ -d "$CUSTOM_DOT_GIT" ]] || {
		_gdf_log "first run for $NAME: $WORKTREE"
		git init || return "$(_gdf_err "failed to initialize git repo")"
	}
	[[ -e "$CUSTOM_DOT_GITIGNORE" ]] || {
		_gdf_log "creating $CUSTOM_DOT_GITIGNORE"
		cat >"$CUSTOM_DOT_GITIGNORE" <<-EOF
			### git-dotfiles section (do not edit)
			# Ignore everything except this file by default.
			/*
			!/home.gitignore
			### End of git-dotfiles section.

			# Common ignore patterns.
			*.env
			*.orig
			*.bak
			.DS_Store

			# Files that commonly contain credentials.
			auth.*
			*.ign
			*.json
			*.yaml
			*.yml

			# Unignore some top-level directories, we will re-ignore some of their contents
			# later. (This is needed because once a dir is excluded it can't be re-included.)
			!/.config
			!/.tmux
			/.tmux/plugins
			/.tmux/resurrect
			!/.tmux.conf
			!/.config/nvim
			!/.bashrc.d

			# Unignore some common dotfiles.
			!/.bash_profile
			!/.bashrc
			!/Brewfile
		EOF
	}
	git config status.showUntrackedFiles yes || return "$(_gdf_err "failed to configure git")"
	git config core.excludesFile "$CUSTOM_DOT_GITIGNORE" || return "$(_gdf_err "failed to configure git")"
)

# _gdf_configure_shell is called inside the login shell launched by the alias.
_gdf_configure_shell() {
	local NAME="${1:?}" WORKTREE="${2:?}"
	cd "$WORKTREE" || return "$(_gdf_err "failed to CD to worktree '$WORKTREE'")"
	export PS1="$NAME.git> $PS1"
	if [[ $(type -t git_dotfiles_configure_shell_hook) == function ]]; then
		_gdf_log "running configure shell hook"
		git_dotfiles_configure_shell_hook || _gdf_log "warning: configure shell hook failed"
	else
		_gdf_log "no shell hooks"
	fi
	_gdf_log "shell configured for $NAME.git in $WORKTREE; Ctrl+D to go back to previous shell."
}
