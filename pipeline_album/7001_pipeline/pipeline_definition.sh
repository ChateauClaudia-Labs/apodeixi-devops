#!/usr/bin/env bash

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
pipeline_description() {
    echo "
    Flow type:                          Conda flow
    Apodexi version built:              v${APODEIXI_VERSION}
    Packaged as:                        Conda package 'apodeixi', ${APODEIXI_GIT_BRANCH}
    Deployed to:                        Conda channel https://anaconda.org/alejandro-ccl/repo
    "
}

# Single-line description suitable for use when listing multiple pipelines
pipeline_short_description() {
    echo "Deploys Apodeixi v${APODEIXI_VERSION} as a Conda package in channel https://anaconda.org/alejandro-ccl/repo"
}

export UBUNTU_IMAGE="ubuntu:20.04"
export PYTHON_VERSION="3.9"
export UBUNTU_PYTHON_PACKAGE="python3.9"

# Release version that is to be built
export APODEIXI_VERSION="0.9.9"
export APODEIXI_GIT_BRANCH="v${APODEIXI_VERSION}"
export CONDA_RECIPE="apodeixi_${APODEIXI_VERSION}_recipe"

export APODEIXI_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

export APODEIXI_TESTDB_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi-testdb.git"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export A6I_CONDABUILD_SERVER="a6i-condabuild-server"

# Defines the name (& tag) for the Apodeixi image to be created by the pipeline. If there is no tag, Docker will
# by default put a tag of ":latest"
#
APODEIXI_IMAGE="apodeixi"

export APODEIXI_CONFIG_DIRECTORY=${PIPELINE_ALBUM}/${PIPELINE_NAME}

export TEST_APODEIXI_CONFIG_DIRECTORY=${PIPELINE_ALBUM}/${PIPELINE_NAME}/apodeixi_testdb_config