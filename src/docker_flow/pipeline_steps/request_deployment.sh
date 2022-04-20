#!/usr/bin/env bash

# This script deploys Apodeixi to a chosen environment. I.e., it launches a container running Apodeixi with the
# appropriate configuration that, in particular, points to an environment's data volumes.
#
# To run this script, change directory to the location of this script and do something like this from a command tool
#
#               bash request_deployment.sh
#
# As a precondition, the Docker daemon must be running. To start it in WSL2 Ubuntu, do someting like:
#
#               sudo service docker start
#
export A6I_DEVOPS_ROOT="$( cd "$( dirname $0 )/../../../" >/dev/null 2>&1 && pwd )"
export PIPELINE_SCRIPTS="${A6I_DEVOPS_ROOT}/src/docker_flow/pipeline_steps"

source ${PIPELINE_SCRIPTS}/common.sh

echo
echo "${INFO_PROMPT} ---------------- Starting deployment step"
echo
# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this sript took
SECONDS=0

# Comment this environment variable if we want to keep the Apodeixi container (e.g., to inspect problems) after we stop it
export REMOVE_CONTAINER_WHEN_DONE="--rm" 

# Check that Apodeixi config file exists
[ ! -f ${APODEIXI_CONFIG_DIRECTORY}/apodeixi_config.toml ] && echo \
    && echo "${ERR_PROMPT} '${PIPELINE_ALBUM}/${PIPELINE_ID}' is improperly configured:" \
    && echo "${ERR_PROMPT} It expects Apodeixi config file, which doesn't exist:" \
    && echo "${ERR_PROMPT}     ${APODEIXI_CONFIG_DIRECTORY}/apodeixi_config.toml" \
    && echo \
    && exit 1

# Check that mounted volumes for the Apodeixi environment exist
[ ! -d ${SECRETS_FOLDER} ] && echo \
        && echo "${ERR_PROMPT} '${PIPELINE_ALBUM}/${PIPELINE_ID}' is improperly configured:" \
        && echo "${ERR_PROMPT} It expects a non-existent folder called "\
        && echo "    ${SECRETS_FOLDER}." \
        && echo \
        && exit 1
[ ! -d ${COLLABORATION_AREA} ] && echo \
        && echo "${ERR_PROMPT} '${PIPELINE_ALBUM}/${PIPELINE_ID}' is improperly configured:" \
        && echo "${ERR_PROMPT} It expects a non-existent a folder called " \
        && echo "    ${COLLABORATION_AREA}." \
        && echo \
        && exit 1
[ ! -d ${KNOWLEDGE_BASE_FOLDER} ] && echo \
    && echo "${ERR_PROMPT} '${PIPELINE_ALBUM}/${PIPELINE_ID}' is improperly configured:" \
    && echo "${ERR_PROMPT} It expects a non-existent a folder called " \
    && echo "    ${KNOWLEDGE_BASE_FOLDER}." \
        && echo \
   && exit 1



echo "${INFO_PROMPT} About to start Apodeixi container..."
docker run ${REMOVE_CONTAINER_WHEN_DONE} \
            -e APODEIXI_CONFIG_DIRECTORY="/home/apodeixi/config" \
            -v ${SECRETS_FOLDER}:/home/apodeixi/secrets -v ${COLLABORATION_AREA}:/home/apodeixi/collaboration_area  \
            -v ${KNOWLEDGE_BASE_FOLDER}:/home/apodeixi/kb -v ${APODEIXI_CONFIG_DIRECTORY}:/home/apodeixi/config \
            ${APODEIXI_IMAGE} & 2>/tmp/error # run in the background 
abort_on_error

echo "${INFO_PROMPT} ...waiting for Apodeixi to start..."
sleep 3 
export APODEIXI_CONTAINER=$(docker ps -q -l) 2>/tmp/error
abort_on_error

echo "${INFO_PROMPT} Apodeixi container ${APODEIXI_CONTAINER} up and running..."

# GOTCHA - IF TESTING WITH BATS, WE MUST STOP THE CONTAINER TO PREVENT BATS FROM HANGING.
#       There are other mechanisms in the Bats documentation to avoid hanging (basically, to close file descriptor 3)
#       but they don't work in the context of Docker. Only thing I found works is stopping the container so that
#       Bats then gets unblocked and finishes up the test
if [ ! -z ${RUNNING_BATS} ]
    then
        echo "${INFO_PROMPT} ...stopping build container..."
        echo "${INFO_PROMPT} ...stopped build container $(docker stop ${APODEIXI_CONTAINER})"
        echo
fi

# Compute how long we took in this script
duration=$SECONDS
echo
echo "${INFO_PROMPT} ---------------- Completed deployment step in $duration sec"
echo
echo "${INFO_PROMPT} Check logs and distribution under ${PIPELINE_STEP_OUTPUT}"
