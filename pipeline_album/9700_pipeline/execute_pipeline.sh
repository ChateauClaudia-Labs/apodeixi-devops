#
# GOTCHA: Invoke pipeline steps so that $0 is set to their full path, since each step assumes
#       $0 refers to that pipeline step's script. This means that:
#       1. Invoke the script directly, not by using the 'source' command
#       2. Invoke them via their full path
#       3. To ensure environment variables referenced here are set, the caller should have invoked this script using 'source'
#
echo "${_SVC__INFO_PROMPT} Running create_condabuild_server step..."
T0=$SECONDS
${_SVC__ROOT}/src/conda_flow/infrastructure/create_condabuild_server.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T1=$SECONDS
echo "${_SVC__INFO_PROMPT} ... completed create_condabuild_server step in $(($T1 - $T0)) sec"


