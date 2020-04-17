#!/bin/sh

: "${IMAGE:=$1}"

kldload nmdm

bhyvectl --vm=dank-live-test --destroy || true

exec bhyve -c 2 -AHP -m 2g \
    -s 0,amd_hostbridge \
    -s 1,ahci-hd,$IMAGE \
    -s 3,virtio-net,tap0 \
    -s 4,virtio-rnd \
    -s 5,hda \
    -s "29,fbuf,tcp=[::]:5900,w=800,h=600" \
    -s 30,xhci,tablet \
    -s 31,lpc \
    -l com1,/dev/nmdm0A \
    -l bootrom,/usr/local/share/uefi-firmware/BHYVE_UEFI.fd \
    dank-live-test
