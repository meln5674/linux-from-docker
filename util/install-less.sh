#!/bin/bash -xeu

./configure --prefix=/usr --sysconfdir=/etc

make
# make check
make DESTDIR=$LFS install
