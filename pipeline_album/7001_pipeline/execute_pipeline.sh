#
# GOTCHA: Invoke pipeline steps so that $0 is set to their full path, since each step assumes
#       $0 refers to that pipeline step's script. This means that:
#       1. Invoke the script directly, not by using the 'source' command
#       2. Invoke them via their full path
#       3. To ensure environment variables referenced here are set, the caller should have invoked this script using 'source'
#
echo "${INFO_PROMPT} Running build step..."
T0=$SECONDS
${A6I_DEVOPS_ROOT}/src/conda_flow/pipeline_steps/request_condabuild.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T1=$SECONDS
echo "${INFO_PROMPT} ... completed build step in $(($T1 - $T0)) sec"

echo "${INFO_PROMPT} Running Linux test step ..."
${A6I_DEVOPS_ROOT}/src/conda_flow/pipeline_steps/request_linux_test.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T2=$SECONDS
echo "${INFO_PROMPT} ... completed Linux install-and-test step in $(($T2 - $T1)) sec"

echo "${INFO_PROMPT} Running Windows test step ..."
${A6I_DEVOPS_ROOT}/src/conda_flow/pipeline_steps/request_windows_test.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T2=$SECONDS
echo "${INFO_PROMPT} ... completed Windows install-and-test step in $(($T2 - $T1)) sec"


echo "${INFO_PROMPT} Running upload-to-Anaconda step..."
${A6I_DEVOPS_ROOT}/src/conda_flow/pipeline_steps/request_anaconda_upload.sh ${PIPELINE_ID} &>> ${PIPELINE_LOG}
abort_pipeline_step_on_error
T4=$SECONDS
echo "${INFO_PROMPT} ... completed upload-to-Anaconda step in $(($T4 - $T3)) sec"

