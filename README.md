# DankBSD

WIP WIP WIP WIP WIP WIP WIP WIP

DankBSD is a desktop-oriented fork/distro/patchset/thingy of FreeBSD.

- graphical Live USB image with a [Wayfire](https://github.com/WayfireWM/wayfire) desktop
- UEFI only, amd64 and arm64 (aarch64) only
- CURRENT only / "rolling release"
- lots of [updates to ports](https://github.com/myfreeweb/freebsd-ports-dank) (e.g. GNOME apps @ 3.36)
- [runit](https://github.com/t6/freebsd-runit) out of the box, no rc scripts
- [next input stack with I2C HID support](https://github.com/wulf7/iichid) out of the box
- [upstream OpenZFS](https://github.com/openzfs/zfs) out of the box
- [packaged base](https://wiki.freebsd.org/PkgBase)
- reduced duplication between base and ports (LLVM/Clang and OpenSSH in ports only)
- `MINIMAL`-derived (as modular as possible) kernel configuration
- a tiny bit of hardening (PIE and BIND_NOW base, only exposing mem map sysctls to the real (jail 0) root user)
- interesting upcoming patches often applied early
- various legacy stuff removed

binaries/images "coming" "soon"
