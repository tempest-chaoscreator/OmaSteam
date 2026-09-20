#!/usr/bin/env bash
# Install the OmaSteam Millennium theme and Omarchy theme-set hook.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
THEME_NATIVE="OmaSteam"
STEAM_DIR="$HOME/.steam/steam"
THEME_DEST="$STEAM_DIR/millennium/themes/$THEME_NATIVE"
HOOK_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/hooks/theme-set.d/omahook-omasteam"
MILLENNIUM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/millennium/config.json"
NONINTERACTIVE=0
ENABLE=1

usage() {
	cat <<EOF
Usage: $0 [options]

Install OmaSteam into Millennium's themes folder and wire the Omarchy
theme-set hook that writes custom.css from colors.toml.

Options:
  --yes         Do not prompt
  --no-enable   Copy files and install the hook, but do not switch Steam to OmaSteam
  -h, --help    Show this help
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--yes)
		NONINTERACTIVE=1
		shift
		;;
	--no-enable)
		ENABLE=0
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	esac
done

if [[ ! -d "$STEAM_DIR" ]]; then
	echo "Steam not found at $STEAM_DIR" >&2
	exit 1
fi

mkdir -p "$THEME_DEST" "$(dirname "$HOOK_DEST")"
chmod +x "$REPO_DIR/omahook-omasteam" "$REPO_DIR/install.sh" "$REPO_DIR/uninstall.sh"

# Theme files only -- hook/docs stay in the git checkout.
rsync -a --delete \
	--exclude '.git/' \
	--exclude '.github/' \
	--exclude '.gitignore' \
	--exclude '.gitattributes' \
	--exclude 'install.sh' \
	--exclude 'uninstall.sh' \
	--exclude 'omahook-omasteam' \
	--exclude 'README.md' \
	--exclude 'UPSTREAM.md' \
	--exclude 'NOTICE' \
	--exclude 'custom.css' \
	--exclude 'custom.css.example' \
	"$REPO_DIR/" "$THEME_DEST/"

ln -sfn "$REPO_DIR/omahook-omasteam" "$HOOK_DEST"

# Drop the old MetroSteam-only hook if this machine still has it.
old_hook="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/hooks/theme-set.d/omahook-metrosteam"
if [[ -L "$old_hook" || -f "$old_hook" ]]; then
	rm -f "$old_hook"
	echo "Removed old hook $old_hook"
fi

"$REPO_DIR/omahook-omasteam" || true

enable_theme() {
	if [[ ! -f "$MILLENNIUM_CONFIG" ]]; then
		echo "Millennium config not found at $MILLENNIUM_CONFIG; enable OmaSteam once in Steam → Millennium → Themes." >&2
		return 1
	fi
	python3 - "$MILLENNIUM_CONFIG" "$THEME_NATIVE" <<'PY'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
name = sys.argv[2]
data = json.loads(path.read_text(encoding="utf-8"))
themes = data.setdefault("themes", {})
themes["activeTheme"] = name
path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
print(f"set {path} themes.activeTheme={name}")
PY
}

echo
echo "Installed:"
echo "  theme: $THEME_DEST"
echo "  hook:  $HOOK_DEST"
echo

if [[ "$ENABLE" -eq 1 ]]; then
	enable_theme || true
	if pgrep -x steam >/dev/null 2>&1; then
		steam "steam://millennium/settings/themes/enable/${THEME_NATIVE}" >/dev/null 2>&1
		echo "Asked Millennium to enable and reload OmaSteam."
	else
		echo "Steam is not running. OmaSteam will load on the next Steam start if Millennium config was updated."
	fi
else
	echo "Left the active Millennium theme unchanged (--no-enable)."
	echo "Enable once: Steam → Millennium → Themes → OmaSteam, or:"
	echo "  steam steam://millennium/settings/themes/enable/${THEME_NATIVE}"
fi
