#!/bin/bash -xeu

# rm -rf "/src/lfs/bash"
# mkdir -p "/src/lfs/bash"
# tar -xf "/src/lfs/bash"-*.tar.* --strip-components=1 -C "/src/lfs/bash"
# 
# cd /src/lfs/bash

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

make
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh

