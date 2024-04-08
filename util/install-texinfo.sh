#!/bin/bash -xeu

./configure --prefix=/usr

make
# make check
make DESTDIR=$LFS install

make TEXMF=$LFS/usr/share/texmf install-tex
