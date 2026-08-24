#!/usr/bin/env bash
# Re-apply links that must stay machine-local after stow.

set -u

repo_dir="$(CDPATH= cd -- "$(dirname -- "$(readlink -f -- "$0")")" && pwd)"

# kwm reads this runtime config directly from the dotfiles checkout.
if [ -L "$HOME/.config/kwm" ]; then
    rm -f "$HOME/.config/kwm"
fi
mkdir -p "$HOME/.config/kwm"
kwm_target="$(realpath --relative-to="$HOME/.config/kwm" "$repo_dir/.config/kwm/config.zon")"
ln -sfn "$kwm_target" "$HOME/.config/kwm/config.zon"

# Configs refer to the extensionless wallpaper path.
mkdir -p "$HOME/.local/share"
ln -sfn wallpaper.png "$HOME/.local/share/wallpaper"

# Keep the MPD ignore list tracked without linking the music directory.
mkdir -p "$HOME/mus"
mpdignore_target="$(realpath --relative-to="$HOME/mus" "$repo_dir/mus/.mpdignore")"
ln -sfn "$mpdignore_target" "$HOME/mus/.mpdignore"

# Keep private SSH keys in a real directory, not under stow.
if [ -L "$HOME/.ssh" ]; then
    rm -f "$HOME/.ssh"
    mkdir -p "$HOME/.ssh"
    if [ -d "$HOME/doc/heart/.backup-ssh" ]; then
        cp -a "$HOME/doc/heart/.backup-ssh/." "$HOME/.ssh/"
    fi
fi
mkdir -p "$HOME/.ssh"
if [ -d "$repo_dir/.ssh" ]; then
    for file in config unixchad.conf; do
        [ -e "$HOME/.ssh/$file" ] || cp "$repo_dir/.ssh/$file" "$HOME/.ssh/$file"
    done
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh"/id_* 2>/dev/null || true
fi

# NvChad stores its plugin data outside the tracked configuration.
if [ -L "$HOME/.local/share/nvim" ]; then
    rm -f "$HOME/.local/share/nvim"
    mkdir -p "$HOME/.local/share/nvim"
fi

echo "local links fixed:"
readlink -f "$HOME/.config/kwm/config.zon"
readlink -f "$HOME/.local/share/wallpaper"
