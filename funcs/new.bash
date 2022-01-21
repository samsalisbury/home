
new() {
	(
		set -eu
		test -n "$1"
		if test -f "$1"; then
			echo "File '$1' already exists, opening as-is..."
			sleep 1
		else
			printf '#!/usr/bin/env bash\n\nset -Eeuo pipefail\n\n' > "$1"
			chmod +x "$1"
		fi
	) && {
		if [[ "$EDITOR" = *vim ]]; then
			"$EDITOR" +\$ "$1"
		else
			"$EDITOR" "$1"
		fi
	}
}
