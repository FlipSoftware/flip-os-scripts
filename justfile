# Use with https://github.com/casey/just
# and https://github.com/dopplerhq
#
# Common cross-platform shell scripts using
# Just (command runner) and Doppler (env manager)
#
# + ------------------------------ +
# | THE SCRIPTS ASSUME YOU'RE ROOT | 
# + ------------------------------ +
# 
# Some reference packages: https://wiki.archlinux.org/title/list_of_applications

# + --------------------------------- +
# | ENVIRONMENT VARIABLES DESCRIPTION | 
# + --------------------------------- +
#


# + -----------------------------------------  +
# | IMPORT PRE-BUILT PACKAGES FROM CHAOTIC-AUR | 
# + ------------------------------------------ +
#
# Keyring from chaotic-aur keyserver:
import-chaotic-keyring:
	pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com && 
	pacman-key --lsign-key FBA220DFC880C036 && 
	pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Import chaotic-aur mirrorlist to pacman
import-chaotic-aur:
	\n[chaotic-aur] \nInclude = /etc/pacman.d/chaotic-mirrorlist \n >> /etc/pacman.conf

# + -------------------------- +
# | INTEL UNDERVOLT (OPTIONAL) |
# + -------------------------- +
#
apply-intel-undervolt:
git clone https://github.com/georgewhewell/undervolt.git /undervolt && 
echo [Unit] \
\nDescription=undervolt \
\nAfter=suspend.target \
\nAfter=hibernate.target \
\nAfter=hybrid-sleep.target \
\n
[Service] \
\nType=oneshot \
\nExecStart=/undervolt/undervolt.py -v --core -150 --cache -150 --gpu -70 \
\n
[Install]
\nWantedBy=multi-user.target \
\nWantedBy=suspend.target \
\nWantedBy=hibernate.target \
\nWantedBy=hybrid-sleep.target \
\nsudo systemctl enable --now undervolt.service
&& ./undervolt/undervolt.py --read

# + --------------------------------- +
# | DEPLOY A FRESH AND UPDATED SYSTEM |
# + --------------------------------- +
#
# Install Rust toolchain
install-rust:
	pacman -S rustup && rustup default stable

# Refresh and sync new pacman packages
install-fresh-os:
pacman -Syyuuv && 
pacman -Sv --noconfirm snap-pac just fish paru cmake micro wl-clipboard rsync rclone git base-devel &&
paru -Sv --noconfirm noto-fonts noto-fonts-cjk firefox code guake fd exa bottom grex ripgrep xh bat sd dust \
tealdeer code code-features browsh

# Enable systemd-boot services
enable-systemd-boot-services:
systemctl enable --now systemd-boot-check-no-failures.service systemd-boot-update.service && 
systemctl status --no-pager systemd-boot-check-no-failures.service systemd-boot-update.service

# Sync and restore a cloud backup (if any) with rclone

# Bash-to-Rust shell utils
ls:
    exa -laT --level=3
top:
    btm -cmT
grep:
    rg
find:
    fd
cat:
    bat
curl:
    xh
du:
    dust
regex:
    grex
nano:
    micro
