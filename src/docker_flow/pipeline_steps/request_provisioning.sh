#!/usr/bin/env bash

# This script creates an image for a container where Apodeixi runs, and provisions it with the relevant software.
#
# To run this script, change directory to the location of this script and do something like this from a command tool
#
#               bash request_provisioning.sh
#
# As a precondition, the Docker daemon must be running. To start it in WSL2 Ubuntu, do someting like:
#
#               sudo service docker start
#
# After the image is built, to inspect it from within you can start a shell as root in the container, like this:
#
#               docker run -it --rm apodeixi /bin/bash

export A6I_DEVOPS_ROOT="$( cd "$( dirname $0 )/../../../" >/dev/null 2>&1 && pwd )"
export PIPELINE_SCRIPTS="${A6I_DEVOPS_ROOT}/src/docker_flow/pipeline_steps"

source ${PIPELINE_SCRIPTS}/common.sh

export UBUNTU_IMAGE="ubuntu:20.04"
export PYTHON_VERSION="3.9"

echo
echo "${INFO_PROMPT} ---------------- Starting provisioning step"
echo
echo "${INFO_PROMPT} UBUNTU_IMAGE=${UBUNTU_IMAGE}"
echo "${INFO_PROMPT} INFO_PROMPT=${PYTHON_VERSION}"
echo
# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this sript took
SECONDS=0

# GOTCHA: Docker relies on a "context folder" to build images. This "context folder" is "passed" to the Docker daemon, so all 
# files in the host that are referenced during the Docker build process must be in that folder or some sub-folder, not
# in "super directories" like ../ since they are not reachable by the Docker daemon.
#
# Therefore, we create a working folder to be used as the "context folder", and move into it any other files that are
# needed in the Docker process. That way they are all in 1 place.
export APODEIXI_DIST="${PIPELINE_STEP_INTAKE}/dist"
export PROVISIONING_DOCKERFILE="${A6I_DEVOPS_ROOT}/src/docker_flow/docker/apodeixi_server/Dockerfile"
export WORK_FOLDER="${PIPELINE_STEP_OUTPUT}/provisioning_work"
mkdir ${WORK_FOLDER}

echo "${INFO_PROMPT} Copying Dockerfile to work folder"
cp ${PROVISIONING_DOCKERFILE} ${WORK_FOLDER} 2>/tmp/error
abort_on_error

echo "${INFO_PROMPT} Copying Apodeixi distribution to work folder"
cp ${APODEIXI_DIST}/apodeixi-${APODEIXI_VERSION}-py3-none-any.whl ${WORK_FOLDER} 2>/tmp/error
abort_on_error

# pip does not come with the Ubuntu python distribution, unfortunately, so we need to download this module to later help us get
# python. The Dockerfile will copy this `get-pip.py` script so that it can be invoked from within the apodeixi container
# in order to provision pip
echo "${INFO_PROMPT} Switching directory to work folder"
cd ${WORK_FOLDER}

echo "${INFO_PROMPT} Downlod pip to work folder"
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

echo "${INFO_PROMPT} Build Apodeixi image '${APODEIXI_IMAGE}'"
docker build --build-arg UBUNTU_IMAGE \
            --build-arg PYTHON_VERSION \
            --build-arg APODEIXI_VERSION \
            -t ${APODEIXI_IMAGE} ${WORK_FOLDER} 2>/tmp/error
abort_on_error

# Compute how long we took in this script
duration=$SECONDS
echo
echo "${INFO_PROMPT} ---------------- Completed provisioning step in $duration sec"
echo
echo "${INFO_PROMPT} Check logs and distribution under ${PIPELINE_STEP_OUTPUT}"