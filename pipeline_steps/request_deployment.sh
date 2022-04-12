#!/bin/sh

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

# Apodeixi environment settings

source ./common.sh

export ENVIRONMENT="UAT_ENV"
export ROOT_FOLDER="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi"

export SECRETS_FOLDER=${ROOT_FOLDER}/${ENVIRONMENT}/secrets
export COLLABORATION_AREA=${ROOT_FOLDER}/${ENVIRONMENT}/collaboration_area
export KNOWLEDGE_BASE_FOLDER=${ROOT_FOLDER}/${ENVIRONMENT}/kb

export CONFIG_DIRECTORY=${ROOT_FOLDER}/${ENVIRONMENT}/injected_config

cp apodeixi_config_${ENVIRONMENT}.toml ${CONFIG_DIRECTORY}/apodeixi_config.toml

echo "About to start Apodeixi container..."
docker run ${REMOVE_CONTAINER_WHEN_DONE} \
            -e APODEIXI_CONFIG_DIRECTORY="/home/apodeixi/config" \
            -v ${SECRETS_FOLDER}:/home/apodeixi/secrets -v ${COLLABORATION_AREA}:/home/apodeixi/collaboration_area  \
            -v ${KNOWLEDGE_BASE_FOLDER}:/home/apodeixi/kb -v ${CONFIG_DIRECTORY}:/home/apodeixi/config \
            apodeixi & # run in the background so rest of this script can proceed

echo "...waiting for Apodeixi to start..."
sleep 3
export APODEIXI_CONTAINER=$(docker ps -q -l)
echo "Apodeixi container ${APODEIXI_CONTAINER} up and running..."

