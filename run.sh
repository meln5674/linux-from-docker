#!/bin/bash -xeu

if [ -z "${1:-}" ]; then
    COMMAND=( /bin/sh )
else
    COMMAND=( "$@" )
fi

image_id=$(DOCKER_FLAGS="${DOCKER_FLAGS:-} -q" ./build.sh)

docker run --rm "${DOCKER_RUN_FLAGS:--it}" "${image_id}" "${COMMAND[@]}"
