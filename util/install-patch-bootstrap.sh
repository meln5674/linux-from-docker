#!/bin/bash -xeu

# rm -rf "/src/lfs/patch"
# mkdir -p "/src/lfs/patch"
# tar -xf "/src/lfs/patch"-*.tar.* --strip-components=1 -C "/src/lfs/patch"
# 
# cd /src/lfs/patch

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

