#!/bin/bash -xeu

# rm -rf "/src/lfs/coreutils"
# mkdir -p "/src/lfs/coreutils"
# tar -xf "/src/lfs/coreutils"-*.tar.* --strip-components=1 -C "/src/lfs/coreutils"
# 
# cd /src/lfs/coreutils

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make
make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
