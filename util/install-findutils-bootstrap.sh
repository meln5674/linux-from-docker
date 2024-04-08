#!/bin/bash -xeu

# rm -rf "/src/lfs/findutils"
# mkdir -p "/src/lfs/findutils"
# tar -xf "/src/lfs/findutils"-*.tar.* --strip-components=1 -C "/src/lfs/findutils"
# 
# cd /src/lfs/findutils

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

