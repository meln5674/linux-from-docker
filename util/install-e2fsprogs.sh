#!/bin/bash -xeu

mkdir -v build
cd       build

../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

make
# make check
make DESTDIR=$LFS install

rm -fv $LFS/usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v $LFS/usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir $LFS/usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info $LFS/usr/share/info
install-info --dir-file=$LFS/usr/share/info/dir $LFS/usr/share/info/com_err.info

sed 's/metadata_csum_seed,//' -i $LFS/etc/mke2fs.conf
