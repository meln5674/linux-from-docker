#!/bin/bash -xeu

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make
# make check
make DESTDIR=$LFS install

mkdir -pv $LFS/usr/share/doc
cp -R -v docs/doc -T $LFS/usr/share/doc/kbd-2.6.4
