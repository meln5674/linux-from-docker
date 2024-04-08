#!/bin/bash -xeu

./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

make
make DESTDIR=$LFS install
