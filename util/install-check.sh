#!/bin/bash -xeu

./configure --prefix=/usr --disable-static

make
# make check
make DESTDIR=$LFS docdir=/usr/share/doc/check-0.15.2 install
