#!/bin/bash -xeu

sh autogen.sh

sh configure

make

make DESTDIR=$LFS install
