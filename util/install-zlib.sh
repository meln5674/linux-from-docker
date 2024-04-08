#!/bin/bash -xeu

./configure --prefix=/usr
make
# make check
make DESTDIR=$LFS install
rm -fv $LFS/usr/lib/libz.a
