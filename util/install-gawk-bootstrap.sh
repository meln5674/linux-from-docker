#!/bin/bash -xeu

# rm -rf "/src/lfs/gawk"
# mkdir -p "/src/lfs/gawk"
# tar -xf "/src/lfs/gawk"-*.tar.* --strip-components=1 -C "/src/lfs/gawk"
# 
# cd /src/lfs/gawk

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install
