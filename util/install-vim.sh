#!/bin/bash -xeu

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

# chown -R tester .
# su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
#    &> vim-test.log

make DESTDIR=$LFS install

ln -sv vim $LFS/usr/bin/vi
for L in  $LFS/usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
mkdir -pv $LFS/usr/share/doc
ln -sv ../vim/vim91/doc $LFS/usr/share/doc/vim-9.1.0041

cat > $LFS/etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
