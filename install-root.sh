#!/usr/bin/env bash
# @author nate zhou
# @since 2025,2026
# Setup system-wide softwares
#set -x

# install.sh runs this through sudo, so SUDO_USER is the account to configure;
# the uid 1000 lookup only covers a manual root shell
sudoer="${SUDO_USER:-}"
[ "$sudoer" = "root" ] && sudoer=""
[ -n "$sudoer" ] || sudoer="$(grep ':1000:1000:' /etc/passwd | cut -d':' -f1 | head -1)"

HEART_LOCAL="/home/${sudoer}/doc/heart" # machine-local state around this repository
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
hostname="$(cat /etc/hostname)"
ARCH_LIST="${HEART_LOCAL}/package-list/arch-${hostname}.list"

print_err() {
    local RED='\033[0;31m'
    local RESET='\033[0m'
    echo -e ${RED}${1}${RESET} >&2
}

[ ! "$UID" -eq 0 ] && print_err "You must run this script as root." && exit 1
[ -n "$sudoer" ] || { print_err "Cannot tell which user to configure."; exit 1; }

pacman --noconfirm -Sy && pacman -S --noconfirm --needed archlinux-keyring

[ -f "$ARCH_LIST" ] && pacman -S --needed $(cat "$ARCH_LIST") \
    || print_err "package list not found, no packages installed"

pacman -Qi samba >/dev/null 2>&1 && [ -z "$(pdbedit -Lv)" ] \
    && smbpasswd -a "$sudoer"

grep -q '^kvm:' /etc/group && usermod "$sudoer" -aG kvm
grep -q '^libvirt:' /etc/group && usermod "$sudoer" -aG libvirt
grep -q '^termux:' /etc/passwd || useradd -m -G "$sudoer" termux
sudo -u termux mkdir -p -m 700 /home/termux/.ssh
sudo -u termux touch /home/termux/.ssh/authorized_keys
chmod 750 /home/"$sudoer"

[ -f /root/.bash_profile ] && mv /root/.bash_profile{,~}
[ -f /root/.bashrc ] && [ ! -L /root/.bashrc ] && mv /root/.bashrc{,~}

CRYPTKEY="/root/cryptkey"
[ -f "$CRYPTKEY" ] && (chmod -f 400 "$CRYPTKEY"; chattr +i "$CRYPTKEY")

find ${script_dir}/{etc,usr} -type d -exec chmod 755 {} +
find ${script_dir}/{etc,usr} -type f -exec chmod 644 {} +
cp -r --preserve=mode ${script_dir}/{etc,usr} /

timedatectl set-ntp true
systemctl enable --now systemd-timesyncd.service

systemctl enable --now sshd.service
systemctl enable --now systemd-boot-update.service 2>/dev/null
systemctl enable --now bluetooth.service 2>/dev/null
systemctl enable --now tlp.service 2>/dev/null
systemctl enable --now smb.service 2>/dev/null
systemctl enable --now dictd.service 2>/dev/null
systemctl enable --now cronie.service 2>/dev/null

# libvirt only makes sense on bare metal: inside a guest there is no nesting
if pacman -Qi libvirt >/dev/null 2>&1 && ! lscpu | grep -q 'Hypervisor vendor:'; then
    systemctl enable --now libvirtd \
        && virsh net-define /etc/libvirt/qemu/networks/default.xml \
        && virsh net-autostart default
fi

pacman -Qi nvidia-utils > /dev/null 2>&1 \
    && (systemctl enable nvidia-suspend.service 2>/dev/null
        systemctl enable nvidia-hibernate.service 2>/dev/null
        systemctl enable nvidia-resume.service 2>/dev/null
        systemctl enable nvidia-powerd.service 2>/dev/null
        echo "Nvidia power management service will be enabled after a reboot.")

pacman -Qi seatd > /dev/null 2>&1 \
    && usermod -aG seat "$sudoer" \
    && systemctl enable --now seatd.service

systemctl enable --now reflector.timer 2>/dev/null \
    && systemctl start reflector.service

systemctl disable --now paccache.timer

# an optional unit above must not look like a failed run to install.sh
exit 0
