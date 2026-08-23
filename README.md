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

# packages (WSL/physical aware)
./install-pkgs.sh --install --base
sudo ./install-root.sh
```

## Notes

- Forked/adapted from [unixchad/dotfiles](https://codeberg.org/unixchad/dotfiles) — upstream files remain GPL-3.0, this repo is MIT.
- Machine-local files are gitignored (`~/.config/git/user.inc`, `proxy.inc`, SSH keys live outside the repo).
- `~/doc/heart/fix-local-links.sh` re-applies machine-specific symlinks after `stow -R`.
