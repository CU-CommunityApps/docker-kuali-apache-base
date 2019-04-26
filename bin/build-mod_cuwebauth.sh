#!/bin/bash

set -e

for I in CUWA_VERSION DOCKER_IMG; do
    [[ -z "${!I}" ]] && echo "Please define environment variable ${I}" && exit 1
done

BUILD_TAG="${DOCKER_IMG}:cuwabuild-tmp"
CONTAINER_NAME=${BUILD_TAG//[\/:.]}

# Make sure someone didn't cd into bin/, or call me from a completely different path
BASEDIR=$(dirname "${0}")"/../"

echo Creating build image for compiling mod_cuwebauth.so version ${CUWA_VERSION}

set -x

[[ -f ${BASEDIR}/lib/mod_cuwebauth.so ]] && rm ${BASEDIR}/lib/mod_cuwebauth.so

docker build \
       --build-arg CUWA_VERSION=${CUWA_VERSION} \
       -f ${BASEDIR}Dockerfile.cuwa-build \
       --force-rm \
       --no-cache \
       --pull \
       -t ${BUILD_TAG} \
       ${BASEDIR}

# Will generate error if you already have a container named ${CONTAINER_NAME}
# Most likely scenario would be a previous failed build attempt.
echo Instantiating container to pull mod_cuwebauth.so artifact.
docker create \
       --name ${CONTAINER_NAME} \
       ${BUILD_TAG}

# Copy module from build container to the previously-determined base directory.
echo Copying mod_cuwebauth.so to local lib/ directory.
[[ ! -d ${BASEDIR}/lib ]] && mkdir ${BASEDIR}/lib
docker cp ${CONTAINER_NAME}:/usr/lib/apache2/modules/mod_cuwebauth.so ${BASEDIR}/lib/

# Clean up
echo Cleaning up build image and container.
docker rm ${CONTAINER_NAME}
docker rmi ${BUILD_TAG}
