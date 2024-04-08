#!/bin/bash -xeu

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

make
# make check
make DESTDIR=$LFS -C libelf install
mkdir -pv $LFS/usr/lib/pkgconfig
install -vm644 config/libelf.pc $LFS/usr/lib/pkgconfig/
rm $LFS/usr/lib/libelf.a
