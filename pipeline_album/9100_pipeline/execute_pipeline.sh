#!/usr/bin/env bash

source ${CCL_DEVOPS_CONFIG_PIPELINE_ALBUM}/epoch_commons.sh

#
# GOTCHA: Invoke pipeline steps so that $0 is set to their full path, since each step assumes
#       $0 refers to that pipeline step's script. This means that:
#       1. Invoke the script directly, not by using the 'source' command
#       2. Invoke them via their full path
#       3. To ensure environment variables referenced here are set, the caller should have invoked this script using 'source'
#
echo "${INFO_PROMPT} Running create_build_server step..."
T0=$SECONDS
${CCL_DEVOPS_SERVICE_ROOT}/src/docker_flow/infrastructure/create_build_server.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T1=$SECONDS
echo "${INFO_PROMPT} ... completed create_build_server step in $(($T1 - $T0)) sec"
