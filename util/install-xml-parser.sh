#!/bin/bash -xeu

perl Makefile.PL

make
# make test
make install DESTDIR=$LFS
