#!/bin/bash -xeu

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

# HARNESS_JOBS=$(nproc) make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl DESTDIR=$LFS install

mv -v $LFS/usr/share/doc/openssl $LFS/usr/share/doc/openssl-3.2.1
cp -vfr doc/* $LFS/usr/share/doc/openssl-3.2.1
