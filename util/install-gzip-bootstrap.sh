#!/bin/bash -xeu

# rm -rf "/src/lfs/gzip"
# mkdir -p "/src/lfs/gzip"
# tar -xf "/src/lfs/gzip"-*.tar.* --strip-components=1 -C "/src/lfs/gzip"
# 
# cd /src/lfs/gzip

./configure --prefix=/usr --host=$LFS_TGT

make
make DESTDIR=$LFS install
