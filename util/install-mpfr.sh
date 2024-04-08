#!/bin/bash -xeu

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1

make
make html

# make check

make DESTDIR=$LFS install
make DESTDIR=$LFS install-html


sed -i -E "s|$LFS/?|/|" $LFS/usr/lib/libmpfr*.la
