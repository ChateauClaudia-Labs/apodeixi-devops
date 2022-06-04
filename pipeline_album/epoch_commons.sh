# This file defines some variables & functions that are common across multiple pipelines.
#
# Normally, they define an "epoch", i.e., a period of time during which pipelines are using a stable set of infrastructure 
# dependencies (e.g, Python version, Ubuntu version, application GIT URL, ....)
#
# Any specific pipeline can overwrite any of these values by simply re-defining the variable in question, since the pattern
# is to "source" this file as the first thing that is done in a pipeline definition script.
#
export _CFG__UBUNTU_IMAGE="ubuntu:20.04"
export _CFG__PYTHON_VERSION="3.9"
export _CFG__UBUNTU_PYTHON_PACKAGE="python${_CFG__PYTHON_VERSION}"
export _CFG__BUILD_SERVER="a6i-build-server"
export _CFG__CONDA_VERSION="4.12" # NB: On May 29 2022 the Conda build failed and seems related to Conda version moving from 4.12 to 4.13

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

# We draw a distinction between the "application" vs the "deployable(s)":
#
#       1. An application may consist of multiple microservices, each of which is a "deployable"
#       2. GIT repos are at the level of volatility, which means usually multiple microservices are in the same GIT
#               repo. Usual pattern is: one repo for the client services (CLI, UI, ...), and one repo for the server-side
#               microservices
#       3. What we call a "deployable" here corresponds to 1 microservice, which entails 1 Python package (with its own
#               microservice-specific setup.cfg and src folder)
#       4. So an "application" has 1+ repos, and each repo has 1+ "deployables"
#       5. Test database repos are at the level of the "application" to allow for testing multiple microservices together, while segregating
#               microservice-specific tests in subfolders.
#       6. Pipelines are the level of a "deployable". 
#       7. Configuration is at the level of a "deployable"
#       8. Therefore, a pipeline for a microservice X will need GIT repos for more then just X, since the GIT repo may bring
#               along code and tests for other microservices as well, even if the pipeline will the concern itself with only
#               building X and only testing X (by going to appropriate sub-folders in the repo for X and for X's tests)
#
export _CFG__DEPLOYABLE="apodeixi"

# Apodeixi is monolithic, so the application and deployable coincide in this case
export _CFG__APPLICATION="${_CFG__DEPLOYABLE}" 
export _CFG__APPLICATION_BASE_IMAGE="${_CFG__APPLICATION}-base"

# This is the path from (and including) the root folder for the repo all to way to the deployable. In the case
# of Apodeixi it is "trivial" since there is only 1 deployable in the repo
export _CFG__DEPLOYABLE_RELATIVE_PATH="${_CFG__DEPLOYABLE}"

export _CFG__DEPLOYABLE_GIT_URL="https://github.com/ChateauClaudia-Labs/${_CFG__APPLICATION}.git"

export _CFG__TESTDB_GIT_URL="https://github.com/ChateauClaudia-Labs/${_CFG__APPLICATION}-testdb.git"

export _CFG__TESTDB_REPO_NAME="${_CFG__APPLICATION}-testdb"

# This is a Linux command that will be executed inside the deployable's container when that container is deployed,
# to validate that the deployment is correct. The deployment will be aborted by CCL Chassis if this command fails.
#
export _CFG__DEPLOYMENT_VALIDATION_COMMAND="apo --version && apo get assertions"

# We need to set the variable $A6I_ROOT which is used by the Apodeixi pipeline definitions as the root folder
# above test environments like UAT.
# We set it based on these considerations: ff we call <A6I_ROOT> the folder where Apodeixi repos exist, then we know that:
#
#   * The environment is usually <A6I_ROOT>/${ENVIRONMENT}. Example: <A6I_ROOT>/UAT_ENV
#   * ${_CFG__PIPELINE_ALBUM} points to <A6I_ROOT>/${_CFG__DEPLOYABLE}-devops/pipeline_album
#   
# This motivates how the following is set up
A6I_ROOT=${_CFG__PIPELINE_ALBUM}/../../


export DEPLOYABLE_CONFIG_DIRECTORY=${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}

export TEST_DEPLOYABLE_CONFIG_DIRECTORY=${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}/${_CFG__DEPLOYABLE}_testdb_config

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
            export APODEIXI_URL_CLONED_BY_CONTAINER="/home/${_CFG__APPLICATION}"
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
# We expect the test database to already have an `${_CFG__DEPLOYABLE}_config.toml` file geared to development-time testing.
# That means that the paths referenced in that `${_CFG__DEPLOYABLE}_config.toml` file are expected to include hard-coded
# directories for the developer's machine.
#
# These hard-coded directories in the host won't work when the tests are run inside the Apodeixi container, so we 
# will have to replace them by paths in the container file system. However, we don't want to modify the
# test database's `${_CFG__DEPLOYABLE}_config.toml` file since its host hard-coded paths are needed at development time.
# Therefore, the logic of CCL-DevOps if for container to apply this logic when running CCL_Devops' testrun.sh:
#
#   1. Clone the GIT repo that contains the test database into /home/work, creating /home/work/${_CFG__DEPLOYABLE}-testdb inside
#      the container
#   2. Rely on the environment variable $INJECTED_CONFIG_DIRECTORY to locate the folder where the Apodeixi configuration
#      file resides. 
#      This environment variable is needed to address the following problem with Apodeixi's test harness, and specifcially by
#      ${_CFG__DEPLOYABLE}.testing_framework.a6i_skeleton_test.py:
#
#           The test harness by default assumes that the Apodeixi configuration is found in 
#
#                    '../../../../test_db'
#
#           with the path relative to that of `a6i_skeleton_test.py` in the container, which is 
#
#                   /usr/local/lib/python3.9/dist-packages/${_CFG__DEPLOYABLE}/testing_framework/a6i_skeleton_test.py
#
#      because of the way how pip installed Apodeixi inside the container. 
#
#      This is addresed by:
#           - setting the environment variable $INJECTED_CONFIG_DIRECTORY to /home/${_CFG__DEPLOYABLE}_testdb_config
#           - this will cause the test harness to look for Apodeixi's configuration in the folder $INJECTED_CONFIG_DIRECTORY
#           - additionally, read the value of another environment variable, $TEST_DEPLOYABLE_CONFIG_DIRECTORY, from the
#             pipeline definition (in pipeline_album/<pipeline_id>/pipeline_definition.sh)
#           - this way the pipeline's choice for what ${_CFG__DEPLOYABLE}_config.toml to use for testing will come from looking
#             in $TEST_DEPLOYABLE_CONFIG_DIRECTORY in the host
#           - lastly, we mount $TEST_DEPLOYABLE_CONFIG_DIRECTORY as /home/${_CFG__DEPLOYABLE}_testdb_config in the container, which is
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
            export APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER="/home/${_CFG__APPLICATION}-testdb"
            export GIT_REPO_MOUNT_DOCKER_OPTION=" -v ${_CFG__TESTDB_GIT_URL}:${APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER}"
        else
            echo "${_SVC__INFO_PROMPT}        => from this URL:"
            echo "${_SVC__INFO_PROMPT}        => ${_CFG__TESTDB_GIT_URL}"
            export APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER="${_CFG__TESTDB_GIT_URL}"
    fi    

    echo    " -e _CFG__TESTDB_GIT_URL=${APODEIXI_TESTDB_URL_CLONED_BY_CONTAINER} " \
            " -e INJECTED_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config" \
            " -e APODEIXI_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config" \
            " -v $TEST_DEPLOYABLE_CONFIG_DIRECTORY:/home/${_CFG__DEPLOYABLE}_testdb_config" \
            "${GIT_REPO_MOUNT_DOCKER_OPTION} "> /tmp/_CFG__TESTRUN_DOCKER_OPTIONS.txt
    export _CFG__TESTRUN_DOCKER_OPTIONS=`cat /tmp/_CFG__TESTRUN_DOCKER_OPTIONS.txt`
}



# This function will be invoked by CCL-DevOps. It is used to create _CFG__DEPLOYMENT_DOCKER_OPTIONS.
#
# This implementation is Apodeixi-specific and requires that the following have been previously
# set in the pipeline definition:
#
#   -${DEPLOYABLE_CONFIG_DIRECTORY}
#   -${SECRETS_FOLDER}
#   -${COLLABORATION_AREA}
#   -${KNOWLEDGE_BASE_FOLDER}
#
_CFG__set_deployment_docker_options() {

    # Check that Apodeixi config file exists
    [ ! -f ${DEPLOYABLE_CONFIG_DIRECTORY}/${_CFG__DEPLOYABLE}_config.toml ] && echo \
        && echo "${_SVC__ERR_PROMPT} '${_CFG__PIPELINE_ALBUM}/${PIPELINE_NAME}' is improperly configured:" \
        && echo "${_SVC__ERR_PROMPT} It expects Apodeixi config file, which doesn't exist:" \
        && echo "${_SVC__ERR_PROMPT}     ${DEPLOYABLE_CONFIG_DIRECTORY}/${_CFG__DEPLOYABLE}_config.toml" \
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

    echo    " -e APODEIXI_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}/config" \
            " -v ${SECRETS_FOLDER}:/home/${_CFG__DEPLOYABLE}/secrets " \
            " -v ${COLLABORATION_AREA}:/home/${_CFG__APPLICATION}/collaboration_area "\
            " -v ${KNOWLEDGE_BASE_FOLDER}:/home/${_CFG__APPLICATION}/kb " \
            " -v ${DEPLOYABLE_CONFIG_DIRECTORY}:/home/${_CFG__DEPLOYABLE}/config" > /tmp/_CFG__DEPLOYMENT_DOCKER_OPTIONS.txt

    export _CFG__DEPLOYMENT_DOCKER_OPTIONS=`cat /tmp/_CFG__DEPLOYMENT_DOCKER_OPTIONS.txt`

}

# See comments for function _CFG__set_testrun_docker_options, since the same rationale applies here.
#
_CFG__set_linux_test_conda_options() {

    echo    " -e _CFG__TESTDB_GIT_URL=${_CFG__TESTDB_GIT_URL} " \
            " -e INJECTED_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config " \
            " -e APODEIXI_CONFIG_DIRECTORY=/home/${_CFG__DEPLOYABLE}_testdb_config " \
            " -v $TEST_DEPLOYABLE_CONFIG_DIRECTORY:/home/${_CFG__DEPLOYABLE}_testdb_config " \
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

    # This function is being called in WSL, and we must make sure that some things are set up for when script $1
    # later runs in Windows and runs Apodeixi tests. This is what we must ensure:
    #   1. the variable $INJECTED_CONFIG_DIRECTORY is set in the script $1
    #   2. Ensure $INJECTED_CONFIG_DIRECTORY points to a valid directory
    #   3. that directory contains a file called ${_CFG__DEPLOYABLE}_config.toml which is "based" on the file
    #      $TEST_DEPLOYABLE_CONFIG_DIRECTORY/${_CFG__DEPLOYABLE}_config.toml but differs from it a per the next point
    #   4. Paths like "home/work" in $TEST_DEPLOYABLE_CONFIG_DIRECTORY/${_CFG__DEPLOYABLE}_config.toml are replaced by
    #      paths like "$WIN_TESTDB_REPO_DIR/${WIN_TESTDB_REPO_NAME".
    #
    # APPROACH: we create a temporary file in WSL,
    #
    #                        /tmp/_CFG__apply_windows_test_conda_options.txt
    #
    # This file will have all the Windows commands & Windows paths (i.e, like script $1, so not WSL!)
    # Once we have built this file, we inject its content in script $1 using sed
    

    # Step 1: Ensure $INJECTED_CONFIG_DIRECTORY is set and points to a valid directory
    #
    echo "export INJECTED_CONFIG_DIRECTORY=$(echo ${WIN_WORKING_DIR}/${_CFG__DEPLOYABLE}_testdb_config)" \
            > /tmp/_CFG__apply_windows_test_conda_options.txt

    # Step 2: Ensure $INJECTED_CONFIG_DIRECTORY points to a valid directory
    #       GOTCHA: 
    #               $INJECTED_CONFIG_DIRECTORY is a string with Window paths ("C:/...") since it is meant to
    #           retrieved by Apodeixi running on Windows.
    #           But if we are going to create such directory if it doesn't already, we must go back to the
    #           WSL paths ("/mtn/c/...") since this function is running in WSL.
    #           For this we leverage the identity
    #           
    #                   IN_WORKING_DIR=$(to_windows_path ${WORKING_DIR})
    #
    export WSL_INJECTED_CONFIG_DIRECTORY="${WORKING_DIR}/${_CFG__DEPLOYABLE}_testdb_config"
    if [ ! -d $WSL_INJECTED_CONFIG_DIRECTORY ]
        then
            mkdir $WSL_INJECTED_CONFIG_DIRECTORY
    fi

    # Step 3: put instructions in script $1 to copy the file $TEST_DEPLOYABLE_CONFIG_DIRECTORY/${_CFG__DEPLOYABLE}_config.toml 
    #       to "$WIN_TESTDB_REPO_DIR/${WIN_TESTDB_REPO_NAME"
    #
    #       GOTCHA: 
    #           $TEST_DEPLOYABLE_CONFIG_DIRECTORY/${_CFG__DEPLOYABLE}_config.toml is a WSL path, so we have to:
    #           a. Put an instruction to set Windows environment variable  $WIN_INJECTED_CONFIG_DIRECTORY in
    #               script $1 for the equivalent Windows path
    #           b. Use single quotes in the copy instruction so that the variable $WIN_INJECTED_CONFIG_DIRECTORY is not
    #               interpolated in WSL
    #           c. Should the copy instruction fail when it is executed later on in Windows, inject into script $1
    #               a call to the Windows script's function `abort_testrun_on_error`
    #
    echo "export WIN_INJECTED_CONFIG_DIRECTORY=$(to_windows_path ${TEST_DEPLOYABLE_CONFIG_DIRECTORY})" \
            >> /tmp/_CFG__apply_windows_test_conda_options.txt

    echo 'cp ${WIN_INJECTED_CONFIG_DIRECTORY}/${_CFG__DEPLOYABLE}_config.toml ${INJECTED_CONFIG_DIRECTORY}/' \
            >> /tmp/_CFG__apply_windows_test_conda_options.txt

    echo 'abort_testrun_on_error' \
            >> /tmp/_CFG__apply_windows_test_conda_options.txt

    # Step 4
    #           We know that this identity will hold true in the Windows script $1 by the time that the script $1
    #   clones the test database repo:
    #
    #           TESTDB_REPO_PARENT_DIR="$(cd ~/tmp && pwd)/test_${WIN_TIMESTAMP}"
    #   
    #   Thus, we need ${_CFG__DEPLOYABLE}_config.toml to reference paths which in Windows are equal to $TESTDB_REPO_PARENT_DIR
    #   Since the file we copied references path in '/home/work', we need to:
    #
    #   a. Put an instruction in script $1 to set the value of variable TESTDB_REPO_PARENT_DIR
    #   b. Put a sed instruction to replace '/home/work' by $TESTDB_REPO_PARENT_DIR. Being an instruction for execution
    #       later on in Windows (not now, not in WSL), we must use single quotes to prevent Bash interpolation.
    #       Since "/" is part of the text being replaced, we choose a different sed delimeter (we use "#" instead of the 
    #       default delimeter "/")
    #   c. Lastly, an additional sed instruction will be needed because in the script $1 the variable TESTDB_REPO_PARENT_DIR
    #      is something like 
    # 
    #
    #               /c/Users/aleja/tmp/test_220501.144650
    #
    #       but we need ${INJECTED_CONFIG_DIRECTORY}/${_CFG__DEPLOYABLE}_config.toml to have paths like 
    #
    #               C:/Users/aleja/tmp/test_220501.144650
    #
    #       to prevent problems when loading the yaml file "/c/Users/aleja/tmp/test_220501.144650/${_CFG__DEPLOYABLE}-testdb/test_config.yaml"
    #       
    #       So put an instruction for another we do another sed call, replacing "/c/" by "C:/"
    #
    echo 'export TESTDB_REPO_PARENT_DIR=$(cd ~/tmp && pwd)/test_${WIN_TIMESTAMP}' \
             >> /tmp/_CFG__apply_windows_test_conda_options.txt   
    echo 'sed -i "s#/home/work/#${TESTDB_REPO_PARENT_DIR}/#g" ${INJECTED_CONFIG_DIRECTORY}/${_CFG__DEPLOYABLE}_config.toml' \
             >> /tmp/_CFG__apply_windows_test_conda_options.txt   
    echo 'abort_testrun_on_error' \
             >> /tmp/_CFG__apply_windows_test_conda_options.txt   
    echo 'sed -i "s#/c/#C:/#g" ${INJECTED_CONFIG_DIRECTORY}/${_CFG__DEPLOYABLE}_config.toml' \
             >> /tmp/_CFG__apply_windows_test_conda_options.txt   
    echo 'abort_testrun_on_error' \
             >> /tmp/_CFG__apply_windows_test_conda_options.txt

    echo 'echo "[A6I_WIN_TEST_VIRTUAL_ENV] =========== Additional logic from Apodeixi: set up ${_CFG__DEPLOYABLE} config"   &>> ${TEST_LOG}' \
            >> /tmp/_CFG__apply_windows_test_conda_options.txt
    echo 'echo &>> ${TEST_LOG}' \
            >> /tmp/_CFG__apply_windows_test_conda_options.txt

    # Now insert the contents of /tmp/_CFG__apply_windows_test_conda_options.txt into script $1
    # GOTCHA:
    #       Use double quotes in "$x" so that line breaks are preserved. Else all lines get aggregated to a single line
    # (would be a huge mess)
    x=`cat /tmp/_CFG__apply_windows_test_conda_options.txt; cat $1`
    echo "$x" > $1

    abort_on_error
}

