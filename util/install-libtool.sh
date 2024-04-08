#!/bin/bash -xeu

./configure --prefix=/usr

make
# make -k check
make DESTDIR=$LFS install

rm -fv $LFS/usr/lib/libltdl.a
