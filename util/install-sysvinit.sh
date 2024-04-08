#!/bin/bash -xeu

make
mkdir -pv $LFS/run
make ROOT=$LFS DESTDIR=$LFS install
mknod -m 600 $LFS/run/initctl p
