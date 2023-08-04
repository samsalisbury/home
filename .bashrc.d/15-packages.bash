# shellcheck disable=SC1090
DEVBOXENV=~/.local/state/devbox/shellenv
packages() {
	has devbox && {
		[[ -f "$DEVBOXENV" ]] && source "$DEVBOXENV"
		[[ -f "$DEVBOXENV" ]] || write_devbox_shellenv
	}
	has devbox || msg "Devbox not installed; use 'install_devbox'"

	has tailscale || msg "tailscale not installed; use 'install_tailscale'"
}

install_tailscale() {
	BASE=https://pkgs.tailscale.com/stable/ubuntu/jammy
	curl -fsSL $BASE.noarmor.gpg | \
		sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
	curl -fsSL $BASE.tailscale-keyring.list | \
		sudo tee /etc/apt/sources.list.d/tailscale.list

	sudo apt-get update
	sudo apt-get install tailscale
	sudo tailscale up
}

write_devbox_shellenv() {
	echo "==> Updating devbox shell env"
	mkdir -p "$(dirname "$DEVBOXENV")"
	devbox global shellenv > "$DEVBOXENV"
}

add() {
	devbox global add "$1"
	write_devbox_shellenv
}

remove() {
	devbox global rm "$1"
	write_devbox_shellenv
}

install_nix() (
	export NIX_IGNORE_SYMLINK_STORE=1
	LOGDIR=~/.local/share/logs
	mkdir -p $LOGDIR
	LOGFILE=$LOGDIR/nix-install.log
	log "Setting up nix... (Logs in $LOGFILE)"
	NIX_INSTALLER_YES=1 sudo ~/init/nix.modified --daemon > $LOGFILE 2>&1
)

install_devbox() {
	install_nix
	~/init/devbox.official
	devbox global install
}
