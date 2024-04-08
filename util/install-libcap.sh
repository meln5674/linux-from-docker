#!/bin/bash -xeu

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=$LFS/usr lib=lib

# make test

make prefix=$LFS/usr lib=lib install
