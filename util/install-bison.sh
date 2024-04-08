#!/bin/bash -xeu

./configure --prefix=/usr --docdir=$LFS/usr/share/doc/bison-3.8.2

make
# make check
make DESTDIR=$LFS install
