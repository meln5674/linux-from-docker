#!/bin/bash -xeu

image=$1
export_path=$2

container_id=$(docker create "${image}" /bin/sh)

trap "docker rm ${container_id}" EXIT

mkdir -v "${export_path}"
docker export "${container_id}" | tar -x -C "${export_path}"
