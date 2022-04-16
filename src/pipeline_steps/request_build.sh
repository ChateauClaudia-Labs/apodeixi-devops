#!/usr/bin/env bash

export A6I_DEVOPS_ROOT="$( cd "$( dirname $0 )/../../" >/dev/null 2>&1 && pwd )"
export PIPELINE_SCRIPTS="${A6I_DEVOPS_ROOT}/src/pipeline_steps"

source ${PIPELINE_SCRIPTS}/common.sh

# Get definition (really more of a config) of the pipeline we are running
source "${A6I_DEVOPS_ROOT}/pipelines/${PIPELINE_ID}/pipeline_definition.sh"

# Comment this environment variable if we want to keep the build container (e.g., to inspect problems) after using build is over
export REMOVE_CONTAINER_WHEN_DONE="--rm" 

# Used for external volume
export BUILD_OUTPUT="${A6I_DEVOPS_ROOT}/pipelines/${PIPELINE_ID}/output"

# Run build in build container
#
echo
echo "${INFO_PROMPT} About to start build server container..."
docker run ${REMOVE_CONTAINER_WHEN_DONE} \
            -e TIMESTAMP=${TIMESTAMP} -e APODEIXI_VERSION=${APODEIXI_VERSION} -e APODEIXI_GIT_URL=${APODEIXI_GIT_URL} \
            -v ${BUILD_OUTPUT}:/home/output -v ${PIPELINE_SCRIPTS}:/home/scripts \
            ${A6I_BUILD_SERVER} & 2>/tmp/error # run in the background so rest of this script can proceed
if [[ $? != 0 ]]; then
    error=$(</tmp/error)
    echo "${ERR_PROMPT} ${error}"
    echo "${ERR_PROMPT} For more detail on error, check logs under ${BUILD_OUTPUT}"
    exit 1
fi

echo "${INFO_PROMPT} ...waiting for build server to start..."
sleep 3

export BUILD_CONTAINER=$(docker ps -q -l) 2>/tmp/error
if [[ $? != 0 ]]; then
    error=$(</tmp/error)
    echo "${ERR_PROMPT} ${error}"
    echo "${ERR_PROMPT} For more detail on error, check logs under ${BUILD_OUTPUT}"
    exit 1
fi

echo "${INFO_PROMPT} Build server container ${BUILD_CONTAINER} up and running..."
echo "${INFO_PROMPT} ...attempting to build Apodeixi v${APODEIXI_VERSION}..."

echo "${INFO_PROMPT} ...will build Apodeixi in container ${BUILD_CONTAINER}..."
docker exec ${BUILD_CONTAINER} /bin/bash /home/scripts/build.sh 2>/tmp/error
if [[ $? != 0 ]]; then
    error=$(</tmp/error)
    echo "${ERR_PROMPT} ${error}"
    echo "${ERR_PROMPT} Due to above error, cleanup wasn't done. Container ${BUILD_CONTAINER} needs to be manually stopped"
    echo "${ERR_PROMPT} For more detail on error, check logs under ${BUILD_OUTPUT}"
    exit 1
fi

echo "${INFO_PROMPT} Build was successful"
echo "${INFO_PROMPT} ...stopping build container..."
echo "${INFO_PROMPT} ...stopped build container $(docker stop ${BUILD_CONTAINER})"
echo
echo "${INFO_PROMPT} Check logs and distribution under ${BUILD_OUTPUT}"
