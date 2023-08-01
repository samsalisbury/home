#!/usr/bin/env bash

# shellcheck disable=SC1090 # Ignore "Can't follow non-constant source."

start="$(date +%s.%N)"

PATH="/opt/homebrew/bin:$PATH"
PATH="$HOME/.local/share/bin:$PATH"

: "${DEBUG:=true}"
OS="$(uname | tr '[:upper:]' '[:lower:]')"
log() { printf "%s\n" "$*" >&2; }
dbg() { $DEBUG || return 0; log "DEBUG: $*"; }
has() { command -v "$1" > /dev/null 2>&1; }
os()  { [[ "$OS" == "$1" ]]; }

# STOP is a special exit code meaning stop sourcing further files.
STOP=13

include() { local code fn_name
	dbg "Sourcing $f"
	source "$f" || {
		code=$?; (( code == STOP )) && MSG=dbg || MSG=log
		log "Error sourcing $f"
		return $?
	}
	fn_name="$(echo "${1##.bashrc.d/}" | sed -E 's/[[:digit:]]{2}\-(.*)\.bash/\1/')"
	dbg "Running $fn_name"
	$fn_name && {
		dbg "$fn_name succeeded"
		return 0
	}
	code=$?; (( code == STOP )) && MSG=dbg || MSG=log
	$MSG "$f failed with exit code $code, skipping remaining files."
	return $code
}

for f in .bashrc.d/*.bash; do
	include "$f" || break
done

os linux && has devbox && {
	source ./init/setup-nix-devbox.bash
	export LC_ALL=en_GB.UTF8
}

source "$HOME/funcs/darkmode.bash"


_req_tool() {
	has "$1" && return 0
	if os linux; then
		apt install "$1"
	else
		echo "Please install $1" >&2
	fi
}

if [[ "$(uname)" == "Darwin" ]]; then
	_req_tool gdate
fi
_req_tool bc

# Some scripts and Makefiles this to decide whether to clear the screen.
export AUTOCLEAR=1

# Disable warnings about not being able to follow source includes.
# shellcheck disable=SC1090,SC1091

# Shebang line above exists only so shellcheck knows this is bash, not sh.
export BASH_SILENCE_DEPRECATION_WARNING=1

alias ibrew="arch -x86_64 /usr/local/bin/brew"
alias mbrew="arch -arm64e /opt/homebrew/bin/brew"

set -o vi

source "$HOME/funcs/sourcetool.bash"
source "$HOME/funcs/getport.bash"
source "$HOME/funcs/creds.bash"

## Python
#export PYENV_ROOT="$HOME/.pyenv" 
#export PATH="$PYENV_ROOT/bin:$PATH" 
#eval "$(pyenv init --path)" 
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

#sourcetool "$PYENV_ROOT/plugins/pyenv-virtualenv" \
#	https://github.com/pyenv/pyenv-virtualenv $PYENV_VIRTUALENV_VERSION


# My tools.
PATH="$HOME/bin:$PATH"

# Go
export GOPATH="$HOME/go"
PATH="/usr/local/go/bin:$PATH"
PATH="$GOPATH/bin:$PATH"

# Editor
alias vim=nvim
export VISUAL=nvim
export EDITOR=$VISUAL

# GitHub - auto-load credentials if available.
gh() {
	local BIN
	BIN="$(which gh)"
	(
		creds github > /dev/null 2>&1
		"$BIN" "$@"
	)
}

# Git - auto-load github credentials if available.
git() {
	local BIN
	BIN="$(which git)"
	(
		creds github > /dev/null 2>&1
		"$BIN" "$@"
	)
}

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

# TODO: See if this is what's slow...
## Set display brightness options in the background & suppress all output.
#( tmux-dark-mode & ) &> /dev/null
#( { match-brightness > /dev/null 2>&1 || true; } & ) &> /dev/null

alias l='ls -lahG'
alias t='tree'
alias ag='ag --hidden --ignore .git --ignore .tmp'

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
alias gl1='git log -n1'
alias gl2='git log -n2'
alias gl3='git log -n3'
alias gl4='git log -n4'
alias gl5='git log -n5'
alias gm='git merge'
alias gmt='git mergetool'
alias gp='git pull --ff-only'
alias gru='git remote update'
alias grv='git remote -v'
alias gr='git reset'
alias grh='git reset --hard'
alias gs='git status'
alias gup='git push'
alias gupnv='git push --no-verify'


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

# read_make_targets_dynamic processes the Makefile to expand
# generated targets, giving a much more useful completion
# list.
read_make_targets_dynamic() {
	local MAKEFILE="$1"
	LC_ALL=C make -pRrq -f "$MAKEFILE" : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($1 !~ "^[#.]") {print $1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$'
}

read_make_targets_static() {
	grep -oE '^[a-zA-Z0-9/_-]+:' "$1" \
	| sed 's/://' \
	| tr '\n' ' '
}

read_make_targets() { read_make_targets_dynamic "$1" || read_make_targets_static "$1"; }

# Makefile autocomplete
_makefile_targets() {
    local curr_arg;
    local targets;

    # Find makefile targets available in the current directory
    targets=''
    if [[ -e "$(pwd)/GNUMakefile" ]]; then
		targets=$(read_make_targets GNUMakefile)
    elif [[ -e "$(pwd)/Makefile" ]]; then
		targets=$(read_make_targets Makefile)
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

# Temporary func used for reovering accidentally deleted nix config.
rec() {
	time grep -aFC 200 "$1" /dev/dm-2 > "$2.raw"
}

source "$HOME/funcs/aliascompletion.bash"
source "$HOME/funcs/new.bash"

# Warn if docker containers are running.
docker_is_running() {
	curl --connect-timeout 0.0001 -s --unix-socket /var/run/docker.sock http/_ping > /dev/null 2>&1
}

# Returns the number of running docker containers.
# If docker's not running or there are zero containers,
# the command fails with nonzero exit code.
docker_running_containers_count() {
	local COUNT=0
	docker_is_running && COUNT="$(docker ps -q | wc -l | xargs)" || return 1
	echo "$COUNT"
}

print_docker_status() {
	local COUNT
	COUNT="$(docker_running_containers_count)" || return 0
	[[ "$COUNT" -ne 0 ]] || return 0
	echo "NOTE: You have $COUNT docker containers running. Run 'docker ps;' to see what they are."
}

print_docker_status

# Git Dotfiles
source "$HOME/funcs/git-dotfiles.bash"
git_dotfiles_configure_shell_hook() {
	# Override 'ga' func to add only modified files by default.
	ga() { if [[ -z "$*" ]]; then git ls-files -m | xargs git add; else git add "$@"; fi; }
}
git_dotfiles home "$HOME"
git_dotfiles system /

end="$(date +%s.%N)"

echo -n ".bash_profile runtime: "
echo "$end - $start" | bc -l
