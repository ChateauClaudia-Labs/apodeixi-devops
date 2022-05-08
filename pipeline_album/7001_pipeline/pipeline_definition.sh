#!/usr/bin/env bash

source ${_CFG__PIPELINE_ALBUM}/epoch_commons.sh

# This variable holds a text description of what this pipeline does. This is needed by the discover_pipelines.sh
# script to help DevOps operators discover which pipeline to use by interrogating pipelines on what their purpose is.
# So this variable is required for all pipelines.
_CFG__pipeline_description() {
    echo "
    Flow type:                          Conda flow
    Apodexi version built:              v${_CFG__DEPLOYABLE_VERSION}
    Packaged as:                        Conda package 'apodeixi', ${_CFG__DEPLOYABLE_GIT_BRANCH}
    Platforms:                          win-64, linux-64 packages are created.
    Deployed to:                        Distributions left in pipeline's output. Manually login to Anaconda to upload to channel https://anaconda.org/alejandro-ccl/repo
    "
}

# Single-line description suitable for use when listing multiple pipelines
_CFG__pipeline_short_description() {
    echo "Creates Linux and Windows distributions Apodeixi v${_CFG__DEPLOYABLE_VERSION} suitable to upload to https://anaconda.org/alejandro-ccl/repo"
}

# Release version that is to be built
#   GOTCHA:
#       If you change it, you must change version in **multiple** places:
#       -In pipeline definition (this file)
#       -In name of Conda recipe folder under src/conda_flow/conda_recipes
#       -In the meta.yaml file inside the Conda recipe folder
export _CFG__DEPLOYABLE_VERSION="0.9.10"

export _CFG__DEPLOYABLE_GIT_BRANCH="v${_CFG__DEPLOYABLE_VERSION}"
export _CFG__CONDA_RECIPE="apodeixi_${_CFG__DEPLOYABLE_VERSION}_recipe"
