#!/usr/bin/env bash

# Release version that is to be built
export APODEIXI_VERSION="0.9.7"

export APODEIXI_GIT_URL="https://github.com/ChateauClaudia-Labs/apodeixi.git"

# Define which server image to use for the build. Determines version of Ubuntu and Python for the container where the build runs
export A6I_BUILD_SERVER="a6i-build-server"