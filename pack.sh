#!/bin/sh

. /usr/src/tools/boot/install-boot.sh

: "${ROOT:=build}"
: "${FSIMAGE:=/tmp/dank-live-ufs.img}"
: "${ZIPIMAGE:=/tmp/dank-live-zip.img}"
: "${BSIMAGE:=/tmp/dank-live-bootstrap.img}"
: "${EFIIMAGE:=/tmp/dank-live-esp.img}"
: "${BSDIR:=/tmp/dank-live-bootstrap}"
: "${OUTPUTDIR:=/tmp}"
: "${OUTPUT:=$OUTPUTDIR/DankBSD-$(date '+%Y-%m-%d-%H-%M-%S').img}"

cp src/32-dank.sh src/99-dank.sh "$ROOT/usr/local/etc/runit/core-services/"
echo '/dev/gpt/dank-live-zip.uzip / ufs ro 1 1' > $ROOT/etc/fstab

make_esp_file $EFIIMAGE 1024 $ROOT/boot/loader.efi

makefs -B little -o label=DankBSD_Live -o version=2 -o optimization=space $FSIMAGE $ROOT
mkuzip -A zstd -C 15 -s 32768 -d -S -o $ZIPIMAGE $FSIMAGE
rm $FSIMAGE

# The loader needs to load the kernel and look at the fstab from an uncompressed partition
# We don't need networking and gpu stuff on there, that can be loaded later after mounting uzip
rm -rf $BSDIR
mkdir -p $BSDIR/etc
cp -r $ROOT/boot $BSDIR/
rm $BSDIR/boot/kernel/iwm* $BSDIR/boot/kernel/iwn* $BSDIR/boot/kernel/isp* $BSDIR/boot/kernel/ath* \
	$BSDIR/boot/kernel/rtwn* $BSDIR/boot/kernel/if_* $BSDIR/boot/kernel/sfxg* $BSDIR/boot/kernel/pmspcv* \
	$BSDIR/boot/kernel/t*fw_* $BSDIR/boot/kernel/mlx4* $BSDIR/boot/kernel/mlx5*
rm -r $BSDIR/boot/modules $BSDIR/boot/firmware $BSDIR/boot/userboot* $BSDIR/boot/*.efi
cp $ROOT/etc/fstab $BSDIR/etc/
makefs -B little -o label=DankBSD_Live_Bootstrap -o version=2 -o optimization=space $BSIMAGE $BSDIR
rm -rf $BSDIR

rm $ROOT/etc/fstab

mkimg -v -s gpt -b /boot/pmbr \
	-p efi/dank-live-esp:=$EFIIMAGE \
	-p freebsd-ufs/dank-live-bootstrap:=$BSIMAGE \
	-p freebsd-ufs/dank-live-zip:=$ZIPIMAGE \
	-o $OUTPUT

rm $EFIIMAGE $BSIMAGE $ZIPIMAGE
printf '>> Built %s <<' $OUTPUT
