#!/bin/bash -xeu

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make
# make check

make DESTDIR=$LFS install
install -v -Dm644 doc/I18N-HOWTO $LFS/usr/share/doc/intltool-0.51.0/I18N-HOWTO
