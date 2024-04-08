#!/bin/bash -xeu

# rm -rf "/src/lfs/tar"
# mkdir -p "/src/lfs/tar"
# tar -xf "/src/lfs/tar"-*.tar.* --strip-components=1 -C "/src/lfs/tar"
# 
# cd /src/lfs/tar

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install


