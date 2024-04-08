#!/bin/bash -xeu

python3 -c 'from pty import spawn; spawn(["echo", "ok"])'

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

make
# make test
make DESTDIR=$LFS install
ln -svf expect5.45.4/libexpect5.45.4.so $LFS/usr/lib
