#!/usr/bin/env bash

source ${_CFG__PIPELINE_ALBUM}/epoch_commons.sh

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
_CFG__pipeline_description() {
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
_CFG__pipeline_short_description() {
    echo "Deploys local Apodeixi dev branch as a Linux container to ${ENVIRONMENT} (for user Alex in host CC-Labs-2)"
}

# Release version that is to be built
export _CFG__DEPLOYABLE_GIT_BRANCH="dev"
export _CFG__DEPLOYABLE_VERSION="dev"


# Inputs for function: epoch_commons.sh::_CFG__set_build_docker_options
#
# Purpose: function is called by CCL-DevOps to set _CFG__BUILD_DOCKER_OPTIONS
#
export MOUNT_APODEIXI_GIT_PROJECT=1
export _CFG__DEPLOYABLE_GIT_URL="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/a6i_repos/apodeixi"
export _CFG__TESTDB_GIT_URL="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/a6i_repos/apodeixi-testdb"

# Defines the name (& tag) for the Apodeixi image to be created by the pipeline. If there is no tag, Docker will
# by default put a tag of ":latest"
#
_CFG__DEPLOYABLE_IMAGE="apodeixi:dev"

# Inputs for function: epoch_commons.sh::_CFG__set_deployment_docker_options
#
# Purpose: function is called by CCL-DevOps to set _CFG__DEPLOYMENT_DOCKER_OPTIONS
#
export ENVIRONMENT="UAT_ENV"
export SECRETS_FOLDER=${A6I_ROOT}/${ENVIRONMENT}/secrets
export COLLABORATION_AREA=${A6I_ROOT}/${ENVIRONMENT}/collaboration_area
export KNOWLEDGE_BASE_FOLDER=${A6I_ROOT}/${ENVIRONMENT}/kb
