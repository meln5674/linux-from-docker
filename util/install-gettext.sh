#!/bin/bash -xeu

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.22.4

make
# make check
make DESTDIR=$LFS install
chmod -v 0755 $LFS/usr/lib/preloadable_libintl.so
