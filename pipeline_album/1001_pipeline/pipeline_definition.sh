#!/usr/bin/env bash

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
pipeline_description() {
    echo "
    Flow type:                          Docker flow
    Apodexi version built:              v${APODEIXI_VERSION}
    Packaged as:                        Docker container for image 'apodeixi:latest'
    Deployed to:                        UAT environment in local Linux host (same host in which pipeline is run)
    Secrets:                            ${SECRETS_FOLDER}
    Collaboration area:                 ${COLLABORATION_AREA}
    Knowledge Base:                     ${KNOWLEDGE_BASE_FOLDER}
    Apodeixi config directory:          ${APODEIXI_CONFIG_DIRECTORY}
    "
}

# Single-line description suitable for use when listing multiple pipelines
pipeline_short_description() {
    echo "Deploys Apodeixi v${APODEIXI_VERSION} as a Linux container locally to ${ENVIRONMENT}"
}

export UBUNTU_IMAGE="ubuntu:20.04"
export PYTHON_VERSION="3.9"
export UBUNTU_PYTHON_PACKAGE="python3.9"

# Release version that is to be built
export APODEIXI_GIT_BRANCH="v${APODEIXI_VERSION}"
export APODEIXI_VERSION="0.9.8"

export APODEIXI_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

export APODEIXI_TESTDB_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi-testdb.git"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export A6I_BUILD_SERVER="a6i-build-server"

# Defines the name (& tag) for the Apodeixi image to be created by the pipeline. If there is no tag, Docker will
# by default put a tag of ":latest"
#
APODEIXI_IMAGE="apodeixi"

# Defines what Apodeixi environment is being mounted in the Apodeixi container by this pipeline
#
export ENVIRONMENT="UAT_ENV"

# NB: ${A6I_DEVOPS_ROOT} is meant to have been set earlier. For Docker flows that ahppens in 
#       src/docker_flow/pipeline_steps/common.sh
export SECRETS_FOLDER=${A6I_DEVOPS_ROOT}/../${ENVIRONMENT}/secrets
export COLLABORATION_AREA=${A6I_DEVOPS_ROOT}/../${ENVIRONMENT}/collaboration_area
export KNOWLEDGE_BASE_FOLDER=${A6I_DEVOPS_ROOT}/../${ENVIRONMENT}/kb

export APODEIXI_CONFIG_DIRECTORY=${PIPELINE_ALBUM}/${PIPELINE_NAME}

export TEST_APODEIXI_CONFIG_DIRECTORY=${PIPELINE_ALBUM}/${PIPELINE_NAME}/apodeixi_testdb_config