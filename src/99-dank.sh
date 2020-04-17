#!/bin/sh

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

PATH=/usr/local/bin:$PATH

# Don't send ESC on function-key 62/63 (left/right command key)
kbdcontrol -f 62 '' > /dev/null 2>&1
kbdcontrol -f 63 '' > /dev/null 2>&1
export TERM=xterm

# we mounted tmpfs to /root
cp /usr/share/skel/dot.zshrc /root/.zshrc

dialog --backtitle "DankBSD Live" --title "Welcome" --ok-label "Yes" --cancel-label "No" --yesno "Welcome to DankBSD! Would you like to load a graphics driver?" 0 0

case $? in
$DIALOG_OK)
	kldload i915kms amdgpu iichid

	if [ ! -e /dev/dri/card0 ]; then
		echo "  >> No GPUs found after loading Intel and AMD GPU drivers!! :( <<"
		exit 1
	fi

	pw useradd live -u 42069 -g wheel -G operator,video -m -s /usr/local/bin/zsh -w none
	mkdir -p ~live/.config
	cp -r /root/alacritty ~live/.config/

	echo '[core]' > ~live/.config/wayfire.ini
	echo 'xwayland = false' >> ~live/.config/wayfire.ini
	echo 'plugins = resize command vswitch oswitch grid window-rules autostart expo wrot place invert animate move switcher fast-switcher cube wobbly decoration alpha idle vswipe' >> ~live/.config/wayfire.ini
	echo '[input]' >> ~live/.config/wayfire.ini
	echo 'natural_scroll = true' >> ~live/.config/wayfire.ini
	echo 'cursor_theme = Adwaita' >> ~live/.config/wayfire.ini
	echo 'xkb_variant = colemak' >> ~live/.config/wayfire.ini # TODO
	echo '[autostart]' >> ~live/.config/wayfire.ini
	echo 'term = alacritty' >> ~live/.config/wayfire.ini
	echo '[command]' >> ~live/.config/wayfire.ini
	echo 'binding_term = <super> KEY_ENTER' >> ~live/.config/wayfire.ini
	echo 'command_term = gnome-terminal' >> ~live/.config/wayfire.ini

	# Set big vt font and 2x gui scale if the first active connector is HiDPI
	if [ x`drm_info -j | jq -r '."/dev/dri/card0".connectors | map(select(.status == 1))[0] as $d | (pow($d.modes[0].hdisplay; 2) + pow($d.modes[0].vdisplay; 2) | sqrt) / (pow($d.phy_width / 25.4; 2) + pow($d.phy_height / 25.4; 2) | sqrt) > 120'` = xtrue ]; then
		for ttyv in /dev/ttyv*; do
			vidcontrol -f terminus-b32 < ${ttyv} > ${ttyv}
		done
		# just guess common names.. drm_info doesn't give us an actual names and trying to derive it would be too much work
		echo '[eDP-1]' >> ~live/.config/wayfire.ini
		echo 'scale = 2' >> ~live/.config/wayfire.ini
		echo '[DP-1]' >> ~live/.config/wayfire.ini
		echo 'scale = 2' >> ~live/.config/wayfire.ini
		echo '[DP-2]' >> ~live/.config/wayfire.ini
		echo 'scale = 2' >> ~live/.config/wayfire.ini
		echo '[DP-3]' >> ~live/.config/wayfire.ini
		echo 'scale = 2' >> ~live/.config/wayfire.ini
		echo '[HDMI-A-1]' >> ~live/.config/wayfire.ini
		echo 'scale = 2' >> ~live/.config/wayfire.ini
		echo '[HDMI-A-2]' >> ~live/.config/wayfire.ini
		echo 'scale = 2' >> ~live/.config/wayfire.ini
		echo '[HDMI-A-3]' >> ~live/.config/wayfire.ini
		echo 'scale = 2' >> ~live/.config/wayfire.ini
	fi

	kbdmap
	# TODO: apply to wayfire

	echo '[ "x$WAYLAND_DISPLAY" = "x" ] && dbus-launch wayfire -v &> wayfire.log' > ~live/.zprofile

	echo ''
	echo ''
	echo ''
	echo '  --------------------------------------------------'
	echo "  >> Login as 'live' to start a graphical session <<"
	echo '  --------------------------------------------------'
	echo ''
	echo ''
	echo ''
	
	;;
$DIALOG_CANCEL)
	exit 0
	;;
esac
