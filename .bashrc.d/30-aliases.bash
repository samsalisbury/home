# shellcheck disable=SC2317 # Functions defined inside functions are fine.

aliases() {
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
}
