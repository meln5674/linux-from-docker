#!/bin/bash -xeu

# rm -rf "/src/lfs/diffutils"
# mkdir -p "/src/lfs/diffutils"
# tar -xf "/src/lfs/diffutils"-*.tar.* --strip-components=1 -C "/src/lfs/diffutils"
# 
# cd /src/lfs/diffutils

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install
