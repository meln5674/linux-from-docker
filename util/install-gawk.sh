#!/bin/bash -xeu

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make

# chown -R tester .
# su tester -c "PATH=$PATH make check"

rm -f /usr/bin/gawk-5.3.0
make DESTDIR=$LFS install

ln -sv gawk.1 /usr/share/man/man1/awk.1
mkdir -pv                                   $LFS/usr/share/doc/gawk-5.3.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} $LFS/usr/share/doc/gawk-5.3.0
