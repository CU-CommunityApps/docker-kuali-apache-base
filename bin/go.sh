#!/bin/bash

[[ -z "${DOCKER_IMG}" ]] && echo "Please define environment variable DOCKER_IMG before running" && exit 1

BASEDIR=$(dirname "${0}")"/../"

set -e -x

# Expand basedir to absolute path in the most portable way possible
# so we can pass it as a Docker volume mapping later.
cd ${BASEDIR}
BASEDIR=`pwd`
cd -

# Build CUWA and update lib/mod_cuwebauth.so
# This could eventually become a multi-stage Docker build, assuming we
#   update out Docker versions on Jenkins/build hosts to 17.05+.
echo "Building mod_cuwebauth"
${BASEDIR}/bin/build-mod_cuwebauth.sh

# Main image build w/alt tag
echo "Building Apache 2.4 image as ${DOCKER_IMG}:test-build"
docker build \
       --force-rm \
       --no-cache \
       --pull \
       -t ${DOCKER_IMG}:test-build \
       ${BASEDIR}

# Run basic test script against new image
echo "Running basic test suite against new image"
docker run \
       --rm \
       ${DOCKER_IMG}:test-build \
       /root/test-suite/run-tests.sh

echo "Tagging image and removing test-build"
docker tag \
       ${DOCKER_IMG}:test-build \
       ${DOCKER_IMG}
docker rmi ${DOCKER_IMG}:test-build

echo "Build complete."
echo "If you need to push this image to a repository, and it is tagged appropriately, run: "
echo "  docker push ${DOCKER_IMG}"
