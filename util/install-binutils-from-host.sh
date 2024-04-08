#!/bin/bash -xeu

# rm -rf /src/lfs/binutils
# mkdir -p /src/lfs/binutils
# tar -xJf /src/lfs/binutils-*.tar.xz --strip-components=1 -C /src/lfs/binutils
# cd /src/lfs/binutils
# 
mkdir -pv build
cd build

../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-default-hash-style=gnu

make
make install
