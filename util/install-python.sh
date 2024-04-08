#!/bin/bash -xeu

./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations

make
make DESTDIR=$LFS install

cat > $LFS/etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

# install -v -dm755 $LFS/usr/share/doc/python-3.12.2/html
# 
# tar --no-same-owner \
#     -xvf ../python-3.12.2-docs-html.tar.bz2
# cp -R --no-preserve=mode python-3.12.2-docs-html/* \
#     $LFS/usr/share/doc/python-3.12.2/html
