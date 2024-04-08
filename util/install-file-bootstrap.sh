#!/bin/bash -xeu

# rm -rf "/src/lfs/file"
# mkdir -p "/src/lfs/file"
# tar -xf "/src/lfs/file"-*.tar.* --strip-components=1 -C "/src/lfs/file"
# 
# cd /src/lfs/file

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la


