
install_nix() (
	if [[ -d /nix ]]; then
		return 0
	fi

	export NIX_IGNORE_SYMLINK_STORE=1

	LOGDIR=~/.local/share/logs
	mkdir -p $LOGDIR

	LOGFILE=$LOGDIR/nix-install.log
	
	
	log() { printf '%s\n' "$*" 1>&2; }
	
	log "==> Setting up nix... (Logs in $LOGFILE)"
	time NIX_INSTALLER_YES=1 ./init/nix.modified --daemon > $LOGFILE 2>&1
)

setup_devbox_env() {
	if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
		source "$HOME/.nix-profile/etc/profile.d/nix.sh"
	fi
	
	if command -v devbox > /dev/null 2>&1; then
		#devbox global install
		eval "$(devbox global shellenv)"
	else
		echo "Please install devbox to .local/share/bin"
	fi
}

install_nix && setup_devbox_env
