#!/bin/bash -xeu

stat /lib64

sed -i '/test_mkfds/s/^/#/' tests/helpers/Makemodule.am

./configure --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --runstatedir=/run   \
            --sbindir=/usr/sbin  \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.39.3

make
# bash tests/run.sh --srcdir=$PWD --builddir=$PWD
# chown -R tester .
# su tester -c "make -k check"
make DESTDIR=$LFS install
