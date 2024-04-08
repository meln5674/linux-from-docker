#!/bin/bash -xeu

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make
# make check
make DESTDIR=$LFS install
ln -sv flex   $LFS/usr/bin/lex
ln -sv flex.1 $LFS/usr/share/man/man1/lex.1
