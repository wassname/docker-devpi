#!/bin/sh
#
# Script to build images
#

# break on error
set -e

REPO="wassname"
DATE=`date +%Y.%m.%d`

: ${DOCKER_BUILD_OPTIONS:="--pull=true"}

image="${REPO}/devpi"
echo "################################################################### ${image}"

## warm up cache for CI
docker pull ${image} || true

for tag in "${image}:latest" "${image}:latest-${DATE}" "${image}:${DEVPI_VERSION}"; do
    echo "############################################################# ${tag}"
    set -x
    docker build ${DOCKER_BUILD_OPTIONS} -t ${tag} .
    docker inspect ${tag}
    docker push ${tag}
    set +x
done
