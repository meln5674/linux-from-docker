#!/bin/bash -xeu

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns

make SBINDIR=$LFS/usr/sbin install

mkdir -pv             $LFS/usr/share/doc/iproute2-6.7.0
cp -v COPYING README* $LFS/usr/share/doc/iproute2-6.7.0
