#!/bin/bash -xeu

CC=gcc ./configure --prefix=/usr -G -O3 -r
make
# TODO flag for tests
# make test
make DESTDIR=$LFS install
