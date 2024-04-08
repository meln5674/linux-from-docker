#!/bin/bash -xeu

# rm -rf "/src/lfs/grep"
# mkdir -p "/src/lfs/grep"
# tar -xf "/src/lfs/grep"-*.tar.* --strip-components=1 -C "/src/lfs/grep"
# 
# cd /src/lfs/grep

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install
