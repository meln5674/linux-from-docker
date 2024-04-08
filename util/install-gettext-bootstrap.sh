#!/bin/bash -xeu

./configure --disable-shared
make
mkdir -pv $LFS/usr/bin
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} $LFS/usr/bin
