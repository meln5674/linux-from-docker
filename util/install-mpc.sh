#!/bin/bash -xeu

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

make
make html

# make check

make DESTDIR=$LFS install
make DESTDIR=$LFS install-html

sed -i -E "s|$LFS/?|/|" $LFS/usr/lib/libmpc*.la
