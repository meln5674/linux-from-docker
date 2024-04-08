#!/bin/bash -xeu

sed -i "s/echo/#echo/" src/egrep.sh

./configure --prefix=/usr

make
# make check
make DESTDIR=$LFS install
