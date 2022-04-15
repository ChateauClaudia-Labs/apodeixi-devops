#!/bin/sh

source ./common.sh
# Release version that is to be built
#export APODEIXI_VERSION="0.9.5"
export APODEIXI_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

# Comment this environment variable if we want to keep the build container (e.g., to inspect problems) after using build is over
export REMOVE_CONTAINER_WHEN_DONE="--rm" 

# Used for external volume
export BUILD_OUTPUT="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/devops/output"
export PIPELINE_SCRIPTS="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/devops/pipeline_steps"

# Unique timestamp for each build run. 
# For example, "220331.120319" is a run done at 12:03 pm (and 19 seconds) on March 31, 2022
#
export TIMESTAMP="$(date +"%y%m%d.%H%M%S")"

# Run build in build container
#
echo
echo "About to start build server container..."
docker run ${REMOVE_CONTAINER_WHEN_DONE} \
            -e TIMESTAMP=${TIMESTAMP} -e APODEIXI_VERSION=${APODEIXI_VERSION} -e APODEIXI_GIT_URL=${APODEIXI_GIT_URL} \
            -v ${BUILD_OUTPUT}:/home/output -v ${PIPELINE_SCRIPTS}:/home/scripts \
            a6i-build-server & # run in the background so rest of this script can proceed

echo "...waiting for build server to start..."
sleep 3
echo "Build server container up and running..."
echo "...attempting to build Apodeixi v${APODEIXI_VERSION}..."
export BUILD_CONTAINER=$(docker ps -q -l)
docker exec ${BUILD_CONTAINER} /bin/bash /home/scripts/build.sh

echo "...stopping build container..."
echo "...stopped build container $(docker stop ${BUILD_CONTAINER})"
echo
echo "Check logs and distribution under ${BUILD_OUTPUT}"
