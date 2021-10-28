#!/usr/bin/env bash

# Disable warnings about not being able to follow source includes.
# shellcheck disable=SC1090,SC1091

# Shebang line above exists only so shellcheck knows this is bash, not sh.
export BASH_SILENCE_DEPRECATION_WARNING=1

source "$HOME/funcs/darkmode.bash"
source "$HOME/funcs/sourcetool.bash"

set -o vi

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

PYENV_VERSION=444088b1db11744365d93a24cc0ce68d3d54a089
PYENV_VIRTUALENV_VERSION=f95d6a9bee20076f6dc2298878ecfb1b2f6a972c

sourcetool "$PYENV_ROOT" \
	https://github.com/pyenv/pyenv $PYENV_VERSION

sourcetool "$PYENV_ROOT/plugins/pyenv-virtualenv" \
	https://github.com/pyenv/pyenv-virtualenv $PYENV_VIRTUALENV_VERSION

eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# My tools.
PATH="$HOME/bin:$PATH"

# Go
export GOPATH="$HOME"

#alias vim=nvim
export VISUAL=vim
export EDITOR=$VISUAL

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

alias l='ls -lahG'
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

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Ruby
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
if command -v rbenv > /dev/null 2>&1; then
	eval "$(rbenv init -)"
fi

# Python
if command -v pyenv > /dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

export PATH="/usr/local/opt/postgresql@12/bin:$PATH"

# Autocompleters
#

# Don't attempt host completion. (This allows completion of filenames
# beginning with @ which unfortunately we have to use sometimes.)
shopt -u hostcomplete
#complete -r hostname

# AWS autocomplete
complete -C '/usr/local/bin/aws_completer' aws

# Makefile autocomplete
function _makefile_targets {
    local curr_arg;
    local targets;

    # Find makefile targets available in the current directory
    targets=''
    if [[ -e "$(pwd)/Makefile" ]]; then
        targets=$( \
            grep -oE '^[a-zA-Z0-9_-]+:' Makefile \
            | sed 's/://' \
            | tr '\n' ' ' \
        )
    fi

    # Filter targets based on user input to the bash completion
    curr_arg=${COMP_WORDS[COMP_CWORD]}
	# shellcheck disable=SC2207,SC2086
    COMPREPLY=( $(compgen -W "${targets[@]}" -- $curr_arg ) );
}
complete -F _makefile_targets make

# Git completion
GIT_COMPLETION="$HOME/import/git-completion.bash"
GIT_COMPLETION_VERSION=223a1bfb5821387981c700654e4edd2443c5a7fc
if [ ! -f "$GIT_COMPLETION" ]; then
	echo "==> Attempting to install git-completion.bash @$GIT_COMPLETION_VERSION"
	curl --create-dirs -o "$GIT_COMPLETION" https://raw.githubusercontent.com/git/git/$GIT_COMPLETION_VERSION/contrib/completion/git-completion.bash
fi

source "$GIT_COMPLETION"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
