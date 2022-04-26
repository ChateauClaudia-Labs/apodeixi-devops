#!/usr/bin/env bash

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
pipeline_description() {
    echo "
    Flow type:                          Docker flow
    Apodexi version built:              Alex's 'dev' branch in host CC-Labs-2
    Packaged as:                        Docker container for image 'apodeixi:dev'
    Deployed to:                        Local Linux host (same host in which pipeline is run)
    Secrets:                            ${SECRETS_FOLDER}
    Collaboration area:                 ${COLLABORATION_AREA}
    Knowledge Base:                     ${KNOWLEDGE_BASE_FOLDER}
    Apodeixi config directory:          ${APODEIXI_CONFIG_DIRECTORY}
    "
}

# Single-line description suitable for use when listing multiple pipelines
pipeline_short_description() {
    echo "Deploys local Apodeixi dev branch as a Linux container (for user Alex in host CC-Labs-2)"
}

export UBUNTU_IMAGE="ubuntu:20.04"
export PYTHON_VERSION="3.9"
export UBUNTU_PYTHON_PACKAGE="python3.9"

# Release version that is to be built
export APODEIXI_GIT_BRANCH="dev"
export APODEIXI_VERSION="0.9.8"

# The build container will not be able to reference the git repo we want to build, since the container won't
# have access to what, from its perspective, is a remote machine containing the repo.
# So instead, by setting $MOUNT_APODEIXI_GIT_PROJECT, the pipeline will mount this remote directory
# $APODEIXI_GIT_URL onto a folder inside the container
export MOUNT_APODEIXI_GIT_PROJECT=1
export APODEIXI_GIT_URL="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/a6i_repos/apodeixi"
export APODEIXI_TESTDB_GIT_URL="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/a6i_repos/apodeixi-testdb"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export A6I_BUILD_SERVER="a6i-build-server"

# Defines the name (& tag) for the Apodeixi image to be created by the pipeline. If there is no tag, Docker will
# by default put a tag of ":latest"
#
APODEIXI_IMAGE="apodeixi:dev"

# Defines what Apodeixi environment is being mounted in the Apodeixi container by this pipeline
#
export ENVIRONMENT="UAT_ENV"

export SECRETS_FOLDER=${A6I_DEVOPS_ROOT}/../${ENVIRONMENT}/secrets
export COLLABORATION_AREA=${A6I_DEVOPS_ROOT}/../${ENVIRONMENT}/collaboration_area
export KNOWLEDGE_BASE_FOLDER=${A6I_DEVOPS_ROOT}/../${ENVIRONMENT}/kb

export APODEIXI_CONFIG_DIRECTORY=${PIPELINE_ALBUM}/${PIPELINE_ID}

export TEST_APODEIXI_CONFIG_DIRECTORY=${PIPELINE_ALBUM}/${PIPELINE_ID}/apodeixi_testdb_config