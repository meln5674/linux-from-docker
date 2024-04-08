#!/bin/bash -xeu

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-openssl         \
            --with-xz              \
            --with-zstd            \
            --with-zlib

make

make DESTDIR=$LFS install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod $LFS/usr/sbin/$target
done

ln -sfv kmod $LFS/usr/bin/lsmod
