#!/bin/bash -xeu

# rm -rf "/src/lfs/linux"
# mkdir -p "/src/lfs/linux"
# tar -xf "/src/lfs/linux"-*.tar.* --strip-components=1 -C "/src/lfs/linux"
# 
# cd /src/lfs/linux

make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
mkdir -pv "${LFS}/usr"
cp -rv usr/include "${LFS}/usr/include"

