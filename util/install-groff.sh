#!/bin/bash -xeu

# TODO: ARG for PAGE
PAGE=letter ./configure --prefix=/usr

make
# make check
make DESTDIR=$LFS install
