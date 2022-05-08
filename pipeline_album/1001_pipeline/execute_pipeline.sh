#
# GOTCHA: Invoke pipeline steps so that $0 is set to their full path, since each step assumes
#       $0 refers to that pipeline step's script. This means that:
#       1. Invoke the script directly, not by using the 'source' command
#       2. Invoke them via their full path
#       3. To ensure environment variables referenced here are set, the caller should have invoked this script using 'source'
#
echo "${INFO_PROMPT} Running build step..."
T0=$SECONDS
${_SVC__ROOT}/src/docker_flow/pipeline_steps/request_build.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T1=$SECONDS
echo "${INFO_PROMPT} ... completed build step in $(($T1 - $T0)) sec"

echo "${INFO_PROMPT} Running provisioning step..."
${_SVC__ROOT}/src/docker_flow/pipeline_steps/request_provisioning.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T2=$SECONDS
echo "${INFO_PROMPT} ... completed provisioning step in $(($T2 - $T1)) sec"

echo "${INFO_PROMPT} Running testrun step..."
${_SVC__ROOT}/src/docker_flow/pipeline_steps/request_testrun.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T3=$SECONDS
echo "${INFO_PROMPT} ... completed testrun step in $(($T3 - $T2)) sec"

echo "${INFO_PROMPT} Running deployment step..."
${_SVC__ROOT}/src/docker_flow/pipeline_steps/request_deployment.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
export APODEIXI_CONTAINER=$(docker ps -q -l)
abort_pipeline_step_on_error
T4=$SECONDS
echo "${INFO_PROMPT} ... Apodeixi is up in container ${APODEIXI_CONTAINER}"
echo "${INFO_PROMPT} ... completed deployment step in $(($T4 - $T3)) sec"

