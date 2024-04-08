#!/bin/bash -xeu

# rm -rf "/src/lfs/sed"
# mkdir -p "/src/lfs/sed"
# tar -xf "/src/lfs/sed"-*.tar.* --strip-components=1 -C "/src/lfs/sed"
# 
# cd /src/lfs/sed

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

make
make DESTDIR=$LFS install


