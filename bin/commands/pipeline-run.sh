#!/usr/bin/env bash

# Script to implement the behavior of the `apdo pipeline run` command for the `apdo` CLI

source ${A6I_DEVOPS_ROOT}/bin/util/apdo-common.sh

# Check that a command  passed as argument $1. Set the error message to use in $ERROR_MSG
export ERR_MSG="pipeline ID must be given. Try 'apdo pipeline list' to view a list of available pipeline IDs"
cli_argument_exists $1

export PIPELINE_ID="$1_pipeline" # For example, '1001_pipeline'. This is a folder with parameters defining a particular pipeline 

# Check that there is a pipeline for this id
[ ! -d "${A6I_DEVOPS_ROOT}/pipelines/${PIPELINE_ID}" ] && echo \
&& echo "${ERROR_PROMPT} ${PIPELINE_ID} is not a valid ID for a pipeline" \
&& echo "${ERROR_PROMPT} Try 'apdo pipeline list' to view a list of available pipeline IDs" \
&& echo \
&& exit 1

# Check that pipeline folder includes a pipeline definition
[ ! -f "${A6I_DEVOPS_ROOT}/pipelines/${PIPELINE_ID}/pipeline_definition.sh" ] && echo \
&& echo "${ERROR_PROMPT} ${PIPELINE_ID} is improperly configured:" \
&& echo "${ERROR_PROMPT} It should contain a 'pipeline_definition'.sh file with a function called 'pipeline_description'" \
&& echo \
&& exit 1


# Get definition (really more of a config) of the pipeline we are running
source "${A6I_DEVOPS_ROOT}/pipelines/${PIPELINE_ID}/pipeline_definition.sh"

# NOT YET IMPLEMENTED, SO LET THE USER KNOW
echo
echo "..... Sorry, 'apdo pipeline run' is not yet implemented ... :-("
echo


# TODO: implement the running of the pipeline as per the parameters in the pipeline_definition.sh