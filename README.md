# OmaSteam

[Metro by Rose](https://github.com/RoseTheFlower/MetroSteam) for Steam, plus an [Omarchy](https://omarchy.org/) `theme-set` hook that writes `custom.css` from the active `colors.toml`.

You do **not** install Metro by Rose separately. This repo is the skin and the hook.

## Install

Needs Steam with [Millennium](https://steambrew.app/) already running once (so `~/.steam/steam/millennium/themes/` exists).

```bash
git clone https://github.com/tempest-chaoscreator/OmaSteam.git ~/src/OmaSteam
~/src/OmaSteam/install.sh --yes
```

`install.sh` copies the skin into `~/.steam/steam/millennium/themes/OmaSteam`, symlinks the hook into `~/.config/omarchy/hooks/theme-set.d/`, writes `custom.css` from the current Omarchy theme, and tells Millennium to use OmaSteam.

If Steam is open, that last step is a GUI-only reload (`SteamClient.Browser.RestartJSContext`) — the same action as Millennium's **Restart Now**. Downloads and games stay up; Friends List may close.

## After that

`omarchy theme set` updates Steam colors. Leave OmaSteam's **Variation** on Standard so the hook owns the palette. Extra Metro options (decals, friends, web pages) still work in Millennium → Themes → OmaSteam.

## Uninstall

```bash
~/src/OmaSteam/uninstall.sh          # remove the theme-set hook
~/src/OmaSteam/uninstall.sh --purge  # also delete the installed theme files
```

Then pick another theme in Steam → Millennium → Themes if you want the stock look.

## Credits

Skin by [Rose](https://github.com/RoseTheFlower/MetroSteam). See `UPSTREAM.md` and `NOTICE`.
