#!/bin/bash -xeu

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native

make
# make check
make DESTDIR=$LFS install
