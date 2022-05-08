# This file defines some variables & functions that are common across multiple pipelines.
#
# Normally, they define an "epoch", i.e., a period of time during which pipelines are using a stable set of infrastructure 
# dependencies (e.g, Python version, Ubuntu version, application GIT URL, ....)
#
# Any specific pipeline can overwrite any of these values by simply re-defining the variable in question, since the pattern
# is to "source" this file as the first thing that is done in a pipeline definition script.
#
export UBUNTU_IMAGE="ubuntu:20.04"
export UBUNTU_PYTHON_PACKAGE="python3.9"
export A6I_BUILD_SERVER="a6i-build-server"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export A6I_BUILD_SERVER="a6i-build-server"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export A6I_CONDABUILD_SERVER="a6i-condabuild-server"
export ANACONDA_VERSION="2021.11-Linux-x86_64"

# To validate we download a legitimate Anaconda version, we will try to match it against the public
# Anaconda hashes for the version we are using, as documented in  https://docs.anaconda.com/anaconda/install/hashes/lin-3-64/
# 
export ANACONDA_SHA="fedf9e340039557f7b5e8a8a86affa9d299f5e9820144bd7b92ae9f7ee08ac60"

# For the Windows tests, we don't have a Windows container capability, so instead we will run a bash script in
# the Windows host. Here are some variables for assets in that Windows host
#
WIN_ANACONDA_DIR="/c/Users/aleja/Documents/CodeImages/Technos/Anaconda3"

# This is the command that WSL will execute - it must be a Linux path, but it is for a Windows executable
WIN_BASH_EXE="/mnt/c/Users/aleja/Documents/CodeImages/Technos/Git/bin/bash.exe"

export _CFG__DEPLOYABLE="apodeixi"

export APODEIXI_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

export APODEIXI_TESTDB_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi-testdb.git"

# If we call <A6I_ROOT> the folder where Apodeixi repos exist, then we know that:
#
#   * The environment is usually <A6I_ROOT>/${ENVIRONMENT}. Example: <A6I_ROOT>/UAT_ENV
#   * ${_CFG__PIPELINE_ALBUM} points to <A6I_ROOT>/apodeixi-devops/pipeline_album
#   
# This motivates how the following is set up
A6I_ROOT=${_CFG__PIPELINE_ALBUM}/../../

export APODEIXI_CONFIG_DIRECTORY=${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}

export TEST_APODEIXI_CONFIG_DIRECTORY=${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}/apodeixi_testdb_config

_CFG__set_build_docker_options() {

    echo "${_SVC__INFO_PROMPT} ... Determining approach for how container can access the GIT repo:"
    if [ ! -z ${MOUNT_APODEIXI_GIT_PROJECT} ]
        then
            echo "${_SVC__INFO_PROMPT}        => by mounting this drive:"
            echo "${_SVC__INFO_PROMPT}        => ${APODEIXI_GIT_URL}"
            if [ ! -d ${APODEIXI_GIT_URL} ]
                then
                    echo "${_SVC__ERR_PROMPT} Directory doesn't exist, so can't mount it:"
                    echo "      ${APODEIXI_GIT_URL}"
                    echo
                    echo "${_SVC__ERR_PROMPT} Aborting build..."
                    exit 1
            fi
            export APODEIXI_URL_CLONED_BY_CONTAINER="/home/${_CFG__DEPLOYABLE}"
            export GIT_REPO_MOUNT_DOCKER_OPTION=" -v ${APODEIXI_GIT_URL}:${APODEIXI_URL_CLONED_BY_CONTAINER}"
        else
            echo "${_SVC__INFO_PROMPT}        => from this URL:"
            echo "${_SVC__INFO_PROMPT}        => ${APODEIXI_GIT_URL}"
            export APODEIXI_URL_CLONED_BY_CONTAINER="${APODEIXI_GIT_URL}"
    fi    

    echo " -e APODEIXI_GIT_URL=${APODEIXI_URL_CLONED_BY_CONTAINER} " \
            $GIT_REPO_MOUNT_DOCKER_OPTION > /tmp/_CFG__BUILD_DOCKER_OPTIONS.txt
    export _CFG__BUILD_DOCKER_OPTIONS=`cat /tmp/_CFG__BUILD_DOCKER_OPTIONS.txt`
}

_CFG__set_testrun_docker_options() {

    echo "${_SVC__INFO_PROMPT} ... Determining approach for how container can access the GIT testdb repo:"
    if [ ! -z ${MOUNT_APODEIXI_GIT_PROJECT} ]
        then
            echo "${_SVC__INFO_PROMPT}        = by mounting this drive:"
            echo "${_SVC__INFO_PROMPT}        => ${APODEIXI_TESTDB_GIT_URL}"
            if [ ! -d ${APODEIXI_TESTDB_GIT_URL} ]
                then
                    echo "${_SVC__ERR_PROMPT} Directory doesn't exist, so can't mount it:"
                    echo "      ${APODEIXI_TESTDB_GIT_URL}"
                    echo
                    echo echo "${_SVC__ERR_PROMPT} Aborting testrun..."
                    exit 1
            fi
            export APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER="/home/apodeixi-testdb"
            export GIT_REPO_MOUNT_DOCKER_OPTION=" -v ${APODEIXI_TESTDB_GIT_URL}:${APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER}"
        else
            echo "${_SVC__INFO_PROMPT}        => from this URL:"
            echo "${_SVC__INFO_PROMPT}        => ${APODEIXI_TESTDB_GIT_URL}"
            export APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER="${APODEIXI_TESTDB_GIT_URL}"
    fi    

    echo    " -e APODEIXI_TESTDB_GIT_URL=${APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER} " \
            " -e INJECTED_CONFIG_DIRECTORY=/home/apodeixi_testdb_config" \
            " -e APODEIXI_CONFIG_DIRECTORY=/home/apodeixi_testdb_config" \
            " -v $TEST_APODEIXI_CONFIG_DIRECTORY:/home/apodeixi_testdb_config" \
            "${GIT_REPO_MOUNT_DOCKER_OPTION} "> /tmp/_CFG__TESTRUN_DOCKER_OPTIONS.txt
    export _CFG__TESTRUN_DOCKER_OPTIONS=`cat /tmp/_CFG__TESTRUN_DOCKER_OPTIONS.txt`
}

# This function will be invoked by CCL-DevOps. It is used to create _CFG__DEPLOYMENT_DOCKER_OPTIONS.
#
# This impelementation is Apodeixi-specific and requires that the following have been previously
# set in the pipeline definition:
#
#   -${APODEIXI_CONFIG_DIRECTORY}
#   -${SECRETS_FOLDER}
#   -${COLLABORATION_AREA}
#   -${KNOWLEDGE_BASE_FOLDER}
#
_CFG__set_deployment_docker_options() {

    # Check that Apodeixi config file exists
    [ ! -f ${APODEIXI_CONFIG_DIRECTORY}/apodeixi_config.toml ] && echo \
        && echo "${_SVC__ERR_PROMPT} '${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}' is improperly configured:" \
        && echo "${_SVC__ERR_PROMPT} It expects Apodeixi config file, which doesn't exist:" \
        && echo "${_SVC__ERR_PROMPT}     ${APODEIXI_CONFIG_DIRECTORY}/apodeixi_config.toml" \
        && echo \
        && exit 1

    # Check that mounted volumes for the Apodeixi environment exist
    [ ! -d ${SECRETS_FOLDER} ] && echo \
            && echo "${_SVC__ERR_PROMPT} '${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}' is improperly configured:" \
            && echo "${_SVC__ERR_PROMPT} It expects a non-existent folder called "\
            && echo "    ${SECRETS_FOLDER}." \
            && echo \
            && exit 1
    [ ! -d ${COLLABORATION_AREA} ] && echo \
            && echo "${_SVC__ERR_PROMPT} '${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}' is improperly configured:" \
            && echo "${_SVC__ERR_PROMPT} It expects a non-existent a folder called " \
            && echo "    ${COLLABORATION_AREA}." \
            && echo \
            && exit 1
    [ ! -d ${KNOWLEDGE_BASE_FOLDER} ] && echo \
        && echo "${_SVC__ERR_PROMPT} '${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}' is improperly configured:" \
        && echo "${_SVC__ERR_PROMPT} It expects a non-existent a folder called " \
        && echo "    ${KNOWLEDGE_BASE_FOLDER}." \
            && echo \
    && exit 1

    echo    " -e APODEIXI_CONFIG_DIRECTORY=/home/apodeixi/config" \
            " -v ${SECRETS_FOLDER}:/home/apodeixi/secrets " \
            " -v ${COLLABORATION_AREA}:/home/apodeixi/collaboration_area "\
            " -v ${KNOWLEDGE_BASE_FOLDER}:/home/apodeixi/kb " \
            " -v ${APODEIXI_CONFIG_DIRECTORY}:/home/apodeixi/config" > /tmp/_CFG__DEPLOYMENT_DOCKER_OPTIONS.txt

    export _CFG__DEPLOYMENT_DOCKER_OPTIONS=`cat /tmp/_CFG__DEPLOYMENT_DOCKER_OPTIONS.txt`

}

_CFG__set_linux_test_conda_options() {

    echo    " -e APODEIXI_TESTDB_GIT_URL=${APODEIXI_TESTDB_GIT_URL} " \
            " -e INJECTED_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config " \
            " -e APODEIXI_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config " \
            " -v $TEST_APODEIXI_CONFIG_DIRECTORY:/home/${_CFG__DEPLOYABLE}_testdb_config " \
            > /tmp/_CFG__LINUX_TEST_CONDA_OPTIONS.txt
    export _CFG__LINUX_TEST_CONDA_OPTIONS=`cat /tmp/_CFG__LINUX_TEST_CONDA_OPTIONS.txt`
}

