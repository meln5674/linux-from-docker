#!/bin/bash -xeu

# rm -rf "/src/lfs/m4"
# mkdir -p "/src/lfs/m4"
# tar -xf "/src/lfs/m4"-*.tar.* --strip-components=1 -C "/src/lfs/m4"
# 
# cd /src/lfs/m4

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install
