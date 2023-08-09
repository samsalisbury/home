# shellcheck disable=SC1090
DEVBOXENV=~/.local/state/devbox/shellenv
packages() {

	#has devbox && {
	#	[[ -f "$DEVBOXENV" ]] && source "$DEVBOXENV"
	#	[[ -f "$DEVBOXENV" ]] || write_devbox_shellenv
	#}
	#has devbox || msg "Devbox not installed; use 'install_devbox'"

	has tailscale || msg "tailscale not installed; use 'install_tailscale'"
}

APT_PACKAGES=(
	coreutils moreutils build-essential net-tools
	mosh 
	git
	golang-1.20-go
)

SNAP_PACKAGES=(
	gh
)

CLASSIC_SNAP_PACKAGES=(
	nvim
)

aptinstall() {
	sudo env DEBIAN_FRONTEND=noninteractive apt install -y "$@"
}

install_apt() {
	sudo apt update && aptinstall "${APT_PACKAGES[@]}"
}

install_snap() {
	sudo snap install "${SNAP_PACKAGES[@]}"
	sudo snap install --classic "${CLASSIC_SNAP_PACKAGES[@]}"
}

install_devenv() {
	echo "trusted-users = root ubuntu" | \
		sudo tee -a /etc/nix/nix.conf && sudo pkill nix-daemon
	nix profile install nixpkgs#cachix
	cachix use devenv
	nix profile install --accept-flake-config tarball+https://install.devenv.sh/latest
}

install_tailscale() {
	BASE=https://pkgs.tailscale.com/stable/ubuntu/jammy
	curl -fsSL $BASE.noarmor.gpg | \
		sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
	curl -fsSL $BASE.tailscale-keyring.list | \
		sudo tee /etc/apt/sources.list.d/tailscale.list

	export DEBIAN_FRONTEND=noninteractive 
	sudo apt-get update
	sudo apt-get install -y tailscale
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
	LOGDIR=~/.local/share/logs
	mkdir -p $LOGDIR
	LOGFILE=$LOGDIR/nix-install.log
	log "Setting up nix... (Logs in $LOGFILE)"
	sudo env NIX_INSTALLER_YES=1 ~/init/nix.modified --daemon | tee $LOGFILE 2>&1
)


install_devbox() {
	install_nix
	~/init/devbox.official
	devbox global install
}
