#!/bin/bash -xeu

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

make

# make check

make DESTDIR=$LFS install
