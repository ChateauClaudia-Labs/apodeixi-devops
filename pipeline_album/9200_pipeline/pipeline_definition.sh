#!/usr/bin/env bash

source ${_CFG__PIPELINE_ALBUM}/epoch_commons.sh

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
_CFG__pipeline_description() {
    echo "
    Flow type:                          Infrastructure flow
    Type of infrastructure built:       Create base image for ${_CFG__APPLICATION} deployables
    Packaged as:                        Docker image '${_CFG__APPLICATION_BASE_IMAGE}'
    Deployed to:                        Local Linux host (same host in which pipeline is run)
    "
}

# Single-line description suitable for use when listing multiple pipelines
_CFG__pipeline_short_description() {
    echo "Creates locally the base image for ${_CFG__APPLICATION} deployables: '${_CFG__APPLICATION_BASE_IMAGE}'"
}
