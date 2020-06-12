#!/bin/sh

: "${ROOT:=build}"

export ASSUME_ALWAYS_YES=true

mkdir $ROOT
pkg -r $ROOT update -f
pkg -r $ROOT install --no-repo-update \
	FreeBSD-bootloader FreeBSD-kernel-dank FreeBSD-runtime \
	FreeBSD-acpi FreeBSD-autofs FreeBSD-bhyve FreeBSD-ipfw FreeBSD-jail FreeBSD-wpa \
	FreeBSD-libbegemot FreeBSD-libblocksruntime FreeBSD-libbsdstat FreeBSD-libcuse FreeBSD-libcompiler_rt FreeBSD-libexecinfo
pkg -r $ROOT install --no-repo-update \
	pkg \
	drm-devel-kmod iichid openzfs openzfs-kmod \
	runit-faster u2f-devd powerdxx devcpu-data \
	openssh-portable mosh openntpd dhcpcd wpa_supplicant \
	wget curl iperf3 socat rsync git \
	zsh zsh-completions zsh-syntax-highlighting bash fish tmux htop tree pstree ncdu lsof lscpu kakoune fzy fd-find ripgrep hexyl jq srm doas \
	xkeyboard-config evdev-proto libinput py38-evdev evemu evhz drm_info \
	fira firacode cantarell-fonts comic-neue adwaita-icon-theme xdg-utils shared-mime-info bsdisks \
	wayfire wf-shell alacritty wl-clipboard wev grim slurp \
	gnome-terminal nautilus file-roller gedit eog evince gnome-system-monitor cpu-x d-feet dconf-editor \
	gnome-maps gnome-weather celluloid minder-app simple-scan seahorse gucharmap gitg meld lollypop epiphany

mkdir -p $ROOT/proc $ROOT/media $ROOT/home

# pkg -r is not good at running post-install. but chroot doesn't see repos outside..
cp $ROOT/usr/local/etc/pkg.conf.sample $ROOT/usr/local/etc/pkg.conf
cp $ROOT/usr/local/etc/fonts/fonts.conf.sample $ROOT/usr/local/etc/fonts/fonts.conf
chroot $ROOT env LD_LIBRARY_PATH=/usr/local/lib update-mime-database /usr/local/share/mime
chroot $ROOT env LD_LIBRARY_PATH=/usr/local/lib glib-compile-schemas /usr/local/share/glib-2.0/schemas
chroot $ROOT env LD_LIBRARY_PATH=/usr/local/lib gdk-pixbuf-query-loaders --update-cache

# XXX: this was necessary for alacritty (but not on my dev desktop wtf)
mkdir -p $ROOT/etc/fonts
cp $ROOT/usr/local/etc/fonts/fonts.conf.sample $ROOT/etc/fonts/fonts.conf

# root
chroot $ROOT chsh -s /usr/local/bin/zsh root
cp $ROOT/usr/share/skel/dot.zshrc $ROOT/root/.zshrc

# doas
echo 'permit setenv { HOME LC_ALL TERM XDG_RUNTIME_DIR WAYLAND_DISPLAY } :wheel' > "$ROOT/usr/local/etc/doas.conf"

# syslogd complains if they don't already exist
touch $ROOT/var/log/messages $ROOT/var/log/security $ROOT/var/log/auth.log $ROOT/var/log/maillog $ROOT/var/log/cron $ROOT/var/log/debug.log $ROOT/var/log/daemon.log $ROOT/var/log/ppp.log

# we mount tmpfs over there
rm -rf $ROOT/var/run/*

# PAM. note: bsd sed doesn't do that kind of append
gsed -i '/^session.*include.*system/a session		optional	pam_ck_connector.so' $ROOT/etc/pam.d/login

# libinput
mkdir -p $ROOT/usr/local/etc/libinput
cp src/libinput-quirks.conf $ROOT/usr/local/etc/libinput/local-overrides.quirks

# runit+configurate
mkdir -p $ROOT/var/service
ln -sf ../var/run/os-release "$ROOT/etc/os-release"
cp src/rc.toml "$ROOT/etc/rc.toml"
cp ../configurate/target/release/configurate "$ROOT/usr/local/sbin/"
# TODO: package configurate when it gets more mature
