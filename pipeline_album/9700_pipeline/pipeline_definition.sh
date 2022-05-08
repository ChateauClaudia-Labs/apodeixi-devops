#!/usr/bin/env bash

source ${_CFG__PIPELINE_ALBUM}/epoch_commons.sh

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
