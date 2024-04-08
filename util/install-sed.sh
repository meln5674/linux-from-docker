#!/bin/bash -xeu

./configure --prefix=/usr

make
make html

# chown -R tester .
# su tester -c "PATH=$PATH make check"

make DESTDIR=$LFS install
install -d -m755           $LFS/usr/share/doc/sed-4.9
install -m644 doc/sed.html $LFS/usr/share/doc/sed-4.9
