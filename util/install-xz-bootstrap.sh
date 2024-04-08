#!/bin/bash -xeu

# rm -rf "/src/lfs/xz"
# mkdir -p "/src/lfs/xz"
# tar -xf "/src/lfs/xz"-*.tar.* --strip-components=1 -C "/src/lfs/xz"
# 
# cd /src/lfs/xz

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.4.6

make
make DESTDIR=$LFS install
