# dotfiles

A personal Arch Linux environment. The default stack is **river 0.5 + kwm**, with river-classic, plain river, sway, dwl and dwm kept bootable. Configuration is managed by GNU Stow through symlinks, and installation is split into three layers — packages → user → system — so each layer can be run and verified on its own.

![kwm stack (default)](misc/kwm.png)

[中文](README.md) ｜ English ｜ reference docs: [docs/](docs/README.md) (Chinese)

**Size**: 440+ tracked files · 155 hand-written scripts in `~/.local/bin` · 60 applications under `.config` · 2700+ commits (since 2025-01).

---

## Contents

1. [What this is](#1-what-this-is)
2. [Repository layout](#2-repository-layout)
3. [Compositor stacks and session lifecycle](#3-compositor-stacks-and-session-lifecycle)
4. [Requirements](#4-requirements)
5. [Installation](#5-installation)
6. [Making changes take effect](#6-making-changes-take-effect)
7. [Packages, mirrors, cache](#7-packages-mirrors-cache)
8. [Status bar and cron-driven signals](#8-status-bar-and-cron-driven-signals)
9. [Script layer](#9-script-layer)
10. [Private data and the `.gitignore` policy](#10-private-data-and-the-gitignore-policy)
11. [Sync and backup](#11-sync-and-backup)
12. [Workflow and validation](#12-workflow-and-validation)
13. [Known issues](#13-known-issues)
14. [Screenshots](#14-screenshots)
15. [Credits and license](#15-credits-and-license)

---

## 1. What this is

### 1.1 Stack

| Role | Choice |
|---|---|
| Compositor / WM | river 0.5 + [kwm](https://github.com/kewuaa/kwm) (default) · river-classic · plain river · sway (fallback) · dwl, dwm (still supported by the scripts) |
| Status bar | [damblocks](.local/bin/damblocks) (pure POSIX shell status generator) → kwm's built-in bar via FIFO / `dam` renderer / swaybar |
| Terminal | foot + footclient (client/server, instant start); abduco + dvtm for tiling sessions |
| Editor | neovim + [NvChad](https://nvchad.com) (versions pinned in `lazy-lock.json`) |
| File manager | lf (with rifle / scope) |
| Browser | firefox (`BROWSER`, foot URL launcher, `Super+q`) |
| Menus / pickers | wmenu (themed through `wmenu-run-color`) · fzf |
| Input method | fcitx5 + Pinyin (anthy for Japanese), `Ctrl+Space` to toggle |
| Audio | pipewire + wireplumber, wob for OSD |
| Music | mpd + ncmpcpp + mpc (`damblocks-mpdd` draws the visualizer) |
| Notifications | dunst |
| Lock / power | swaylock (one config shared by all three stacks + its own PAM policy) · swayidle · tlp · systemd-hibernate |
| Display | kanshi output profiles · swaybg · brightnessctl |
| X11 compat | xwayland-satellite (for X-only clients) + the xorg tool chain |
| Text-first workflow | neomutt + isync · newsboat · calcurse + taskwarrior · ttyper |
| Bar data sources | cron writes cache files, the bar only reads them (see [§8](#8-status-bar-and-cron-driven-signals)) |

### 1.2 Design rules

Written down in [AGENTS.md](AGENTS.md) and actually followed:

- **The repo is the single source of truth.** `git ls-files` is exactly what a fresh install needs to restore. Runtime data, caches and secrets never enter the repo.
- **Symlinks, not copies.** Every tracked config in `$HOME` is a stow link; `readlink -f` leads straight back here. The few programs that read a checkout directly (kwm) are handled explicitly by `fix-local-links.sh`.
- **Three install layers, each independently useful.** `install-pkgs.sh` (what to install) → `install-user.sh` (links + user environment) → `install-root.sh` (`/etc`, services). Nothing blocks anything else, and every layer can print before it acts.
- **Whitelist-style `.gitignore`.** Everything is ignored by default and tracked paths are allow-listed explicitly — so adding a tracked file (especially under `etc/**`) requires a matching `!` rule.
- **No backward-compatibility layers.** Obsolete paths get deleted, not wrapped in fallbacks or migrations.

---

## 2. Repository layout

```text
.
├── .config/              60 application configs, stowed into ~/.config
├── .local/
│   ├── bin/              155 scripts (first in PATH; the directory itself is one symlink)
│   └── share/            wallpaper.png, nvim runtime skeleton, address book template
├── .bashrc .profile .zprofile .zshrc .xinitrc
├── install.sh            one-shot entry point: runs the three layers below, plans by default
├── install-pkgs.sh       packages: role-based profiles, dry-run by default
├── install-user.sh       user: directory skeleton, stow, chsh, crontab, templates
├── install-root.sh       system: /etc + /usr, services (needs root)
├── fix-local-links.sh    re-applies links that must stay machine-local after stow
├── etc/                  system config: pacman, systemd, udev, PAM, kernel params…
├── usr/                  custom keymap us-custom.map.gz
├── boot/                 systemd-boot entry templates (.example)
├── docs/                 detailed docs (keybinds, software, compositors, bar, IME, power, scripts)
├── misc/                 screenshots, a kwm config copy, the river-classic build patch
├── mus/                  MPD metadata only (`.mpdignore`; the music itself is not tracked)
└── AGENTS.md             repository rules for coding agents (structure, style, checks, commits)
```

Directories under `.config/` worth calling out:

| Path | Role |
|---|---|
| `.config/shell/` | `profile.sh` / `aliases.sh` / `functions.sh`, one environment shared by bash and zsh (XDG layout, `EDITOR`, `BROWSER`, `PATH`) |
| `.config/{zsh,bash}/` | per-shell aliases and functions, plus `completions/_scripts.{zsh,bash}` — completions for the hand-written scripts |
| `.config/kwm/config.zon`, `.config/kwim/config.zon` | default stack: bindings, layouts, rules, bar, `startup_cmds`; keyboard repeat rate |
| `.config/river-classic/` | `init` + `bindings` + `modes` + `rules` + `autostart`, maintained in parallel with the kwm stack |
| `.config/river/init`, `.config/sway/` | river entry point (only starts kwm and the FIFO), fallback sway config |
| `.config/proxy/` | collection of per-application proxy templates (git, newsboat, ssh, yt-dlp) |
| `.config/git/config` | `include`s the machine-local `user.inc` / `proxy.inc` (not tracked) |
| `.config/mpd/`, `.config/ncmpcpp/` | music daemon and client |
| `.config/kanshi/config` | monitor profiles (2K internal panel + 1080p HDMI) |

`etc/` is covered in [§7](#7-packages-mirrors-cache), the scripts in [§9](#9-script-layer).

---

## 3. Compositor stacks and session lifecycle

Sessions start from `.local/bin/startw` (defaults to `kwm`, with zsh/bash completions):

```sh
startw                  # = startw kwm
startw kwm              # river 0.5 + kwm (default)
startw river-classic    # classic river
startw river            # plain river, no WM
startw sway             # fallback sway
startw dwl              # dwl (X11 tool chain)
```

Every branch runs `prepare-damblocks-fifo` first, so the status FIFO exists before the compositor reads its bar configuration, then `exec`s `ssh-agent <compositor>` so the session inherits the agent (there is also a user-level `ssh-agent.service`).

| Action | Command / key |
|---|---|
| Exit session | `Super+Shift+q` (→ `exiland -river` / `-river-classic` / `-sway` / `-dwl`, with wmenu confirmation) |
| Reload config | `Super+Shift+r` (all stacks; kwm reloads `config.zon`, river-classic re-runs `init`) |
| Lock | `Super+Shift+w` (`swaylock -f`) |
| Hibernate | `Super+Shift+e` (`hibe`, then `systemctl hibernate` after confirmation) |

Keybinding digest (mod = `Super`; full tables in [docs/keybinds.md](docs/keybinds.md)):

| Key | Action | Key | Action |
|---|---|---|---|
| `Return` | terminal | `Space` | toggle floating / tiling |
| `p` | launcher | `e` | fullscreen |
| `q` | close focused window | `j` / `k` | focus next / previous window |
| `1..9` | switch tag | `Shift+j` / `Shift+k` | swap with next / previous |
| `b` | show / hide bar | `z` | zoom (swap with master) |
| `v` | floating terminal (abduco + dvtm) | `s` | sticky (across tags) |
| `r` | lf inside the terminal | `Ctrl+o` | toggle auto-swallow |
| `g` / `Shift+g` | screenshot full / region (to clipboard) | `Ctrl+Space` | fcitx5 toggle |
| `minus` / `equal` | volume ±1% | `[` / `]` | brightness ±1% |

Details: [docs/compositors.md](docs/compositors.md) (startup flow, autostart list, troubleshooting), [docs/statusbar.md](docs/statusbar.md), [docs/input-method.md](docs/input-method.md), [docs/display-power.md](docs/display-power.md).

---

## 4. Requirements

- Arch Linux (or a derivative that can install Arch packages), with a reasonably fresh `archlinux-keyring`.
- `install-user.sh` checks for: `git` `stow` `systemctl` `gsettings` `gpg` `fzf`. It exits non-zero if any is missing, which stops `install.sh`.
- `install-pkgs.sh` uses three channels:
  - **pacman** — official repositories, via `sudo pacman -S --needed`;
  - **AUR** — via `yay` (`--yay` first reuses a package already built in `~/pkg/yay`); the X apps that no official repository carries (`xob`, `xbanish`) and the `wlroots0.19` dwl needs are here too;
  - **source** — `make` / `zig build`, cloned into `~/.local/src`. Sources default to `codeberg.org/unixchad/<pkg>` (`kwim` comes from `github.com/kewuaa/kwim`); each profile pulls in its own build dependencies (`zig`, `scdoc`, …).
- `install-root.sh` touches `/etc`, creates users and enables services. **Run it only on the intended host, after reading the diff.**

---

## 5. Installation

### 5.1 One command

```sh
git clone git@github.com:GEJXD/dotfiles.git ~/doc/heart/dotfiles
cd ~/doc/heart/dotfiles
./install.sh                                          # print what the three layers would do
./install.sh --install                                # apply, default profiles: --base --yay --kwm --ime
./install.sh --install --base --river-classic --mutt   # other profiles
```

`install.sh` does three things: makes sure `git` / `stow` / `sudo` exist (`pacman -S --needed` otherwise, preceded by `-Sy` on a host that never synced its databases) → runs [5.2](#52-packages-install-pkgssh) / [5.3](#53-user-layer-install-usersh) / [5.4](#54-system-layer-install-rootsh) in order, confirming each layer separately → finishes with the list of private files still left to fill in (opened straight from an fzf picker when available). `--skip-root` leaves `/etc` alone.

The repo lives in `~/doc/heart/dotfiles`. The parent `~/doc/heart/` holds machine-local content (`package-list/`, `.cache/`, `.backup-ssh/`) and does not belong to this repository.

### 5.2 Packages: `install-pkgs.sh`

Without `--install` the script **only prints** the commands it would run, so you can review any profile combination first (including `--yay`: a preview never builds AUR packages).

```sh
./install-pkgs.sh --base --kwm --ime              # dry run: print only
./install-pkgs.sh --install --base --kwm --ime    # actually install
```

| Option | Contents | Channel |
|---|---|---|
| `--base` | kernel + headers, ucode chosen from the CPU vendor, GPU driver chosen from `lspci` (NVIDIA → `nvidia-open-dkms`), `base`/`base-devel`, `linux-firmware`, `lvm2`, NetworkManager, man, `zsh`/`dash`, `sbctl`+`efibootmgr`, openssh, `sudo`, arch-install-scripts, `pacman-contrib`/`reflector`/`rebuild-detector`, neovim, nodejs, monitoring set (btop/nvtop/ncdu/smartmontools/sysstat/iftop/powertop), common CLI (bat/fzf/git/jq/less/lf/libcdio/poppler/rsync/samba/stow/tree/zip/w3m…), firefox (the default browser) | pacman; `abduco`, `dvtm` from source |
| `--yay` | install yay itself (reuses `~/pkg/yay` if present, else clone + `makepkg`); it is built automatically before any profile with AUR packages | source |
| `--kwm` | **default stack**: wayland base set + zig + `wlroots0.20` + scdoc, then builds `river`, `kwim`, `kwm` from source | pacman + AUR + zig |
| `--river` | same as above but without kwm / kwim | pacman + zig |
| `--river-classic` | wayland base set + `wlroots0.20` + `dam` + `river-shifttags` + `river-classic` (applies `misc/river-classic-wl-shm-v3.patch` automatically during the build) | pacman + source + zig |
| `--dwl` | wayland base set + `wlroots0.19` + dwl | AUR + source |
| `--dwm` | X11 stack (xorg, `st`, `dmenu`, `nsxiv`, picom, redshift, clipmenu…) + dwm, with `xob` and `xbanish` from the AUR | pacman + AUR + source |
| `--damblocks` | just the status generator | source |
| `--swayimg` | swayimg | pacman |
| `--ime` / `--fcitx5` | fcitx5 + chinese-addons + gtk/qt bridges + anthy + the jade theme | pacman + source |
| `--mutt` | neomutt, isync, `cyrus-sasl-xoauth2-git` | pacman + AUR |
| `--kvm` | libvirt, dnsmasq, virt-install, virt-manager, qemu-base + spice set | pacman |
| `--bluetooth` | bluez-utils, bluetui | pacman |
| `--coding` | jdk-openjdk + src/doc, tree-sitter-cli, `code` | pacman |
| `--coc-java` | nodejs, npm, jdk21 + src/doc | pacman |
| `--all` | combination of most profiles above (dwm + river-classic + kwm side by side) | — |
| `--linux linux\|linux-lts\|linux-zen` | pick kernel and headers (default `linux`) | — |

`--dwm`, `--dwl`, `--river*` and `--kwm` each pull their audio (pipewire + `wireplumber` + `pipewire-audio` — without a session manager there is no sound), the common Wayland set (including `xdg-desktop-portal(-wlr)`, which `pick-wl-mirror` and the portal file picker need), fonts (Noto set + nerd symbols) and theme dependencies.

### 5.3 User layer: `install-user.sh`

```sh
./install-user.sh      # do not run as root; it already calls stow and fix-local-links.sh
```

In order it will:

1. Check dependencies (see [§4](#4-requirements)).
2. Create the home skeleton with permissions: `~/dls doc mnt mus pic pkg smb tmp vid`, `~/.gnupg`, XDG dirs `~/.local/{share,state}`; `umask 027`.
3. Create state files so cron jobs and the bar have data on first boot: `~/doc/heart/.cache/{wttr,mbsync.cron,newsboat.num,checkupdates-cron.log}`, `~/.local/state/{bash,zsh}/history`, `~/.ollama/history`.
4. Ask for your city → `~/.cache/city` (used by the `wttr` bar module).
5. Reuse existing build caches: `~/.cache/yay` → `~/pkg/yay`, `~/.cache/zig/p` → `~/pkg/zig/p`; link `/data/virt` if present and grant `libvirt-qemu` an ACL.
6. **`stow -R --adopt --ignore='^\.ssh'`** to link the repo into `$HOME`; `--adopt` converts pre-existing files of the same name into links. `~/.ssh` is ignored by stow and handled by `fix-local-links.sh`.
7. Run `fix-local-links.sh` ([§10](#10-private-data-and-the-gitignore-policy)).
8. `chsh -s /usr/bin/zsh`; `systemctl --user enable ssh-agent.service`; set `Adwaita-dark` when `gsettings` exists.
9. Copy private templates when missing: `~/.ssh/proxy.conf`, `btop.conf`, `git/proxy.inc`, `mutt/account*.muttrc`, `newsboat/{proxy.conf,urls}`, `yt-dlp/proxy.conf`, `isyncrc` (the git identity file `user.inc` has no template — write it yourself).
10. Import GPG keys from `~/doc/.gpg/gpg-keys` through an fzf picker, if that directory exists.
11. Load a crontab: `~/.config/crontab.backup` (written by `sync-config`) if present, otherwise [.config/crontab.example](.config/crontab.example).
12. Import the shipped holiday calendar with `calcurse -i example.ical` when the calendar is empty; refresh the fontconfig cache; apply the wallpaper with `setwall`.
13. Ask whether to run `sync-config-root` (mirrors the shell setup for root).

A real `~/.bashrc` / `~/.bash_profile` is renamed to `~/.bashrc~` so the link can take its place.

### 5.4 System layer: `install-root.sh`

```sh
sudo ./install-root.sh
```

What it does (**destructive — read the script and the diff first**):

| Group | Actions |
|---|---|
| Packages | `pacman -Sy` + refresh `archlinux-keyring`; install from the **per-host list** `~/doc/heart/package-list/arch-$(hostname).list` (generated by `sync-config` from `pacman -Qenq`, kept outside this repo; a missing file only prints an error and the script continues) |
| Filesystem | `chmod 755/644` over `etc/` and `usr/`, then `cp -r --preserve=mode … /` (overwrites same-named system files) |
| Users / perms | add `$SUDO_USER` (falls back to uid 1000, and the script exits when neither identifies an account) to `kvm`, `libvirt`; create the `termux` user with `authorized_keys`; tighten `$HOME` to 750; `chmod 400` + `chattr +i` on `/root/cryptkey` if present |
| Time | `timedatectl set-ntp true` + enable `systemd-timesyncd` |
| Services | `sshd`, `systemd-boot-update`, `bluetooth`, `tlp`, `smb`, `dictd`, `cronie` (skipped when the package is absent); enable `libvirtd` and define/autostart the default network on bare metal; four NVIDIA power services when `nvidia-utils` is installed; `seatd` plus the `seat` group when present |
| Mirrors / cache | enable `reflector.timer` and refresh the mirrorlist once; disable `paccache.timer` (cache is handled by `rmcache` / `sync-pkg` instead) |
| Other | `smbpasswd -a` when samba is installed with no users |

### 5.5 After installation

```sh
exec $SHELL            # or log out and back in so profile.sh applies
./fix-local-links.sh   # re-run this after any manual stow
startw                 # enter the graphical session
```

---

## 6. Making changes take effect

| Change | How it lands |
|---|---|
| `.config/kwm/config.zon` | `Super+Shift+r`. `~/.config/kwm/config.zon` is a relative link into the repo, so edits are live immediately; a few options still need a session restart |
| `.config/river-classic/*`, `.config/sway/*` | `Super+Shift+r` (re-run `init` / reload sway) |
| `.config/foot/*`, `.config/shell/*`, `.zshrc`, `.bashrc` | new terminal, or `source ~/.config/shell/profile.sh` |
| `.local/bin/*` | immediately (`~/.local/bin` is one symlink to the repo, scripts are read on every run) |
| cron-driven bar modules (weather, unread counts) | next cron run, or invoke the matching `*-cron` script |
| `etc/**` | `sudo ./install-root.sh` (or a targeted `sudo cp` + `sudo systemctl restart <unit>`), sometimes a reboot |
| `.config/nvim/` | restart nvim; plugin changes go through lazy.nvim and `lazy-lock.json` should be committed together |
| behaviour / keybindings changed | update the matching file in `docs/` (the two are required to agree) |

---

## 7. Packages, mirrors, cache

### 7.1 Mirrors are managed by reflector

The rules live only in [etc/xdg/reflector/reflector.conf](etc/xdg/reflector/reflector.conf) and are shared by the systemd timer and the manual script, so both paths produce the same list:

```text
--save /etc/pacman.d/mirrorlist
--protocol https --completion-percent 100 --score 20   # complete https mirrors, top 20 by MirrorStatus score
--fastest 5                                            # keep the 5 fastest by measured rate (matches ParallelDownloads=5)
--download-timeout 30                                  # rating downloads extra.db (~9 MiB); the 5s default would zero out slow mirrors
--verbose
```

| Trigger | Notes |
|---|---|
| `reflector.timer` | weekly (`Persistent=true` catches up, plus up to 12h randomized delay); `install-root.sh` enables it |
| `refresh-mirror` | manual refresh; `-l` shows the current list, `-t` only ranks and prints without writing (no sudo needed) |

Four things to know:

- rating really downloads: roughly 20 × 9 MiB per run, 1–2 minutes;
- the write is **a full replacement**, so `ala` (Arch Linux Archive) lines and hand-written local mirrors are lost — re-run `ala` after a refresh;
- on failure (mirrorstatus API unreachable or no matching mirror) reflector exits and leaves the mirrorlist untouched;
- to prefer domestic (China) mirrors instead, replace `--score 20` with `--country China --score 20` (there are about 6 complete https mirrors there).

The `lsml` alias prints the first five servers in use.

### 7.2 The rest of the pacman side

| File | Role |
|---|---|
| `etc/pacman.conf` | 5 parallel downloads, `CheckSpace`, … |
| `etc/pacman.d/hooks/checkupdates-cron.hook` | after every upgrade, runs `checkupdates-cron --now` as the regular user so the bar's pending count is right away |
| `etc/pacman.d/hooks/default-shell-symlink.hook` | points `/bin/sh` back at dash after bash upgrades its package scripts |
| `paccache.timer` | disabled by `install-root.sh`; cleanup via `rmcache`, offline package pool via `sync-pkg` |
| `~/doc/heart/package-list/arch-<host>.list` | the full list of explicitly installed packages per machine, used by `install-root.sh` to restore; complements the role-based profiles in `install-pkgs.sh` |

---

## 8. Status bar and cron-driven signals

The status line comes from `.local/bin/damblocks` (per-module refresh intervals and signals, only updates what changed, works on Wayland, Xorg and the tty), then consumed per stack: kwm reads `${XDG_RUNTIME_DIR}/damblocks.fifo`, river-classic runs `damblocks | dam`, sway uses swaybar.

The key convention: **heavy signals never run inside the bar process**. Cron writes cache files and damblocks only reads them, so refreshing stays fast and can never block on the network.

```cron
*/15 * * * * ~/.local/bin/wttr --cron                # weather → cache
*/15 * * * * ~/.local/bin/checkupdates-cron          # pending update count
*/15 * * * * ~/.local/bin/newsboat-update-cron       # RSS fetch
*/15 * * * * ~/.local/bin/newsboat-num-cron          # unread count
*/15 * * * * ~/.local/bin/calcurse-num-cron          # event count
*/15 * * * * ~/.local/bin/sync-config-cron           # package lists / crontab backup (throttled to 12h)
```

Full list: [.config/crontab.example](.config/crontab.example). FIFO startup ordering, surviving SIGPIPE, and how `dam-run` coordinates the stacks with `pgrep` + `flock`: [docs/statusbar.md](docs/statusbar.md).

---

## 9. Script layer

`~/.local/bin` is a symlink to the repo; the 155 POSIX shell scripts split by responsibility:

| Category | Representative scripts |
|---|---|
| Session / power | `startw`, `exiland`, `hibe`, `reload`, `mag`, `wsk` |
| Audio / brightness / OSD | `audio` (wireplumber), `bright`, `speaker`, `wobd`, `xobd` |
| Screenshot / clipboard | `shoot` (grim+slurp), `clip`, `capture`, `picker`, `cropper` |
| Status bar | `damblocks`, `dam-run`, `damblocks-mpdd`, `prepare-damblocks-fifo` |
| System / updates | `lsupdates`, `checkupdates-cron`, `refresh-mirror`, `rmcache`, `rmorphan`, `sharepkg`, `os`, `fanmode` |
| Mail / RSS / calendar | `mbs`, `mbs-cron`, `mutt`, `muttauth`, `news`, `newsboat-*-cron`, `dcal`, `calen`, `wttr`, `pomodoro` |
| Media | `lsmus`, `yta`, `ytv`, `id3title`, `img2vid`, `mediatrim`, `gif`, `selwall`, `randwall`, `setwall` |
| Knowledge / docs | `wiki` (arch-wiki-docs), `jdoc`, `books`, `address`, `emoji`, `heart` |
| Sync / backup | the `sync-*` family (see [§11](#11-sync-and-backup)), `backup-gpg`, `backup-mail`, `gpg-*` |
| Proxy / network | `prox`, `getprox`, `phone` |
| Menu theming | `wmenu-color`, `wmenu-run-color`, `colors.sh` |

House style: keep the shebang, four-space indentation, lowercase locals and uppercase constants, always quote paths; scripts that take options get completions in `.config/{zsh,bash}/completions/_scripts.{zsh,bash}`. Full cheat sheet: [docs/scripts.md](docs/scripts.md).

---

## 10. Private data and the `.gitignore` policy

`.gitignore` is a **whitelist**: line 2 is `*`, then tracked paths are explicitly re-allowed with `!`. So any new tracked file (especially under `etc/**`) needs a matching rule, otherwise `git add` will silently skip it.

Untracked data comes in two flavours:

**Runtime data** (regenerable by definition): browser history and cookies, the NvChad plugin tree (`~/.local/share/nvim`), fcitx5 user dictionaries, calendar/news/weather caches, package databases, zig/go caches.

**Secrets** (never tracked, filled in after install):

| Template | Destination | Contents |
|---|---|---|
| `.config/git/proxy.inc.example` (also under `.config/proxy/git/`) | `~/.config/git/proxy.inc` | git proxy; the sibling `user.inc` (git identity) has **no template and must be written by hand** — `~/.config/git/config` `include`s both |
| `.config/newsboat/{proxy.conf,urls}.example` | same directory | feeds and proxy |
| `.config/yt-dlp/proxy.conf.example` | `~/.config/yt-dlp/proxy.conf` | download proxy |
| `.config/isyncrc.example` | `~/.config/isyncrc` | IMAP/SMTP accounts |
| `.config/mutt/account.md` (how-to) | `~/.config/mutt/account-{private,public}.muttrc` | credentials stay out of the repo; `install-user.sh` seeds placeholders you fill in following `account.md` (`account-unixchad.muttrc` is the tracked sample account) |
| `.ssh/proxy.conf.example` | `~/.ssh/proxy.conf` | SSH proxy |
| `.config/btop/btop.conf.example` | `~/.config/btop/btop.conf` | monitor preferences |
| `.config/crontab.example` | `crontab -` (loaded by `install-user.sh`) | scheduled jobs |
| `.config/Code - OSS/User/settings.json.example`, `.config/VSCodium/…` | respective `settings.json` | editor settings |
| `.local/share/address/address.example` | same name without `.example` | address book |
| `boot/loader/{loader.conf,entries/arch.conf}.example` | `/boot/loader/…` | systemd-boot entries (incl. the `resume=` UUID) |
| `etc/samba/smb.conf.example` | `/etc/samba/smb.conf` | Samba shares |

`fix-local-links.sh` puts back everything that must stay machine-local after each stow: `~/.config/kwm/config.zon` becomes a relative link into the repo, `~/.local/share/wallpaper` → `wallpaper.png`, `~/mus/.mpdignore` points back at the repo, `~/.ssh` is restored as a real directory (recoverable from `~/doc/heart/.backup-ssh`) with permissions fixed, and `~/.local/share/nvim` is guaranteed to be a real directory rather than a link.

---

## 11. Sync and backup

Multiple machines (including a `termux` user pulling data) stay in sync through the rsync family. Every script follows the same habit: **print a `--dry-run` first, then ask before applying**.

| Script | Direction | Contents |
|---|---|---|
| `sync-config` | host → repo | writes `package-list/{arch,aur,code}-<hostname>.list`, backs up the crontab to `~/.config/crontab.backup`, redacts the address book for screen casting |
| `sync-config-cron` | throttle | runs `sync-config` at most once per 12h, called every 15 min by cron |
| `sync-config-sys` | `/etc` → repo | pulls tracked system files back for commit (`pacman.conf`, `mirrorlist`, hooks, `xdg/reflector/reflector.conf`, `tlp.conf`, …) |
| `sync-config-root` | repo → `/root/heart` | mirrors the shell / lf / fzf / vim setup for root |
| `sync-pkg` / `-cron` / `-reverse` | package pool ⇄ `~/pkg/pacman` | pacman cache mirror, weekly; pairs with `sharepkg` as a LAN HTTP repo |
| `sync-data` | `~/{doc,mus,pic,vid,pkg}` → `/data/` | cold backup to the local bulk disk |
| `sync-to <ip>` | same → remote host | LAN directory sync |
| `sync-usb` / `-all` | → volumes labelled `usb-*` | offline backup (set labels with `e2label`) |
| `sync-notify` | — | `sync` plus a desktop notification (alias `sync`) |

To refresh one signal manually, just run the matching `*-cron` script — they compute once and write the cache.

---

## 12. Workflow and validation

There is no build artefact and no automated test suite; verification is syntax checks plus trying it on a real machine:

```sh
# 1) syntax
bash -n install-user.sh install-root.sh fix-local-links.sh
sh -n install-pkgs.sh .local/bin/<script you touched>

# 2) whitespace / conflict markers
git diff --check

# 3) what the links would change (preview only)
stow -n -v -t "$HOME" .

# 4) after stowing, confirm the important links still point into the repo
readlink -f ~/.config/kwm/config.zon ~/.local/share/wallpaper ~/mus/.mpdignore
```

Anything behaviour-related (compositor, keybindings, bar, services) has to be exercised in a live session, and the matching `docs/` file updated.

Commit convention (consistent with the 2700+ commits in history): Conventional Commits, short imperative subject, scope where useful — `feat(input): …`, `fix(bar): …`, `docs: …`, `chore(foot): …`. One change per commit; when `/etc` or services are involved, name the affected system components in the body.

---

## 13. Known issues

- reflector replaces the mirrorlist, so ALA lines are lost ([§7.1](#71-mirrors-are-managed-by-reflector)).
- `install-root.sh` creates a `termux` user — it is written for one specific machine; audit every item on a new environment.
- Startup troubleshooting (blank bar, FIFO, the portal error that breaks Electron file pickers, kwm `execve failed`) lives in [docs/compositors.md](docs/compositors.md).

---

## 14. Screenshots

| Stack | Image |
|---|---|
| kwm (river 0.5, default) | ![kwm](misc/kwm.png) |
| river-classic | ![river-classic](misc/river-classic.png) |
| sway (fallback) | ![sway](misc/sway.png) |
| dwm (X11) | ![dwm](misc/dwm.png) |
| dwl | ![dwl](misc/dwl.png) |

---

## 15. Credits and license

- Started as a fork of [unixchad/dotfiles](https://codeberg.org/unixchad/dotfiles) (GPL-3.0; upstream signing key in [unixchad.asc](unixchad.asc)) and heavily rewritten. This repository is MIT — see [LICENSE](LICENSE); upstream files keep their original license.
- damblocks, dam, dwm/dwl/st and the other source packages default to the upstream author's codeberg repositories (see `check_src` in `install-pkgs.sh`).
- Structure, coding style and commit rules: [AGENTS.md](AGENTS.md). Feature documentation: [docs/](docs/README.md).
