#!/bin/bash -xeu

LFD_CONFIG=${LFD_CONFIG:-config.yaml}

gomplate \
    -f Dockerfile.tpl \
    -d Values="${LFD_CONFIG}" \
    >/dev/null

gomplate \
    -f Dockerfile.tpl \
    -d Values="${LFD_CONFIG}" \
| tee Dockerfile \
| docker \
    build \
    -f - \
    --build-arg "LFS_TGT=$(uname -m)-lfs-linux-gnu" \
    --build-arg "CONFIG_SITE=/mnt/lfs/usr/share/config.site" \
    --build-arg "MAKEFLAGS=-j$(nproc)" \
    ${DOCKER_FLAGS:-} \
    .
