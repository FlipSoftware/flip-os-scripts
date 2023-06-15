# Use with https://github.com/casey/just
# and https://github.com/dopplerhq
#
# Common cross-platform shell scripts using
# Just (command runner) and Doppler (env manager)
#
# + ------------------------------ +
# | THE SCRIPTS ASSUME YOU'RE ROOT | 
# + ------------------------------ +
# ::::::::::::::::::::::::::::::::/
# Some reference packages: https://wiki.archlinux.org/title/list_of_applications

# + --------------------------------- +
# | ENVIRONMENT VARIABLES DESCRIPTION | 
# + --------------------------------- +
# :::::::::::::::::::::::::::::::::::/

# + --------------- +
# | COLOR VARIABLES | 
# + --------------- +
# :::::::::::::::::/
# TODO: os_esc := if os_family() == "windows" { "\Esc" } else { "\033" }
# Standard Colors
black := '\033[0;30m'
red := '\033[0;31m'
green := '\033[0;32m'
yellow := '\033[0;33m'
blue := '\033[0;34m'
magenta := '\033[0;35m'
cyan := '\033[0;36m'
white := '\033[0;37m'
# Bold Colors
black_b := '\033[1;30m'
red_b := '\033[1;31m'
green_b := '\033[1;32m'
yellow_b := '\033[1;33m'
blue_b := '\033[1;34m'
magenta_b := '\033[1;35m'
cyan_b := '\033[1;36m'
white_b := '\033[1;37m'
# Underlined Colors
black_u := '\033[4;30m'
red_u := '\033[4;31m'
green_u := '\033[4;32m'
yellow_u := '\033[4;33m'
blue_u := '\033[4;34m'
magenta_u := '\033[4;35m'
cyan_u := '\033[4;36m'
white_u := '\033[4;37m'
# Background Colors
black_bg := '\033[40m'
red_bg := '\033[41m'
green_bg := '\033[42m'
yellow_bg := '\033[43m'
blue_bg := '\033[44m'
magenta_bg := '\033[45m'
cyan_bg := '\033[46m'
white_bg := '\033[47m'
# Bold Background Colors
black_bg_b := '\033[1;40m'
red_bg_b := '\033[1;41m'
green_bg_b := '\033[1;42m'
yellow_bg_b := '\033[1;43m'
blue_bg_b := '\033[1;44m'
magenta_bg_b := '\033[1;45m'
cyan_bg_b := '\033[1;46m'
white_bg_b := '\033[1;47m'
# Bold
bold := '\033[1m'
# Reset
reset := '\033[0m'

# + -----------------------------------------  +
# | IMPORT PRE-BUILT PACKAGES FROM CHAOTIC-AUR | 
# + ------------------------------------------ +
# ::::::::::::::::::::::::::::::::::::::::::::/
# Keyring from chaotic-aur keyserver:
import-chaotic-keyring:
	pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
	pacman-key --lsign-key FBA220DFC880C036
	pacman -U https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst

# Import chaotic-aur mirrorlist to pacman
import-chaotic-aur:
	printf '\v[chaotic-aur] \nInclude = /etc/pacman.d/chaotic-mirrorlist \v' >> /etc/pacman.conf

# + -------------------------- +
# | INTEL UNDERVOLT (OPTIONAL) |
# + -------------------------- +
# ::::::::::::::::::::::::::::/
# Apply undervolt to Intel processor newer than Haswell
apply-intel-undervolt:
	@printf '\v{{yellow_b}} Deleting the old cloned directory...\v\n {{reset}}'
	rm -rf /undervolt
	@printf '\v{{green_b}}\t>>{{reset}}{{bold}} Clone from git to /undervolt directory...\v\n {{reset}}'
	git clone https://github.com/georgewhewell/undervolt.git /undervolt
	@printf '\v{{green_b}}\t>>{{reset}}{{bold}} Create new undervolt service to systemd \v\n{{reset}}'
	@printf '[Unit] \
	\nDescription=undervolt \
	\nAfter=suspend.target \
	\nAfter=hibernate.target \
	\nAfter=hybrid-sleep.target \
	\n \
	\n[Service] \
	\nType=oneshot \
	\nExecStart=/undervolt/undervolt.py -v --core -150 --cache -150 --gpu -70 \
	\n \
	\n[Install] \
	\nWantedBy=multi-user.target \
	\nWantedBy=suspend.target \
	\nWantedBy=hibernate.target \
	\nWantedBy=hybrid-sleep.target' > /etc/systemd/system/undervolt.service
	systemctl enable --now undervolt.service && /undervolt/undervolt.py --read
	@printf '\v{{green_b}}\t>>{{reset}}{{bold}} Undervolt applied successfuly!\v\n{{reset}}'

# + --------------------------------- +
# | DEPLOY A FRESH AND UPDATED SYSTEM |
# + --------------------------------- +
# :::::::::::::::::::::::::::::::::::/
# Install Rust toolchain
install-rust:
	pacman -S rustup && rustup default stable

# Refresh and sync new pacman packages
install-fresh-os:
	pacman -Syyuuv
	pacman -Sv --noconfirm snap-pac just fish starship paru cmake micro wl-clipboard rsync rclone git base-devel
	paru -Sv --noconfirm noto-fonts noto-fonts-cjk firefox rclone-browser fd exa bottom grex ripgrep xh bat sd dust tealdeer gitui code code-marketplace code-features browsh

# Enable Starship shell theme for fish
enable-starship-fish:
	printf '\nsource (/usr/local/bin/starship init fish --print-full-init | psub)' >> ~/.config/fish/config.fish && source ~/.config/fish/config.fish
# Enable Starship shell theme for zsh
enable-starship-zsh:
	printf 'eval "$(starship init zsh)"' >> ~/.zshrc

# Enable systemd-boot services
enable-systemd-boot-services:
	systemctl enable systemd-boot-check-no-failures.service systemd-boot-update.service

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
sed:
	sd
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
