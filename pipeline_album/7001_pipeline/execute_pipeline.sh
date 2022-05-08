# This will define the execute_conda_flow_step function
source ${_CFG__PIPELINE_ALBUM}/execution_commons.sh

execute_conda_flow_step request_linux_condabuild.sh "Linux conda build step"

execute_conda_flow_step request_linux_test.sh "Linux test step"

execute_conda_flow_step request_windows_condabuild.sh "Windows conda build step"

execute_conda_flow_step request_windows_test.sh "Windows test step"

# For now we don't support automatic uploading to anaconda. That must be done manually.
#   To support it, something will have to be troubleshooted around Anaconda login authentication, since that
#   fails in Bash
#
#execute_conda_flow_step request_anaconda_upload.sh "pload-to-Anaconda step"

