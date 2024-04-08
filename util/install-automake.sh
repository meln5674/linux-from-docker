#!/bin/bash -xeu

find /usr/ -name autoconf

echo $PATH

find /usr/ -name libperl.so

autoconf --help

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5

make
# make -j$(($(nproc)>4?$(nproc):4)) check
make DESTDIR=$LFS install
