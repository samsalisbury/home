# shellcheck disable=SC1091 # The source does really exist.

git-dotfiles() {
	# Git Dotfiles
	source "$HOME/funcs/git-dotfiles.bash" || return 1
	git_dotfiles_configure_shell_hook() {
		# Override 'ga' func to add only modified files by default.
		ga() { if [[ -z "$*" ]]; then git ls-files -m | xargs git add; else git add "$@"; fi; }
		# Add func to checkpoint lazy.nvim plugins.
		lazy() {
			git reset
			git add ~/.config/nvim/lazy-lock.json
			git commit -m "conf(nvim): update plugins"
			git push
		}
	}
	git_dotfiles home "$HOME"
	git_dotfiles system /
}
