#!/bin/bash -xeu

rm -v man3/crypt*
make prefix=$LFS/usr install
