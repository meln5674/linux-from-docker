#!/bin/bash -xeu

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html

# make check 2>&1 | tee gmp-check-log

make DESTDIR=$LFS install
make DESTDIR=$LFS install-html

sed -i -E "s|$LFS/?|/|" $LFS/usr/lib/libgmp*.la
