# Sam's dotfiles (home dir)

To set this up on a new machine:

1. Install bash and git.
2. Clone this repo: `git clone https://github.com/samsalisbury/home`
3. ( cd home && git config status.showUntrackedFiles no
3. Move the home/.git dir to ~/home.git
4. Move all the other files from home/ to ~/
5. Paste the script below into your .profile or .bashrc:

```
# Home git directory, for tracking dotfiles etc.
export HOME_GIT_DIR="$HOME/home.git"

# Add 'home' alias to open an interactive subshell configured for managing
# dotfiles etc via git, in my $HOME directory.
alias home='/usr/bin/env GIT_DIR=$HOME_GIT_DIR GIT_WORK_TREE=$HOME bash -l'
# Set up the environment when this profile is loaded in the new subshell.
if [ "$GIT_DIR" = "$HOME_GIT_DIR" ]; then
	cd "$HOME" || true
	export PS1="home.git> $PS1"
	# Override 'ga' func to add only modified files by default.
	ga() { if [ -z "$*" ]; then git ls-files -m | xargs git add; else git add "$@"; fi; }
	echo "==> Git configured for home directory; Ctrl+D to go back to previous shell."
fi
```
