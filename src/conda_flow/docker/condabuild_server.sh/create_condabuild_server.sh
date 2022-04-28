#!/usr/bin/env bash

# This script creates an image for a container that can be used to create a conda package for Apodeixi
#
#
# As a precondition to running this script, the Docker daemon must be running. To start it in WSL2 Ubuntu, do someting like:
#
#               sudo service docker start
#
export DOCKER_FILE_DIR="$( cd "$( dirname $0 )" >/dev/null 2>&1 && pwd )"

export UBUNTU_IMAGE="ubuntu:20.04"

export A6I_CONDABUILD_SERVER="a6i-condabuild-server"

docker build --build-arg UBUNTU_IMAGE -t ${A6I_CONDABUILD_SERVER} .

