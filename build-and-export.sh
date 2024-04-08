#!/bin/bash -xeu

export_path=$1

image_id=$(DOCKER_FLAGS="${DOCKER_FLAGS:-} -q" ./build.sh)

./export.sh "${image_id}" "${export_path}"
