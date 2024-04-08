#!/bin/bash -xeu

sed -e '/n_out += n_hold/,+4 s|.*bufsize.*|//&|' \
    -i src/split.c


autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make

# make NON_ROOT_USERNAME=tester check-root
# groupadd -g 102 dummy -U tester
# chown -R tester .
# su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
# groupdel dummy

make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
