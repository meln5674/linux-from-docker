#!/bin/bash -xeu

ls

mkdir -pv $LFS/usr/include

sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in
sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h

mkdir -p build
cd       build

meson setup \
      --prefix=/usr                 \
      --buildtype=release           \
      -Dmode=release                \
      -Ddev-kvm-mode=0660           \
      -Dlink-udev-shared=false      \
      -Dlogind=false                \
      -Dvconsole=false              \
      ..

export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | \
                      awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')

ninja udevadm systemd-hwdb                                           \
      $(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
      $(realpath libudev.so --relative-to .)                         \
      $udev_helpers

install -vm755 -d $LFS{/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}
install -vm755 -d $LFS/usr/{lib,share}/pkgconfig
install -vm755 udevadm                             $LFS/usr/bin/
install -vm755 systemd-hwdb                        $LFS/usr/bin/udev-hwdb
ln      -svfn  ../bin/udevadm                      $LFS/usr/sbin/udevd
cp      -av    libudev.so{,*[0-9]}                 $LFS/usr/lib/
install -vm644 ../src/libudev/libudev.h            $LFS/usr/include/
install -vm644 src/libudev/*.pc                    $LFS/usr/lib/pkgconfig/
install -vm644 src/udev/*.pc                       $LFS/usr/share/pkgconfig/
install -vm644 ../src/udev/udev.conf               $LFS/etc/udev/
install -vm644 rules.d/* ../rules.d/README         $LFS/usr/lib/udev/rules.d/
install -vm644 $(find ../rules.d/*.rules \
                      -not -name '*power-switch*') $LFS/usr/lib/udev/rules.d/
install -vm644 hwdb.d/*  ../hwdb.d/{*.hwdb,README} $LFS/usr/lib/udev/hwdb.d/
install -vm755 $udev_helpers                       $LFS/usr/lib/udev
install -vm644 ../network/99-default.link          $LFS/usr/lib/udev/network

cd $LFS_SRC/udev-lfs
make -f udev-lfs-20230818/Makefile.lfs DESTDIR=$LFS install

# tar -xf ../../systemd-man-pages-255.tar.xz                            \
#     --no-same-owner --strip-components=1                              \
#     -C /usr/share/man --wildcards '*/udev*' '*/libudev*'              \
#                                   '*/systemd.link.5'                  \
#                                   '*/systemd-'{hwdb,udevd.service}.8
# 
# sed 's|systemd/network|udev/network|'                                 \
#     $LFS/usr/share/man/man5/systemd.link.5                                \
#   > $LFS/usr/share/man/man5/udev.link.5
# 
# sed 's/systemd\(\\\?-\)/udev\1/' $LFS/usr/share/man/man8/systemd-hwdb.8   \
#                                > $LFS/usr/share/man/man8/udev-hwdb.8
# 
# sed 's|lib.*udevd|sbin/udevd|'                                        \
#     $LFS/usr/share/man/man8/systemd-udevd.service.8                       \
#   > $LFS/usr/share/man/man8/udevd.8
# 
# rm $LFS/usr/share/man/man*/systemd*

unset udev_helpers

# TODO: Need to run this on the actual VM?
# udev-hwdb update
