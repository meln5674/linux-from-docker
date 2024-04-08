#!/bin/bash -xeu

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.4 \
            --disable-static                        \
            --disable-kill

make
# make -k check
make DESTDIR=$LFS
