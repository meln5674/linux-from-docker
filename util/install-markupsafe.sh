#!/bin/bash -xeu

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --no-user --find-links dist --root $LFS Markupsafe
