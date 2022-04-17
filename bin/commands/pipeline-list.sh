#!/usr/bin/env bash

# Script to implement the behavior of the `apdo pipeline list` command for the `apdo` CLI

source ${A6I_DEVOPS_ROOT}/bin/util/apdo-common.sh

#echo "$(ls ${A6I_DEVOPS_ROOT}/pipelines/)"

# directories are in the form <ID>_pipeline. So to ghet the ID, split by delimeter "_pipeline"
# We achieve this by piping the list of relative directory names to the 'tr' translate command, that will replace the 
# '_pipeline' by newlines
pipeline_ids=$(ls ${A6I_DEVOPS_ROOT}/pipelines/ | tr "_pipeline" "\n")

echo # empty line for readability
for id in $pipeline_ids
do
    # Check that pipeline folder includes a pipeline definition
    cli_pipeline_def_exists ${A6I_DEVOPS_ROOT} ${id}_pipeline

    # Get definition (really more of a config) of the pipeline we are running
    source "${A6I_DEVOPS_ROOT}/pipelines/${id}_pipeline/pipeline_definition.sh"
    pipeline_short_description > /tmp/pipeline_short_desc
    desc=$(</tmp/pipeline_short_desc)
    echo "$id           $desc"
done
echo # empty line for readability
