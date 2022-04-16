#!/bin/sh

# Release version that is to be built
export APODEIXI_VERSION="0.9.7"

# Unique timestamp used e.g., as a prefix in the names of log files
# For example, "220331.120319" is a run done at 12:03 pm (and 19 seconds) on March 31, 2022
export TIMESTAMP="$(date +"%y%m%d.%H%M%S")"

export ERR_PROMPT="[A6I CI/CD ERROR]"
export INFO_PROMPT="[A6I CI/CD INFO]"

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