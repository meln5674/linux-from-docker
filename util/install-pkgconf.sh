./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.1.1

make
make DESTDIR=$LFS install

ln -sv pkgconf   $LFS/usr/bin/pkg-config
ln -sv pkgconf.1 $LFS/usr/share/man/man1/pkg-config.1
