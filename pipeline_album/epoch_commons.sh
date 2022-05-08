# This file defines some variables that are common across multiple pipelines.
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
