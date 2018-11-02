#!/bin/sh
PKG_CONFIG_SYSROOT_DIR=/opt/sdk/sysroots/aarch64-agl-linux
export PKG_CONFIG_SYSROOT_DIR
PKG_CONFIG_LIBDIR=/opt/sdk/sysroots/aarch64-agl-linux/usr/lib/pkgconfig:/opt/sdk/sysroots/aarch64-agl-linux/usr/share/pkgconfig
export PKG_CONFIG_LIBDIR
exec pkg-config "$@"
