# shellcheck disable=SC1091 # The source does really exist.

extra-funcs() {
	source "$HOME/funcs/new.bash"

	# Temporary func used for recovering accidentally deleted nix config.
	rec() {
		time grep -aFC 200 "$1" /dev/dm-2 > "$2.raw"
	}
}
