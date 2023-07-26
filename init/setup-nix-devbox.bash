
# Create a function to add and sync using devbox
add() {
	echo "===> Adding $1 with devbox..."
	devbox global add "$@" || return $?
	devbox_save
}

remove() {
	echo "===> Removing $1 with devbox..."
	devbox global rm "$@" || return $?
	devbox_save
}

devbox_sync() {
	FROM="$1"
	TO="$2"
	echo "===> Syncing $FROM to $TO"
	rsync -a --delete --stats --info=progress2 "$FROM" "$TO" | grep -E '(^Number)|transferred'
}

devbox_save() {
	if [[ ! -f /nix-restored ]]; then
		echo "Not saving as /nix-restored missing."
		return 1
	fi
	devbox_sync /nix/ ~/.nix
	echo "Packages changed; please commit ~/.local/share/devbox/global/default/"
}

devbox_restore() {
	if [[ -f /nix-restored ]]; then
		echo "Packages already restored."
		return 0
	fi
	devbox_sync ~/.nix/ /nix
	touch /nix-restored
	echo "Packages restored."
}

install_nix() (
	export NIX_IGNORE_SYMLINK_STORE=1

	LOGDIR=~/.local/share/logs
	mkdir -p $LOGDIR

	LOGFILE=$LOGDIR/nix-install.log
	
	
	log() { printf '%s\n' "$*" 1>&2; }
	
	if [[ ! -d /nix ]] && [[ -d "$HOME/.nix" ]]; then
		log "==> Setting up nix... (Logs in $LOGFILE)"
		# Install nix
		time NIX_INSTALLER_YES=1 ./init/nix.modified --daemon > $LOGFILE 2>&1
		log "==> Restoring packages..."
		time devbox_restore
	fi	
)

setup_devbox_env() {
	if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
		source "$HOME/.nix-profile/etc/profile.d/nix.sh"
	fi
	
	if command -v devbox > /dev/null 2>&1; then
		eval "$(devbox global shellenv)"
	else
		echo "Please install devbox to .local/share/bin"
	fi
}

install_nix && setup_devbox_env
