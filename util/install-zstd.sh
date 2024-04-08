#!/bin/bash -xeu

make prefix=$LFS/usr
# make check
make prefix=$LFS/usr install
rm -v $LFS/usr/lib/libzstd.a

find $LFS/ -name '*.pc' -exec sed -Ei "s|$LFS/?|/|" {} \;
