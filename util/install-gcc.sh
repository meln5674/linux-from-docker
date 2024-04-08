#!/bin/bash -xeu

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

make

# ulimit -s 32768
# chown -R tester .
# su tester -c "PATH=$PATH make -k check"
# ../contrib/test_summary

make DESTDIR=$LFS install

chown -v -R root:root \
    $LFS/usr/lib/gcc/$($LFS/usr/bin/gcc -dumpmachine)/13.2.0/include{,-fixed}

ln -svr $LFS/usr/bin/cpp /usr/lib
ln -sv gcc.1 $LFS/usr/share/man/man1/cc.1

mkdir -pv $LFS/usr/lib/bfd-plugins/
ln -sfv ../../libexec/gcc/$($LFS/usr/bin/gcc -dumpmachine)/13.2.0/liblto_plugin.so \
        $LFS/usr/lib/bfd-plugins/

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
rm -v dummy.c a.out dummy.log

mkdir -pv $LFS/usr/share/gdb/auto-load/usr/lib
mv -v $LFS/usr/lib/*gdb.py $LFS/usr/share/gdb/auto-load/usr/lib
