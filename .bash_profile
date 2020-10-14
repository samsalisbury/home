#!/usr/bin/env bash

# Shebang line above exists only so shellcheck knows this is bash, not sh.
export BASH_SILENCE_DEPRECATION_WARNING=1

set -o vi

PATH="$HOME/bin:$PATH"
export GOPATH="$HOME"

# Don't attempt host completion. (This allows completion of filenames
# beginning with @ which unfortunately we have to use sometimes.)
shopt -u hostcomplete
complete -r hostname

alias vim=nvim
export EDITOR=nvim

# Bash history settings.
HISTSIZE=10000 # in-memory history items
HISTFILESIZE=2000000
# Append to history instead of overwrite
shopt -s histappend
# Ignore redundant or space commands
HISTCONTROL=ignoreboth
# Ignore more
HISTIGNORE='l:gs:gd:ls:ll:ls -lah:pwd:clear:history'
# Set time format
HISTTIMEFORMAT='%F %T '
# Multiple commands on one line show up as a single line
shopt -s cmdhist
#export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Set display brightness options in the background & suppress all output.
( tmux-dark-mode & ) &> /dev/null
( { match-brightness > /dev/null 2>&1 || true; } & ) &> /dev/null

alias l='ls -lah'
alias t='tree'

# git shortcuts
ga() { if [ -z "$*" ]; then git add .; else git add "$@"; fi; }
alias g='git'
alias gai='git add --interactive'
alias gb='git branch'
alias gt='git tag'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff --patience'
alias gl='git log'
alias gm='git merge'
alias gmt='git mergetool'
alias gp='git pull --ff-only'
alias gru='git remote update'
alias grv='git remote -v'
alias gr='git reset'
alias grh='git reset --hard'
alias gs='git status'
alias gup='git push'

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

