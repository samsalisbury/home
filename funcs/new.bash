
new() {
	(
		set -eu
		test -n "$1"
		test -f "$1" && { echo "File '$1' already exists."; exit 1; }
		printf '#!/usr/bin/env bash\n\nset -Eeuo pipefail\n\n' > "$1"
		chmod +x "$1"
	) && {
		if [[ "$EDITOR" = *vim ]]; then
			"$EDITOR" +\$ "$1"
		else
			"$EDITOR" "$1"
		fi
	}
}
