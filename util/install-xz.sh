#!/bin/bash -xeu

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.4.6

make
# make check
make DESTDIR=$LFS install
