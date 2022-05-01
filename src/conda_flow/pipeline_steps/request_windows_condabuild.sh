#!/usr/bin/env bash

# This script builds a Windows distribution for Apodeixi by using a specific one-off virtual environment to 
# do a conda-build for a given conda recipe for Apodeixi.
#

export A6I_DEVOPS_ROOT="$( cd "$( dirname $0 )/../../../" >/dev/null 2>&1 && pwd )"
export PIPELINE_SCRIPTS="${A6I_DEVOPS_ROOT}/src"

source ${PIPELINE_SCRIPTS}/util/common.sh

export CONDA_RECIPE_DIR=${PIPELINE_SCRIPTS}/conda_flow/conda_recipes/

echo
echo "${INFO_PROMPT} ---------------- Starting Windows conda build step"
echo
# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this sript took
SECONDS=0

echo "${INFO_PROMPT} About to prepare script to be run in  Windows buildS virtual environment..."

# Comment this environment variable if we want to keep the Conda virtual environment (e.g., to inspect problems) 
# after this script ends
export REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE=1

# To create Windows paths that work in Bash, we must transform WSL paths like
#
#       /mnt/c/Users/aleja/Documents/CodeImages/Technos/Anaconda3
#
#   to Windows Bash paths like
#
#       /c/Users/aleja/Documents/CodeImages/Technos/Anaconda3
#
#   So we use sed to eliminate the "/mnt" token upfront, with code inspired by this snippet run:
#
#       a=/mnt/c/Users/aleja/Documents/CodeImages/Technos/Anaconda3
#       b=$( echo $a | awk -Fmnt '{printf $2}')
#       echo $b
#               => /c/Users/aleja/Documents/CodeImages/Technos/Anaconda3
#
to_windows_path() {     # Expects $1 argument to be a Linux path that starts with /mnt/c/....
    result=$( echo $1 | awk -Fmnt '{printf $2}')
    abort_on_error
    echo $result
}

WIN_OUTPUT_DIR=$(to_windows_path ${PIPELINE_STEP_OUTPUT})

WORKING_DIR="${PIPELINE_STEP_OUTPUT}/work"
if [ ! -d "${WORKING_DIR}" ]; then
    ## Clean up any pre-existing files
    #rm -rf ${WORKING_DIR}
    mkdir ${WORKING_DIR}
fi
#mkdir ${WORKING_DIR}

WIN_ERR_PROMPT="${ERR_PROMPT}"
WIN_TIMESTAMP="${TIMESTAMP}"
WIN_CONDA_RECIPE="${CONDA_RECIPE}"
WIN_CONDA_RECIPE_DIR=$(to_windows_path ${CONDA_RECIPE_DIR})
WIN_REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE="${REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE}"

echo
echo "${INFO_PROMPT} ... these environment variables will be set in the script ..."
# Environment variables to include in the Windows bash script we will be calling:
#
echo "WIN_ANACONDA_DIR:                              ${WIN_ANACONDA_DIR}" # This comes from pipeline_definition.sh
echo "WIN_OUTPUT_DIR:                                ${WIN_OUTPUT_DIR}"
echo "WIN_ERR_PROMPT:                                ${WIN_ERR_PROMPT}"
echo "WIN_TIMESTAMP:                                 ${WIN_TIMESTAMP}"
echo "WIN_CONDA_RECIPE:                              ${WIN_CONDA_RECIPE}"
echo "WIN_CONDA_RECIPE_DIR:                          ${WIN_CONDA_RECIPE_DIR}"
echo "WIN_REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE:      ${WIN_REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE}"
echo
# Now insert environment variables on top of a copy of the script, building the script we will actually run
SCRIPT_TO_RUN=${WORKING_DIR}/windows_condabuild_$TIMESTAMP.sh
cp ${PIPELINE_SCRIPTS}/conda_flow/pipeline_steps/windows_condabuild.sh ${SCRIPT_TO_RUN}
abort_on_error

echo "SCRIPT_TO_RUN:                                 ${SCRIPT_TO_RUN}"
echo

#   GOTCHA
#
# When we apply sed on paths, we must replace sed's default delimeter "/" since the paths will also have
# that character "/", which will confuse sed. Also any other string wit "/" (e.g., "CI/CD") even if not a path.
# There are two possible remedies:
#       -Either escape the paths, changing paths like "/mnt/c/Users/..." to "\/mnt\/c\/Users..."
#       -Or use a different delimeter in sed, as long as it does not appear in paths.
#
#   I chose the latter for simplicy, using the character '#' as the sed delimeter. Hopefully no pipeline definition
#   will have paths using "#", as the calls to sed would then fail
#

echo "${INFO_PROMPT} ...inserting export WIN_ANACONDA_DIR=$(echo $WIN_ANACONDA_DIR)"
echo
sed -i "1s#^#export WIN_ANACONDA_DIR=$(echo $WIN_ANACONDA_DIR)\n#" ${SCRIPT_TO_RUN}
abort_on_error
echo
echo "      export WIN_OUTPUT_DIR=$(echo $WIN_OUTPUT_DIR)"
sed -i "1s#^#export WIN_OUTPUT_DIR=$(echo $WIN_OUTPUT_DIR)\n#" ${SCRIPT_TO_RUN}
abort_on_error
echo
echo "      export WIN_ERR_PROMPT='$(echo $WIN_ERR_PROMPT)'"
sed -i "1s#^#export WIN_ERR_PROMPT='$(echo $WIN_ERR_PROMPT)'\n#" ${SCRIPT_TO_RUN}
abort_on_error
echo
echo "      export WIN_TIMESTAMP=$(echo $WIN_TIMESTAMP)"
sed -i "1s/^/export WIN_TIMESTAMP=$(echo $WIN_TIMESTAMP)\n/" ${SCRIPT_TO_RUN}
abort_on_error
echo
echo "      export WIN_CONDA_RECIPE=$(echo $WIN_CONDA_RECIPE)"
sed -i "1s/^/export WIN_CONDA_RECIPE=$(echo $WIN_CONDA_RECIPE)\n/" ${SCRIPT_TO_RUN}
abort_on_error
echo
echo "      export WIN_CONDA_RECIPE_DIR=$(echo $WIN_CONDA_RECIPE_DIR)"
sed -i "1s#^#export WIN_CONDA_RECIPE_DIR=$(echo $WIN_CONDA_RECIPE_DIR)\n#" ${SCRIPT_TO_RUN}
abort_on_error
echo
echo "      export WIN_REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE=$(echo $WIN_REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE)"
sed -i "1s/^/export WIN_REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE=$(echo $WIN_REMOVE_VIRTUAL_ENVIRONMENT_WHEN_DONE)\n/" ${SCRIPT_TO_RUN}
abort_on_error
echo
echo "${INFO_PROMPT} ... done preparing the script that must be run in virtual environment"
echo
echo "${INFO_PROMPT} Attempting to run conda build for Apodeixi branch ${APODEIXI_GIT_BRANCH} in Windows Conda virtual environment..."
echo "${INFO_PROMPT}            (this might take a 5-10 minutes...)"

# When we run the script, we must refer to it by a Windows path, even if above we manipulated it in Linux and hence have
# been referring to it by its Linux path up to now
#
WIN_SCRIPT_TO_RUN=$(to_windows_path ${SCRIPT_TO_RUN})

${WIN_BASH_EXE} ${WIN_SCRIPT_TO_RUN}                                   2>/tmp/error
abort_on_error

echo
echo "${INFO_PROMPT} Windows conda build was successful"

# Compute how long we took in this script
duration=$SECONDS
echo
echo "${INFO_PROMPT} ---------------- Completed Windows conda build step in $duration sec"
echo
echo "${INFO_PROMPT} Check logs and distribution under ${PIPELINE_STEP_OUTPUT}"