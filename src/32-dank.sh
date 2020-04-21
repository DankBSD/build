#!/bin/sh
# order 32 to get before the 33 /var/run tmpfs mount

echo "=> Mounting ramdisks for live system"

mount -t tmpfs tmpfs /tmp

mount -t tmpfs tmpfs /home

mount -t tmpfs tmpfs /root
cp /usr/share/skel/dot.zshrc /root/.zshrc

copy_tmpfs() {
	cp -r $1 /tmp/
	mount -t tmpfs tmpfs $1
	mv /tmp$1/* $1/
	rm -rf /tmp$1
}

copy_tmpfs /var
copy_tmpfs /etc
