#!/bin/bash -xeu

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

make

make DESTDIR=$LFS install
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so $LFS/usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    $LFS/usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so $LFS/usr/lib/libcurses.so
