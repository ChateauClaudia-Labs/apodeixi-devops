#!/usr/bin/env bash

# This script creates an image for a container that can be used to build Apodeixi
#
# To run this script, change directory to the location of this script and do something like this from a command tool
#
#               bash create_build_server.sh
#
# As a precondition, the Docker daemon must be running. To start it in WSL2 Ubuntu, do someting like:
#
#               sudo service docker start
#
# After the image is built, to inspect it from within you can start a shell as root in the container, like this:
#
#               docker run -it --rm a6i-build-server /bin/bash
#
export A6I_DEVOPS_ROOT="$( cd "$( dirname $0 )/../../../" >/dev/null 2>&1 && pwd )"
export PIPELINE_SCRIPTS="${A6I_DEVOPS_ROOT}/src"

source ${PIPELINE_SCRIPTS}/util/common.sh

LOGS_DIR="${PIPELINE_STEP_OUTPUT}/logs" # This is a mount of a directory in host machine, so it might already exist
if [ ! -d "${LOGS_DIR}" ]; then
  mkdir ${LOGS_DIR}
fi
export SETUP_INFRA_LOG="${LOGS_DIR}/${TIMESTAMP}_setup_infra.txt"

# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this sript took
SECONDS=0

echo
echo "${INFO_PROMPT} ---------------- Building build server's image '${A6I_BUILD_SERVER}'"
echo
echo "${INFO_PROMPT} UBUNTU_IMAGE=${UBUNTU_IMAGE}"
echo "${INFO_PROMPT} UBUNTU_PYTHON_PACKAGE=${UBUNTU_PYTHON_PACKAGE}"
echo

export DOCKERFILE_DIR=${PIPELINE_SCRIPTS}/docker_flow/docker/build_server
cd ${DOCKERFILE_DIR}
echo "${INFO_PROMPT} Current directory is ${DOCKERFILE_DIR}"
echo
echo "${INFO_PROMPT} Running Docker build..."
echo
docker build --build-arg UBUNTU_IMAGE --build-arg UBUNTU_PYTHON_PACKAGE -t ${A6I_BUILD_SERVER} . 1>> ${SETUP_INFRA_LOG} 2>/tmp/error
abort_on_error

# Compute how long we took in this script
duration=$SECONDS
echo
echo "${INFO_PROMPT} ---------------- Completed creating image for build server in $duration sec"
echo

