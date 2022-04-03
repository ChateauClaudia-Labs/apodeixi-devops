#!/bin/sh

# This script creates an image for a container where Apodeixi runs, and provisions it with the relevant software.
#
# To run this script, change directory to the location of this script and do something like this from a command tool
#
#               bash create_apodeixi_server.sh
#
# As a precondition, the Docker daemon must be running. To start it in WSL2 Ubuntu, do someting like:
#
#               sudo service docker start
#
# After the image is built, to inspect it from within you can start a shell as root in the container, like this:
#
#               docker run -it --rm apodeixi /bin/bash

export UBUNTU_IMAGE="ubuntu:20.04"
export PYTHON_VERSION="3.9"
export APODEIXI_VERSION="0.9.4"

# GOTCHA: Docker realies on a "context folder" to build images. This "context folder" is "passed" to the Docker daemon, so all 
# files in the host that are referenced during the Docker build process must be in that folder or some sub-folder, not
# in "super directories" like ../ since they are not reachable by the Docker daemon.
#
# Therefore, we create a working folder to be used as the "context folder", and move into it any other files that are
# needed in the Docker process. That way they are all in 1 place.
export APODEIXI_DIST="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/devops/output/dist"
export PROVISIONING_DOCKERFILE="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/devops/docker/apodeixi_server/Dockerfile"
export WORK_FOLDER="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/devops/output/provisioning_work"
mkdir ${WORK_FOLDER}

cp ${PROVISIONING_DOCKERFILE} ${WORK_FOLDER}
cp ${APODEIXI_DIST}/apodeixi-${APODEIXI_VERSION}-py3-none-any.whl ${WORK_FOLDER}

# pip does not come with the Ubuntu python distribution, unfortunately, so we need to download this module to later help us get
# python. The Dockerfile will copy this `get-pip.py` script so that it can be invoked from within the apodeixi container
# in order to provision pip
cd ${WORK_FOLDER}
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

# Apodeixi environment settings
export APODEIXI_SECRETS_FOLDER="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/UAT_ENV/secrets"
export APODEIXI_COLLABORATION_AREA="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/UAT_ENV/collaboration_area"
export APODEIXI_KNOWLEDGE_BASE_FOLDER="C:/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi/UAT_ENV/kb"

docker build --build-arg UBUNTU_IMAGE --build-arg PYTHON_VERSION -t apodeixi ${WORK_FOLDER}

