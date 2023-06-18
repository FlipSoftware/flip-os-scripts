# Use with https://github.com/casey/just
# and https://github.com/dopplerhq
#
# Common cross-platform shell scripts using
# Just (command runner) and Doppler (env manager)
#
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

# TODO: progress bar with a concise description for every step;

# + ------------------------------------------ +
# | IMPORT PRE-BUILT PACKAGES FROM CHAOTIC-AUR | 
# + ------------------------------------------ +
# ::::::::::::::::::::::::::::::::::::::::::::/
# Keyring from `chaotic-aur` keyserver:
import-chaotic-keyring:
	sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
	sudo pacman-key --lsign-key FBA220DFC880C036
	sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Import chaotic-aur mirrorlist to pacman
import-chaotic-aur:
	just import-chaotic-keyring
	printf '\v[chaotic-aur] \nInclude = /etc/pacman.d/chaotic-mirrorlist \v' >> /etc/pacman.conf

# + -------------------------- +
# | INTEL UNDERVOLT (OPTIONAL) |
# + -------------------------- +
# ::::::::::::::::::::::::::::/
# Apply undervolt to Intel processor newer than Haswell
apply-intel-undervolt:
	@printf '\v{{yellow_b}} Deleting the old cloned directory...\v\n {{reset}}'
	@sudo rm -rf ~/undervolt
	@printf '\v{{green_b}}\t>>{{reset}}{{bold}} Clone from git to ~/undervolt directory...\v\n {{reset}}'
	@git clone https://github.com/georgewhewell/undervolt.git ~/undervolt
	@printf '\v{{green_b}}\t>>{{reset}}{{bold}} Create new undervolt service to systemd \v\n{{reset}}'
	@sudo touch /etc/systemd/system/undervolt.service
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
	\nWantedBy=hybrid-sleep.target' > sudo /etc/systemd/system/undervolt.service
	@printf '\v{{green_b}}\t>>{{reset}}{{bold}} Starting undervolt services...\v\n{{reset}}'
	@sudo systemctl enable --now undervolt.service && sudo ~/undervolt/undervolt.py --read
	@printf '\v{{green_b}}\t>>{{reset}}{{bold}} Undervolt applied successfuly!\v\n{{reset}}'

# + --------------------------------- +
# | DEPLOY A FRESH AND UPDATED SYSTEM |
# + --------------------------------- +
# :::::::::::::::::::::::::::::::::::/
# Install paru AUR helper
install-paru:
	@printf '\v{{yellow_b}} Deleting any previous clone...{{reset}}\v\n'
	rm -rf ~/paru
	git clone https://aur.archlinux.org/paru.git ~/paru
	cd ~/paru && makepkg -si
	rm -rf ~/paru
	@printf '\v{{green_b}} Paru installed successfuly!{{reset}}\v\n'

# Install Rust toolchain and set default to `stable` release
install-rust:
	@sudo pacman -S rustup && rustup default stable

# Refresh and sync new pacman packages
install-base-os:
	@printf '\v{{green}}\t>>{{reset}}{{bold}} Installing system components{{reset}} \v\n'
	just install-rust
	sudo pacman -Syyuuv
	sudo pacman -Sv --noconfirm snap-pac just fish starship cmake micro wl-clipboard rsync rclone git base-devel vulkan-tools
	just install-paru
	just enable-systemd-boot-services
	just set-fish-shell

# Install `fish` as default shell and apply `starship` theme
set-fish-shell:
	sudo su -c "chsh -s /bin/fish $(whoami) < /bin/fish"
	just enable-starship-fish
	
# Install extra common desktop packages
install-desktop-extra:
	paru -Sv --noconfirm noto-fonts noto-fonts-cjk firefox rclone-browser fd exa bottom grex ripgrep xh bat sd dust tealdeer gitui code code-marketplace code-features rclone-browser browsh easyeffects lsp-plugins

# Install extra packages for GNOME Desktop Environment
install-gnome-extra:
	paru -Sv --nonconfirm guake webkit2gtk gnome-browser-connector

# TODO: Configure GNOME
#	set default shorcuts
#	set default tap-to-click
#	set default EasyEffects settings
#	set default guake settings

starship_path := `which starship`
# Enable Starship shell theme for fish
enable-starship-fish:
	@printf '\nsource ({{starship_path}} init fish --print-full-init | psub)' >> ~/.config/fish/config.fish
	@printf '\v{{green_b}}Starship added successfuly!{{reset}}\v\nRestart fish shell or update current shell with:\n{{yellow}}source ~/.config/fish/config.fish{{reset}}'
# Enable Starship shell theme for zsh
enable-starship-zsh:
	@printf 'eval "$(starship init zsh)"' >> ~/.zshrc

# Enable systemd-boot services
enable-systemd-boot-services:
	systemctl enable systemd-boot-check-no-failures.service systemd-boot-update.service

# TODO: Sync and restore a cloud backup (if any) with rclone

# Bash-to-Rust shell utils
ls:
    exa -laT --level=3
top:
    btm -cmT
grep:
    rg
find:
    fd --hidden
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
