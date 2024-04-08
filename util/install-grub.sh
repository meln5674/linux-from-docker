#!/bin/bash -xeu

unset {C,CPP,CXX,LD}FLAGS

echo depends bli part_gpt > grub-core/extra_deps.lst

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror


make

make DESTDIR=$LFS install
mkdir -pv $LFS/usr/share/bash-completion/completions
mv -v $LFS/etc/bash_completion.d/grub $LFS/usr/share/bash-completion/completions/
mkdir -pv $LFS/boot/grub
