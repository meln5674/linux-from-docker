#!/bin/bash -xeu

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist --root $LFS meson
install -vDm644 data/shell-completions/bash/meson $LFS/usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson $LFS/usr/share/zsh/site-functions/_meson
