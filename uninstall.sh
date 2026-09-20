#!/usr/bin/env bash
set -euo pipefail

THEME_NATIVE="OmaSteam"
THEME_DEST="$HOME/.steam/steam/millennium/themes/$THEME_NATIVE"
HOOK_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/hooks/theme-set.d/omahook-omasteam"

rm -f "$HOOK_DEST"
echo "Removed hook $HOOK_DEST"

if [[ "${1:-}" == "--purge" ]]; then
	rm -rf "$THEME_DEST"
	echo "Removed $THEME_DEST"
	echo "If Steam still lists OmaSteam, pick another theme in Millennium → Themes."
else
	echo "Kept $THEME_DEST (pass --purge to delete the installed theme files)."
fi
