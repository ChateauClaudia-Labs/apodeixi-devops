# This file defines some variables & functions that are common across multiple pipelines.
#
# Normally, they define an "epoch", i.e., a period of time during which pipelines are using a stable set of infrastructure 
# dependencies (e.g, Python version, Ubuntu version, application GIT URL, ....)
#
# Any specific pipeline can overwrite any of these values by simply re-defining the variable in question, since the pattern
# is to "source" this file as the first thing that is done in a pipeline definition script.
#
export _CFG__UBUNTU_IMAGE="ubuntu:20.04"
export _CFG__UBUNTU_PYTHON_PACKAGE="python3.9"
export _CFG__BUILD_SERVER="a6i-build-server"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export _CFG__CONDABUILD_SERVER="a6i-condabuild-server"
export _CFG__ANACONDA_VERSION="2021.11-Linux-x86_64"

# To validate we download a legitimate Anaconda version, we will try to match it against the public
# Anaconda hashes for the version we are using, as documented in  https://docs.anaconda.com/anaconda/install/hashes/lin-3-64/
# 
export _CFG__ANACONDA_SHA="fedf9e340039557f7b5e8a8a86affa9d299f5e9820144bd7b92ae9f7ee08ac60"

# For the Windows tests, we don't have a Windows container capability, so instead we will run a bash script in
# the Windows host. Here are some variables for assets in that Windows host
#
export _CFG__WIN_ANACONDA_DIR="/c/Users/aleja/Documents/CodeImages/Technos/Anaconda3"

# This is the command that WSL will execute - it must be a Linux path, but it is for a Windows executable
export _CFG__WIN_BASH_EXE="/mnt/c/Users/aleja/Documents/CodeImages/Technos/Git/bin/bash.exe"

export _CFG__DEPLOYABLE="apodeixi"

export _CFG__DEPLOYABLE_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

export _CFG__TESTDB_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi-testdb.git"

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
            echo "${_SVC__INFO_PROMPT}        => ${_CFG__DEPLOYABLE_GIT_URL}"
            if [ ! -d ${_CFG__DEPLOYABLE_GIT_URL} ]
                then
                    echo "${_SVC__ERR_PROMPT} Directory doesn't exist, so can't mount it:"
                    echo "      ${_CFG__DEPLOYABLE_GIT_URL}"
                    echo
                    echo "${_SVC__ERR_PROMPT} Aborting build..."
                    exit 1
            fi
            export APODEIXI_URL_CLONED_BY_CONTAINER="/home/${_CFG__DEPLOYABLE}"
            export GIT_REPO_MOUNT_DOCKER_OPTION=" -v ${_CFG__DEPLOYABLE_GIT_URL}:${APODEIXI_URL_CLONED_BY_CONTAINER}"
        else
            echo "${_SVC__INFO_PROMPT}        => from this URL:"
            echo "${_SVC__INFO_PROMPT}        => ${_CFG__DEPLOYABLE_GIT_URL}"
            export APODEIXI_URL_CLONED_BY_CONTAINER="${_CFG__DEPLOYABLE_GIT_URL}"
    fi    

    echo " -e _CFG__DEPLOYABLE_GIT_URL=${APODEIXI_URL_CLONED_BY_CONTAINER} " \
            $GIT_REPO_MOUNT_DOCKER_OPTION > /tmp/_CFG__BUILD_DOCKER_OPTIONS.txt
    export _CFG__BUILD_DOCKER_OPTIONS=`cat /tmp/_CFG__BUILD_DOCKER_OPTIONS.txt`
}

# This comment applies to how we implement these functions:
#
#   * _CFG__set_testrun_docker_options
#   * _CFG__set_linux_test_conda_options
#
# We expect the test database to already have an `apodeixi_config.toml` file geared to development-time testing.
# That means that the paths referenced in that `apodeixi_config.toml` file are expected to include hard-coded
# directories for the developer's machine.
#
# These hard-coded directories in the host won't work when the tests are run inside the Apodeixi container, so we 
# will have to replace them by paths in the container file system. However, we don't want to modify the
# test database's `apodeixi_config.toml` file since its host hard-coded paths are needed at development time.
# Therefore, the logic of CCL-DevOps if for container to apply this logic when running CCL_Devops' testrun.sh:
#
#   1. Clone the GIT repo that contains the test database into /home/work, creating /home/work/apodeixi-testdb inside
#      the container
#   2. Rely on the environment variable $INJECTED_CONFIG_DIRECTORY to locate the folder where the Apodeixi configuration
#      file resides. 
#      This environment variable is needed to address the following problem with Apodeixi's test harness, and specifcially by
#      apodeixi.testing_framework.a6i_skeleton_test.py:
#
#           The test harness by default assumes that the Apodeixi configuration is found in 
#
#                    '../../../../test_db'
#
#           with the path relative to that of `a6i_skeleton_test.py` in the container, which is 
#
#                   /usr/local/lib/python3.9/dist-packages/apodeixi/testing_framework/a6i_skeleton_test.py
#
#      because of the way how pip installed Apodeixi inside the container. 
#
#      This is addresed by:
#           - setting the environment variable $INJECTED_CONFIG_DIRECTORY to /home/apodeixi_testdb_config
#           - this will cause the test harness to look for Apodeixi's configuration in the folder $INJECTED_CONFIG_DIRECTORY
#           - additionally, read the value of another environment variable, $TEST_APODEIXI_CONFIG_DIRECTORY, from the
#             pipeline definition (in pipeline_album/<pipeline_id>/pipeline_definition.sh)
#           - this way the pipeline's choice for what apodeixi_config.toml to use for testing will come from looking
#             in $TEST_APODEIXI_CONFIG_DIRECTORY in the host
#           - lastly, we mount $TEST_APODEIXI_CONFIG_DIRECTORY as /home/apodeixi_testdb_config in the container, which is
#             where the container-run test harness will expect it (since that's the value of $INJECTED_CONFIG_DIRECTORY)
#
_CFG__set_testrun_docker_options() {

    echo "${_SVC__INFO_PROMPT} ... Determining approach for how container can access the GIT testdb repo:"
    if [ ! -z ${MOUNT_APODEIXI_GIT_PROJECT} ]
        then
            echo "${_SVC__INFO_PROMPT}        = by mounting this drive:"
            echo "${_SVC__INFO_PROMPT}        => ${_CFG__TESTDB_GIT_URL}"
            if [ ! -d ${_CFG__TESTDB_GIT_URL} ]
                then
                    echo "${_SVC__ERR_PROMPT} Directory doesn't exist, so can't mount it:"
                    echo "      ${_CFG__TESTDB_GIT_URL}"
                    echo
                    echo echo "${_SVC__ERR_PROMPT} Aborting testrun..."
                    exit 1
            fi
            export APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER="/home/apodeixi-testdb"
            export GIT_REPO_MOUNT_DOCKER_OPTION=" -v ${_CFG__TESTDB_GIT_URL}:${APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER}"
        else
            echo "${_SVC__INFO_PROMPT}        => from this URL:"
            echo "${_SVC__INFO_PROMPT}        => ${_CFG__TESTDB_GIT_URL}"
            export APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER="${_CFG__TESTDB_GIT_URL}"
    fi    

    echo    " -e _CFG__TESTDB_GIT_URL=${APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER} " \
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

# See comments for function _CFG__set_testrun_docker_options, since the same rationale applies here.
#
_CFG__set_linux_test_conda_options() {

    echo    " -e _CFG__TESTDB_GIT_URL=${_CFG__TESTDB_GIT_URL} " \
            " -e INJECTED_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config " \
            " -e APODEIXI_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config " \
            " -v $TEST_APODEIXI_CONFIG_DIRECTORY:/home/${_CFG__DEPLOYABLE}_testdb_config " \
            > /tmp/_CFG__LINUX_TEST_CONDA_OPTIONS.txt
    export _CFG__LINUX_TEST_CONDA_OPTIONS=`cat /tmp/_CFG__LINUX_TEST_CONDA_OPTIONS.txt`
}

# For Windows we don't use Docker, so in lieu of the normal Docker options to pass environment
# variables, this is done by adding extra lines to a script that Windows will execution in a conda
# virtual environment.
# That script name is passed to this function as the first parameter
#
#   $1: Name of script that would run in a Windows conda virtual environment to run tests
_CFG__apply_windows_test_conda_options() {

    WIN_INJECTED_CONFIG_DIRECTORY=$(to_windows_path ${TEST_APODEIXI_CONFIG_DIRECTORY})
 
    echo
    echo "      export WIN_INJECTED_CONFIG_DIRECTORY=$(echo $WIN_INJECTED_CONFIG_DIRECTORY)"
    sed -i "1s#^#export WIN_INJECTED_CONFIG_DIRECTORY=$(echo $WIN_INJECTED_CONFIG_DIRECTORY)\n#" $1
    abort_on_error

}

