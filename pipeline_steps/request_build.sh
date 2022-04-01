#!/bin/sh

# Release version that is to be built
export APODEIXI_VERSION="v0.9.3"
export APODEIXI_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

# Comment this environment variable if we want to keep the build container (e.g., to inspect problems) after using build is over
export REMOVE_CONTAINER_WHEN_DONE="--rm" 

# Used for external volume
export BUILD_OUTPUT="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/devops/output"
export BUILD_SCRIPTS="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/devops/pipeline_steps"

# Unique timestamp for each build run. 
# For example, "220331.120319" is a run done at 12:03 pm (and 19 seconds) on March 31, 2022
#
export TIMESTAMP="$(date +"%y%m%d.%H%M%S")"

# Run build in build container
#
echo "About to start build server container..."
docker run ${REMOVE_CONTAINER_WHEN_DONE} \
            -e TIMESTAMP=${TIMESTAMP} -e APODEIXI_VERSION=${APODEIXI_VERSION} -e APODEIXI_GIT_URL=${APODEIXI_GIT_URL} \
            -v ${BUILD_OUTPUT}:/home/output -v ${BUILD_SCRIPTS}:/home/scripts \
            a6i-build-server &# /bin/bash /home/scripts/build.sh

echo "...waiting for build server to start..."
sleep 3
echo "Build server container up and running..."
export BUILD_CONTAINER=$(docker ps -q -l)
docker exec ${BUILD_CONTAINER} /bin/bash /home/scripts/build.sh

echo "...stopping build container"
docker stop ${BUILD_CONTAINER}
