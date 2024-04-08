#!/bin/bash -xeu

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.0

make
# make check
make DESTDIR=$LFS install

install -v -m644 doc/*.{html,css} $LFS/usr/share/doc/expat-2.6.0
