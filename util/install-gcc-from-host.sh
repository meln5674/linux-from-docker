#!/bin/bash -xeu

# rm -rf "/src/lfs/gcc"
# mkdir -p "/src/lfs/gcc"
# tar -xf "/src/lfs/gcc"-*.tar.* --strip-components=1 -C "/src/lfs/gcc"
# 
# for pkg in mpfr gmp mpc; do
#     rm -rf "/src/lfs/gcc/${pkg}"
#     mkdir -p "/src/lfs/gcc/${pkg}"
#     tar -xf "/src/lfs/${pkg}"-*.tar.* --strip-components=1 -C "/src/lfs/gcc/${pkg}"
# done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig /src/lfs/gcc/gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd       build

../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.39 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++

make
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > "$(dirname "$("$LFS_TGT-gcc" -print-libgcc-file-name)")/include/limits.h"

