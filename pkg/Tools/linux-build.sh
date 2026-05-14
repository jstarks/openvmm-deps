#!/bin/sh
# Shared Linux kernel build script.
#
# Called from each kernel package's build.sh. Uses $PKGDIR for the
# per-version config files and $SRCDIR for the kernel source tree.

set -e

config="$PKGDIR/$ARCH.config"

mkdir -p "$SYSROOT/boot"

case $ARCH in
    x86_64) KARCH=x86_64 ;;
    aarch64) KARCH=arm64 ;;
    *) >&2 echo "Unknown architecture: $ARCH" && exit 1 ;;
esac

case $KARCH in
    x86_64)
        KTARGETS="vmlinux bzImage"
        KIMAGES="./vmlinux ./arch/x86/boot/bzImage"
        ;;
    arm64)
        KTARGETS="vmlinux Image"
        KIMAGES="./vmlinux ./arch/arm64/boot/Image"
        ;;
    *) >&2 echo "Unknown kernel architecture: $KARCH" && exit 1 ;;
esac

if [ -f "$config" ]; then
    cp "$config" .config
    make -j`nproc` -k -f $SRCDIR/Makefile ARCH="$KARCH" CROSS_COMPILE="$ARCH-linux-musl-" olddefconfig $KTARGETS
    
    for image in $KIMAGES; do
        cp "$image" "$SYSROOT/boot/"
    done

    # Export the final config (after olddefconfig) so it can be extracted and committed.
    cp .config "$SYSROOT/boot/config"
fi
