#!/usr/bin/env bash

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
pipeline_description() {
    echo "
    Flow type:                          Infrastructure flow
    Type of infrastructure built:       Build server used by Conda flow pipelines
    Packaged as:                        Docker image '${A6I_CONDABUILD_SERVER}'
    Deployed to:                        Local Linux host (same host in which pipeline is run)
    "
}

# Single-line description suitable for use when listing multiple pipelines
pipeline_short_description() {
    echo "Creates locally the infrastructure needed by Conda flow pipelines: '${A6I_CONDABUILD_SERVER}'"
}

export UBUNTU_IMAGE="ubuntu:20.04"
export A6I_CONDABUILD_SERVER="a6i-condabuild-server"

export ANACONDA_VERSION="2021.11-Linux-x86_64"

# To validate we download a legitimate Anaconda version, we will try to match it against the public
# Anaconda hashes for the version we are using, as documented in  https://docs.anaconda.com/anaconda/install/hashes/lin-3-64/
# 
export ANACONDA_SHA="fedf9e340039557f7b5e8a8a86affa9d299f5e9820144bd7b92ae9f7ee08ac60"

