#!/bin/bash -xeu

./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

make
# make check
make DESTDIR=$LFS install
