# DankBSD Development Notes

## Building

### Base build

https://github.com/DankBSD/base in `/usr/src`

```sh
doas nice -n20 cpuset -l0-14 time make -j14 buildkernel buildworld KERNCONF=DANK
doas nice -n20 cpuset -l0-14 time make -j14 packages KERNCONF=DANK
```

### Ports build

https://github.com/DankBSD/ports in `/usr/ports`, see below for Poudriere setup

make.conf from this repo in `/usr/local/etc/poudriere.d`

```sh
doas cpuset -l0-14 nice -n20 poudriere bulk -j dank-2020-09 -f pkglist
```

### pkg setup

```
DankBSD-base-local: {
  url: "file:///usr/obj/usr/src/repo/${ABI}/latest",
  mirror_type: "none",
  enabled: yes
}
DankBSD-local: {
  url: "file:///usr/local/poudriere/data/packages/dank-2020-09-default",
  mirror_type: "none",
  priority: 0,
  enabled: yes,
}
```

Disable all other repos.

### Poudriere patch for no rc in base

```diff
--- common.sh.orig      2020-04-10 18:42:02.935984000 +0300
+++ common.sh   2020-04-12 23:52:00.772991000 +0300
@@ -2539,7 +2539,13 @@
                PORTBUILD_UID=${portbuild_uid}
                PORTBUILD_GID=$(injail id -g ${PORTBUILD_USER})
        fi
-       injail service ldconfig start >/dev/null || \
+
+       # injail service ldconfig start >/dev/null || \
+       #     err 1 "Failed to set ldconfig paths."
+
+       mkdir -p "${tomnt}/usr/local/etc/runit/core-services/"
+       cp -v /usr/local/etc/runit/core-services/41-ldconfig.sh "${tomnt}/usr/local/etc/runit/core-services/"
+       injail sh /usr/local/etc/runit/core-services/41-ldconfig.sh >/dev/null || \
            err 1 "Failed to set ldconfig paths."

        setup_ccache "${tomnt}"
```

### Poudriere jail setup with no compiler in base

```sh
doas poudriere jail -c -j $JAILNAME -m src=/usr/src -v 13.0-CURRENT
doas pkg -r /usr/local/poudriere/jails/$JAILNAME/ install -y llvm11
doas pkg -r /usr/local/poudriere/jails/$JAILNAME/ remove -yf gettext-runtime indexinfo libffi libxml2 lua52 openssl perl5 python37 readline
doas zfs destroy ruunvald-nvme/poudriere/jails/$JAILNAME@clean
doas zfs snapshot ruunvald-nvme/poudriere/jails/$JAILNAME@clean
```

The problem with installing pkgs in the jail is that poudriere builds would use them,
and if they don't match what's built, lots of stuff would get rebuilt everytime because
the built packages depend on wrong things. (e.g. on an older version of `gettext-runtime`.)
So you have to keep them up to date.
Fortunately, nearly all of llvm's dependencies are only for lldb and stuff, not clang, so we can
just force delete them :) and the only package you have to keep up to date is LLVM.
And `libedit`.

### Updating headers in poudriere

After updating and rebuilding the kernel, sync new includes and src into the jail:

```sh
doas rsync -a --exclude=.git --exclude='*.core' --verbose /usr/obj/usr/src/amd64.amd64/worldstage/usr/include/ /usr/local/poudriere/jails/$JAILNAME/usr/include
doas rsync -a --exclude=.git --exclude='*.core' --verbose /usr/src/ /usr/local/poudriere/jails/$JAILNAME/usr/src/
```

And delete kmods to rebuild them e.g.:

```sh
doas rm /usr/local/poudriere/data/packages/$JAILNAME-default/All/{drm-devel-kmod*,openzfs-kmod*,iichid*}
```
