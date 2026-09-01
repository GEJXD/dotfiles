#!/usr/bin/env bash
# @author nate zhou
# @since 2026
# install.sh - bring this repository onto a fresh Arch Linux host

# Runs the three layers in order: packages (install-pkgs.sh) -> user
# (install-user.sh) -> system (install-root.sh). Without '--install' nothing is
# executed at all, every layer only prints what it would do.

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
profiles=()
install=0
skip_root=0
# a failing layer 2/3 must not hide the report at the end
status=0

print_err() {
    local RED='\033[0;31m'
    local RESET='\033[0m'
    echo -e ${RED}${1}${RESET} >&2
}

usage() {
    cat << _EOF_
USAGE
        $(basename $0) [--install] [--skip-root] PROFILE...
        without '--install', only prints what each layer would do
OPTIONS
        --install   run the layers, instead of printing them
        --skip-root   stop before install-root.sh (nothing under /etc is touched)
        -h, --help
        PROFILE     any install-pkgs.sh option, e.g. --base --kwm --mutt --linux linux-lts
                given profiles replace the default set: --base --yay --kwm --ime
DESCRIPTION
        Layer 1  install-pkgs.sh    install packages
        Layer 2  install-user.sh    stow the dotfiles, zsh, crontab, templates
        Layer 3  install-root.sh    copy etc/ and usr/, enable services (root)
        Files that hold credentials are never tracked; they are listed at the end.
_EOF_
    exit 0
}

confirm() {
    [ "$install" -eq 1 ] || { echo "dry run: $*"; return 1; }
    local answer
    read -r -p "run: $* ? (y/n): " answer
    [ "$answer" = "y" ] || [ "$answer" = "Y" ]
}

# install-pkgs.sh needs git and shells out through sudo, install-user.sh needs stow
ensure_bootstrap() {
    local missing=()
    for cmd in git stow sudo; do
        command -v "$cmd" > /dev/null || missing+=("$cmd")
    done
    [ ${#missing[@]} -eq 0 ] && return

    # a host that never synced its databases cannot resolve any target yet
    local refresh=""
    [ -e /var/lib/pacman/sync/core.db ] || refresh="-Sy"

    if [ "$install" -eq 0 ]; then
        echo "would run: sudo pacman $refresh -S --needed ${missing[*]}"
        return
    fi
    if ! command -v sudo > /dev/null; then
        print_err "there is no sudo yet: run 'pacman -S --needed ${missing[*]}' as root, then re-run this as your own user."
        exit 1
    fi
    if confirm "sudo pacman $refresh -S --needed ${missing[*]}"; then
        sudo pacman $refresh -S --needed "${missing[@]}" || {
            print_err "could not install ${missing[*]}"
            exit 1
        }
    else
        print_err "install ${missing[*]} by hand before continuing"
        exit 1
    fi
}

report_leftovers() {
    # Files this repository cannot carry: they hold identities and credentials.
    local fillin=(
        "git identity|${HOME}/.config/git/user.inc"
        "mail sync|${HOME}/.config/isyncrc"
        "mail account|${HOME}/.config/mutt/account-private.muttrc"
        "ssh config|${HOME}/.ssh/config"
        "weather city|${HOME}/.cache/city"
    )
    local missing=() item label path
    echo
    echo "still yours to fill in:"
    for item in "${fillin[@]}"; do
        label="${item%%|*}"; path="${item##*|}"
        if [ -s "$path" ]; then
            printf '        [%-2s] %-14s %s\n' 'ok' "$label" "$path"
        else
            printf '        [  ] %-14s %s\n' "$label" "$path"
            missing+=("$path")
        fi
    done

    local keys="$(find "${HOME}/.ssh" -maxdepth 1 -name 'id_*' ! -name '*.pub' -print -quit 2>/dev/null)"
    printf '        [%-2s] %-14s %s\n' "${keys:+ok}" 'ssh keys' \
        "${HOME}/.ssh/id_* (stow never touches .ssh; copy them out of ~/doc/heart/.backup-ssh)"
    printf '        [%-2s] %-14s %s\n' "$([ -s "${HOME}/doc/.gpg/gpg-keys" ] && echo ok)" 'gpg keys' \
        "imported by install-user.sh when ~/doc/.gpg/gpg-keys exists"
    cat << _EOF_
        [  ] bootloader     /boot/loader/entries/*.example still carries the template
                             resume=UUID; re-run mkinitcpio after editing it
        [  ] package list   run 'sync-config' on the old host, then copy
                             ~/doc/heart/package-list/arch-<hostname>.list over and
                             re-run sudo ./install-root.sh for the full set
_EOF_

    [ ${#missing[@]} -eq 0 ] && return 0
    command -v fzf > /dev/null || return 0
    local answer
    read -r -p "open the empty files in \$EDITOR? (y/n): " answer || return 0
    [ "$answer" = "y" ] || [ "$answer" = "Y" ] || return 0
    "${EDITOR:-vi}" "${missing[@]}"
}

while [ -n "$1" ]; do
    case "$1" in
        --install) install=1 ;;
        --skip-root) skip_root=1 ;;
        -h|--help) usage ;;
        # everything else belongs to install-pkgs.sh, including '--linux linux-lts'
        *) profiles+=("$1") ;;
    esac
    shift
done

# profiles given on the command line replace the default set
[ ${#profiles[@]} -eq 0 ] && profiles=("--base" "--yay" "--kwm" "--ime")

[ "$(id -u)" -eq 0 ] && print_err "run this as your regular user." && exit 1

echo "repository: $script_dir"
echo "profiles:   ${profiles[*]}"

ensure_bootstrap

# a declined layer is skipped for good; only a dry run prints the plan
if [ "$install" -eq 0 ]; then
    "${script_dir}/install-pkgs.sh" "${profiles[@]}"
elif confirm "${script_dir}/install-pkgs.sh --install ${profiles[*]}"; then
    "${script_dir}/install-pkgs.sh" --install "${profiles[@]}" || exit 1
fi

if confirm "${script_dir}/install-user.sh"; then
    "${script_dir}/install-user.sh" || { print_err "install-user.sh failed."; status=1; }
fi

if [ "$skip_root" -eq 1 ]; then
    echo "skipped install-root.sh (--skip-root)"
else
    print_err "install-root.sh overwrites files under /etc and enables services."
    if confirm "${script_dir}/install-root.sh"; then
        sudo "${script_dir}/install-root.sh" || { print_err "install-root.sh failed."; status=1; }
    fi
fi

report_leftovers
exit "$status"
