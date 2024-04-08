#!/bin/bash -xeu

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make
# make check
make DESTDIR=$LFS install
make -C doc install-html docdir=$LFS/usr/share/doc/tar-1.35
