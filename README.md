# dotfiles

My Arch Linux dotfiles, powered by [river](https://github.com/riverwm/river) (Wayland).

## Stack

| | |
|:---|:---|
| compositor | river 0.5 + [kwm](https://github.com/kewuaa/kwm) (tiling WM) · river-classic |
| status bar | damblocks (+ dam for river-classic) |
| terminal | foot |
| editor | neovim ([NvChad](https://nvchad.com)) |
| browser | qutebrowser · firefox (Wayland) |
| menu | wmenu |
| input method | fcitx5 (pinyin) |
| audio | pipewire + wob OSD |
| music | mpd · ncmpcpp (visualizer on `8`) |

## Keybindings (river 0.5 + kwm, mod = Super)

| Keys | Action |
|---|---|
| `Super+q` | close focused window |
| `Super+Shift+q` | exit session |
| `Super+g` / `Super+Shift+g` / `Super+Ctrl+g` | screenshot: fullscreen / region / all (copied to clipboard) |
| `Super+p` | launcher (wmenu) |
| `Super+1..9` / `Super+0` | switch tag / all tags |
| `Super+minus` / `Super+equal` | volume ±1% |
| `Super+Ctrl+minus` / `Super+Ctrl+equal` | microphone ±5% |
| `Super+Shift+minus` / `Super+Shift+equal` | volume ±10% |
| `Super+[` / `Super+]` | brightness ±1% |
| `Super+Ctrl+[` / `Super+Ctrl+]` | brightness ±5% |
| `Super+Shift+[` / `Super+Shift+]` | brightness ±10% |
| `Super+Space` | toggle IME |
| `Ctrl+Space` | toggle Chinese IME (fcitx5) |

## Installation

```sh
# clone
git clone git@github.com:GEJXD/dotfiles.git ~/doc/heart/dotfiles
cd ~/doc/heart/dotfiles

# create dirs
mkdir -p ~/.local/{share,state}
mkdir -p ~/.{cache,config/"Code - OSS"}

# link dotfiles
stow -t ~ . --adopt
./install-user.sh        # user-space setup (zsh, crontab, configs)
./fix-local-links.sh      # repair machine-local links after stow

# packages (WSL/physical aware)
./install-pkgs.sh --install --base
sudo ./install-root.sh
```

## Restore Coverage

The tracked configuration is the source of truth for the active setup:

- `.config/kwm/config.zon` — current kwm runtime configuration, including output switching.
- `.config/river-classic/` and `.config/kanshi/` — compositor bindings and the 2K internal + 1080p HDMI layout.
- `.config/nvim/` — the active NvChad configuration and plugin lock file.
- `.config/fcitx5/profile` — the selected keyboard and Pinyin input methods.
- `.config/xdg-desktop-portal-wlr/config` — screenshot output selection.
- `etc/` — tracked system configuration, including the `isw` module option.
- `misc/river-classic-wl-shm-v3.patch` — the local build fix required by the current Wayland protocol package.

`install-user.sh` runs `fix-local-links.sh` after stow. It keeps private SSH keys and generated NvChad plugin data outside the repository while restoring the tracked links.

Runtime and private data stays local: browser history and cookies, QQ/OBS state, fcitx user dictionaries, calendar/news caches, package databases, SSH/GPG private keys, and proxy/account files.

## Notes

- Forked/adapted from [unixchad/dotfiles](https://codeberg.org/unixchad/dotfiles) — upstream files remain GPL-3.0, this repo is MIT.
- Machine-local files are gitignored (`~/.config/git/user.inc`, `proxy.inc`, SSH keys live outside the repo).
- `fix-local-links.sh` re-applies machine-specific links after `stow -R`.
