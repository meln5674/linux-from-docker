#!/bin/bash -xeu

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

make
# make -j1 check
make DESTDIR=$LFS install
