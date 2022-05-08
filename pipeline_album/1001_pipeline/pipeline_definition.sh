#!/usr/bin/env bash

source ${_CFG__PIPELINE_ALBUM}/epoch_commons.sh

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
pipeline_description() {
    echo "
    Flow type:                          Docker flow
    Apodexi version built:              v${_CFG__DEPLOYABLE_VERSION}
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
    echo "Deploys Apodeixi v${_CFG__DEPLOYABLE_VERSION} as a Linux container locally to ${ENVIRONMENT}"
}

# Release version that is to be built
export _CFG__DEPLOYABLE_VERSION="0.9.10"
export _CFG__DEPLOYABLE_GIT_BRANCH="v${_CFG__DEPLOYABLE_VERSION}"

# Defines the name (& tag) for the Apodeixi image to be created by the pipeline. If there is no tag, Docker will
# by default put a tag of ":latest"
#
export _CFG__DEPLOYABLE_IMAGE="apodeixi"

# Defines what Apodeixi environment is being mounted in the Apodeixi container by this pipeline
#
export ENVIRONMENT="UAT_ENV"
export SECRETS_FOLDER=${A6I_ROOT}/${ENVIRONMENT}/secrets
export COLLABORATION_AREA=${A6I_ROOT}/${ENVIRONMENT}/collaboration_area
export KNOWLEDGE_BASE_FOLDER=${A6I_ROOT}/${ENVIRONMENT}/kb
