#!/usr/bin/env bash

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
pipeline_description() {
    echo "
    Flow type:                          Docker flow
    Apodexi version built:              v0.9.7
    Packaged as:                        Docker container for image 'apodeixi:latest'
    Deployed to:                        Local Linux host (same host in which pipeline is run)
    "
}

# Single-line description suitable for use when listing multiple pipelines
pipeline_short_description() {
    echo "Deploys Apodeixi v0.9.7 as a Linux container locally"
}

export UBUNTU_IMAGE="ubuntu:20.04"
export PYTHON_VERSION="3.9"

# Release version that is to be built
export APODEIXI_VERSION="0.9.7"

export APODEIXI_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export A6I_BUILD_SERVER="a6i-build-server"

# Defines the name (& tag) for the Apodeixi image to be created by the pipeline. If there is no tag, Docker will
# by default put a tag of ":latest"
#
APODEIXI_IMAGE="apodeixi"