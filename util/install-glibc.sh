#!/bin/bash -xeu

case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac

mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=4.19                     \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib
make
# make check
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
mkdir -pv $LFS/usr/lib/locale

$LFS/usr/bin/localedef --prefix=$LFS -i C -f UTF-8 C.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i cs_CZ -f UTF-8 cs_CZ.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i de_DE -f ISO-8859-1 de_DE
$LFS/usr/bin/localedef --prefix=$LFS -i de_DE@euro -f ISO-8859-15 de_DE@euro
$LFS/usr/bin/localedef --prefix=$LFS -i de_DE -f UTF-8 de_DE.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i el_GR -f ISO-8859-7 el_GR
$LFS/usr/bin/localedef --prefix=$LFS -i en_GB -f ISO-8859-1 en_GB
$LFS/usr/bin/localedef --prefix=$LFS -i en_GB -f UTF-8 en_GB.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i en_HK -f ISO-8859-1 en_HK
$LFS/usr/bin/localedef --prefix=$LFS -i en_PH -f ISO-8859-1 en_PH
$LFS/usr/bin/localedef --prefix=$LFS -i en_US -f ISO-8859-1 en_US
$LFS/usr/bin/localedef --prefix=$LFS -i en_US -f UTF-8 en_US.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i es_ES -f ISO-8859-15 es_ES@euro
$LFS/usr/bin/localedef --prefix=$LFS -i es_MX -f ISO-8859-1 es_MX
$LFS/usr/bin/localedef --prefix=$LFS -i fa_IR -f UTF-8 fa_IR
$LFS/usr/bin/localedef --prefix=$LFS -i fr_FR -f ISO-8859-1 fr_FR
$LFS/usr/bin/localedef --prefix=$LFS -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
$LFS/usr/bin/localedef --prefix=$LFS -i fr_FR -f UTF-8 fr_FR.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i is_IS -f ISO-8859-1 is_IS
$LFS/usr/bin/localedef --prefix=$LFS -i is_IS -f UTF-8 is_IS.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i it_IT -f ISO-8859-1 it_IT
$LFS/usr/bin/localedef --prefix=$LFS -i it_IT -f ISO-8859-15 it_IT@euro
$LFS/usr/bin/localedef --prefix=$LFS -i it_IT -f UTF-8 it_IT.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i ja_JP -f EUC-JP ja_JP
$LFS/usr/bin/localedef --prefix=$LFS -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
$LFS/usr/bin/localedef --prefix=$LFS -i ja_JP -f UTF-8 ja_JP.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
$LFS/usr/bin/localedef --prefix=$LFS -i ru_RU -f KOI8-R ru_RU.KOI8-R
$LFS/usr/bin/localedef --prefix=$LFS -i ru_RU -f UTF-8 ru_RU.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i se_NO -f UTF-8 se_NO.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i ta_IN -f UTF-8 ta_IN.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i tr_TR -f UTF-8 tr_TR.UTF-8
$LFS/usr/bin/localedef --prefix=$LFS -i zh_CN -f GB18030 zh_CN.GB18030
$LFS/usr/bin/localedef --prefix=$LFS -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
$LFS/usr/bin/localedef --prefix=$LFS -i zh_TW -f UTF-8 zh_TW.UTF-8

mkdir -pv $LFS/etc
cat > $LFS/etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

cd $LFS_SRC/tzdata

ZONEINFO=$LFS/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    $LFS/usr/sbin/zic -L /dev/null   -d $ZONEINFO       ${tz}
    $LFS/usr/sbin/zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    $LFS/usr/sbin/zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
$LFS/usr/sbin/zic -d $ZONEINFO -p UTC
unset ZONEINFO

# TODO: Provide ARG to select timezone?
ln -sfv /usr/share/zoneinfo/UTC /etc/localtime

cat > $LFS/etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> $LFS/etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv $LFS/etc/ld.so.conf.d
