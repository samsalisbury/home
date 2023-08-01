packages() {
	has nix && has devbox && {
		export LC_ALL=en_GB.UTF8
		if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
			source "$HOME/.nix-profile/etc/profile.d/nix.sh"
		fi
		eval "$(devbox global shellenv)"
	}
	has nix    || msg "Nix not installed; use 'install_nix'"
	has devbox || msg "Devbox not installed; use 'install_devbox'"
}

install_nix() (
	export NIX_IGNORE_SYMLINK_STORE=1
	LOGDIR=~/.local/share/logs
	mkdir -p $LOGDIR
	LOGFILE=$LOGDIR/nix-install.log
	log "Setting up nix... (Logs in $LOGFILE)"
	NIX_INSTALLER_YES=1 ./init/nix.modified --daemon > $LOGFILE 2>&1
)

install_devbox() {
	./init/devbox.official
}
