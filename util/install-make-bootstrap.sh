#!/bin/bash -xeu

# rm -rf "/src/lfs/make"
# mkdir -p "/src/lfs/make"
# tar -xf "/src/lfs/make"-*.tar.* --strip-components=1 -C "/src/lfs/make"
# 
# cd /src/lfs/make

./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

