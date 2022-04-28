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

export UBUNTU_IMAGE="ubuntu:20.04"
export UBUNTU_PYTHON_PACKAGE="python3.9"

export A6I_BUILD_SERVER="a6i-build-server"

docker build --build-arg UBUNTU_IMAGE --build-arg UBUNTU_PYTHON_PACKAGE -t ${A6I_BUILD_SERVER} .

