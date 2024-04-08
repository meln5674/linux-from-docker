#!/bin/bash -xeu

./configure --prefix=/usr
make
make DESTDIR=$LFS install
