# shellcheck disable=SC2317 # Funcs defined inside funcs are fine.
# shellcheck disable=SC1090,SC1091 # Non-constant source is fine.

autocomplete() {

	source "$HOME/funcs/aliascompletion.bash"


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
}
