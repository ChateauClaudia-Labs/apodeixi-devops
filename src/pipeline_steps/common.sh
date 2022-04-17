#!/usr/bin/env bash

# This script has some common settings and logic applicable to all pipeline steps.
# It is expected to be sourced by each pipeline step's request script. 
# It requires that ${A6I_DEVOPS_ROOT} be set up prior to sourcing this script.

# Unique timestamp used e.g., as a prefix in the names of log files
# For example, "220331.120319" is a run done at 12:03 pm (and 19 seconds) on March 31, 2022
export TIMESTAMP="$(date +"%y%m%d.%H%M%S")"

export ERR_PROMPT="[A6I CI/CD ERROR]"
export INFO_PROMPT="[A6I CI/CD INFO]"

# Check that the pipeline id was passed as argument $1
if [ -z "$1" ]
  then
    echo "${ERR_PROMPT} Pipeline id was not provided as an argument. It should be an integer id like '1001'"
    exit 1
fi
export PIPELINE_FOLDER="$1_pipeline" # For example, '1001_pipeline'. This is a folder with parameters defining a particular pipeline   
echo "${INFO_PROMPT} Running pipeline '${PIPELINE_FOLDER}'"

# By default, we use the pipelines in this project unless a pipeline "album" has been injected. A pipeline "album"
# is simply a folder with subfolders called <ID>_pipeline, where <ID> identifies a pipeline in the "album".
# Teach <ID>_pipeline folder contains subfolder for runs on the pipeline (logs, output, ...) and also contains a file
# defining the pipeline ('pipeline_definition.sh'). This definition is interpreted by Apodeixi DevOps' code to run the 
# the generic pipeline steps but as configured specifically for the pipeline idenfified by <ID>
#
# So if the caller has set the variable ${PIPELINE_ALBUM}, we use that; else we default it
#
if [ -z "${PIPELINE_ALBUM}" ]
    then
        export PIPELINE_ALBUM=${A6I_DEVOPS_ROOT}/pipelines
fi

# Check pipeline album contains a pipeline with the given ID
  [ ! -d "${PIPELINE_ALBUM}/${PIPELINE_FOLDER}" ] && echo \
  && echo "${ERR_PROMPT} '${PIPELINE_ALBUM}/${PIPELINE_FOLDER}' does not exist" \
  && echo \
  && exit 1

# Check pipeline folder in the album contains a definition script
  [ ! -f "${PIPELINE_ALBUM}/${PIPELINE_FOLDER}/pipeline_definition.sh" ] && echo \
  && echo "${ERR_PROMPT} '${PIPELINE_ALBUM}/${PIPELINE_FOLDER}' is improperly configured:" \
  && echo "${ERR_PROMPT} It should contain a 'pipeline_definition'.sh file " \
  && echo "with two functions called 'pipeline_description' and 'pipeline_short_description'" \
  && echo \
  && exit 1

# Get the pipeline definition (i.e., set environment variables and initialize functions as per the definition for
# the pipeline with id $1
source "${PIPELINE_ALBUM}/${PIPELINE_FOLDER}/pipeline_definition.sh"

# Check that Docker is running
docker stats --no-stream 2>/tmp/error 1>/dev/null
if [[ $? != 0 ]]; then
    error=$(</tmp/error)
    docker_down=$(echo $error | grep "Cannot connect to the Docker daemon" | wc -l)
    if [[ $docker_down == 1 ]]; then
        echo "${ERR_PROMPT} Docker daemon not running, so must abort. In WSL you may start it from Bash by doing:"
        echo
        echo "   sudo service docker start"
        echo
        echo "...aborting script '$0'"
    else
        echo "${ERR_PROMPT} Docker seems to be running but is giving errors:"
        echo $error
    fi
    exit 1
else
    echo "${INFO_PROMPT} Verified that Docker daemon is running"
fi