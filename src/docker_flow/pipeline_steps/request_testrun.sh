#!/usr/bin/env bash

# This script conducts acceptance tests for Apodeixi by deploying the Apodeixi container, mounting on it
# an acceptance test database, running the tests, and producing test logs in a host folder that is mounted
# on the Apodeixi container.
#
# NB: Because of the way how Apodeixi integration tests are designed, each of them will run on a dedicated
#       Apodeixi environment with a dedicated test-specific `apodeixi_config.toml`. However, for the test harness
#       to start an initial `apodeixi_config.toml` is needed, which is expected to be already provisioned
#       in the test database, and is injected into the Apodeixi container via a mount.
#
# To run this script, change directory to the location of this script and do something like this from a command tool
#
#               bash request_testrun.sh
#
# As a precondition, the Docker daemon must be running. To start it in WSL2 Ubuntu, do someting like:
#
#               sudo service docker start
#

# Apodeixi environment settings

source ./common.sh

export TEST_DB="test_db"
export ROOT_FOLDER="/mnt/c/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi"
export ROOT_FOLDER_IN_WINDOWS="C:/Users/aleja/Documents/Code/chateauclaudia-labs/apodeixi"
export SED_DELIM="#" # Must be a character *not present* in the ROOT_FOLDER, so that SED can use later in this script

export SECRETS_FOLDER=${ROOT_FOLDER}/${TEST_DB}/secrets
export COLLABORATION_AREA=${ROOT_FOLDER}/${TEST_DB}/share-point
export KNOWLEDGE_BASE_FOLDER=${ROOT_FOLDER}/${TEST_DB}/knowledge-base

# We expect the test database to alreay have an `apodeixi_config.toml` file geared to development-time testing.
# That means that the paths referenced in that `apodeixi_config.toml` file are expected to include hard-coded
# directories under the ${ROOT_FOLDER}.
#
# These hard-coded directories in the host won't work when the tests are run inside the Apodeixi container, so we 
# will have to replace them by paths in the container file system. However, we don't want to modify the
# test database's `apodeixi_config.toml` file since its host hard-coded paths are needed at development time.
# Therefore, we:
#   1. Make a temporary copy of the test database's `apodeixi_config.toml` to a tmp subdirectory
#   2. Modify the paths in the copy, rendering the copy a "container-friendly" version of `apodeixi_config.toml`
#   3. Mount to the container the tmp directory containing the containfer-friedly copy of `apodeixi_config.toml`.
#      This mount needs to be done to the folder inside the container where the integration test code will expect
#      for it to exist. This folder is defined in apodeixi.testing_framework.a6i_skeleton_test.py, to be
#      equal to '../../../../test_db', with the path relative to that of `a6i_skeleton_test.py` in the container,
#      which is 
#           /usr/local/lib/python3.9/dist-packages/apodeixi/testing_framework/a6i_skeleton_test.py
#
#      because of the way how pip installed Apodeixi inside the container. Therefore, doing a '../../../../test_db'
#      means that we expect the container-friendly Apodeixi config file to be in 
#
#       /usr/local/lib/test_db/apodeixi_config.toml
#
#      That is the container folder onto which we must mount the temporary folder containing the modified
#      (i.e., container-friendly) version of `apodeixi_config.toml`
#
export TMP_CONFIG_DIRECTORY=${ROOT_FOLDER}/${TEST_DB}/tmp

cp ${ROOT_FOLDER}/${TEST_DB}/apodeixi_config.toml ${TMP_CONFIG_DIRECTORY}

# GOTCHA: use double quotes as parameter to sed, not single quotes, so that the environment variables get interpolated
#       as explained in https://stackoverflow.com/questions/6697753/difference-between-single-and-double-quotes-in-bash
sed -i "s${SED_DELIM}${ROOT_FOLDER_IN_WINDOWS}${SED_DELIM}/home/apodeixi${SED_DELIM}g" ${TMP_CONFIG_DIRECTORY}/apodeixi_config.toml

echo "About to start Apodeixi test container..."

# Comment this environment variable if we want to keep the build container (e.g., to inspect problems) after using build is over
export REMOVE_CONTAINER_WHEN_DONE="--rm"

docker run ${REMOVE_CONTAINER_WHEN_DONE} \
            -e INJECTED_CONFIG_DIRECTORY=/usr/local/lib/test_db \
            -v ${ROOT_FOLDER}/${TEST_DB}:/home/apodeixi/test_db  \
            -v ${TMP_CONFIG_DIRECTORY}:/usr/local/lib/test_db \
            apodeixi & # run in the background so rest of this script can proceed

echo "...waiting for Apodeixi test container to start..."
sleep 3
export APODEIXI_CONTAINER=$(docker ps -q -l)
echo "Apodeixi test container ${APODEIXI_CONTAINER} up and running..."
echo

# To run tests, create a script to run in the container that will:
#   1. cd to /usr/local/lib/python3.9/dist-packages/apodeixi
#   2. python -m unittest

