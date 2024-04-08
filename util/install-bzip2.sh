#!/bin/bash -xeu

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=$LFS/usr install
cp -av libbz2.so.* $LFS/usr/lib
ln -sv libbz2.so.1.0.8 $LFS/usr/lib/libbz2.so
cp -v bzip2-shared $LFS/usr/bin/bzip2
for i in $LFS/usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done
rm -fv $LFS/usr/lib/libbz2.a
