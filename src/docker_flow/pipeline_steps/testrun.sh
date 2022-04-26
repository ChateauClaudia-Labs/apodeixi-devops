# To run tests, create a script to run in the container that will:
#   1. cd to /usr/local/lib/python3.9/dist-packages/apodeixi
#   2. python -m unittest

#!/bin/sh

# This script is meant to run inside the build server container.
#

# NB: /home/output is mounted on this container's host filesystem
#
LOGS_DIR="/home/output/logs" # This is a mount of a directory in host machine, so it might already exist
if [ ! -d "${LOGS_DIR}" ]; then
  mkdir ${LOGS_DIR}
fi

abort_testrun_on_error() {
if [[ $? != 0 ]]; then
    error=$(</tmp/error)
    echo >/dev/stderr
    echo "${ERR_PROMPT} ${error}" &>> ${TEST_LOG}
    # Signal error again, this time for caller to catch, but limiting error to caller to just the first 500 characters.
    # If caller wants to see all the error message, caller can go to the logs
    echo "Aborting testrun. Here is the error message (cut down to last 5 lines):"  >/dev/stderr
    echo >/dev/stderr
    #echo "${error:-500:}"  >/dev/stderr
    tail -n 5 /tmp/error >/dev/stderr
    echo >/dev/stderr 
    exit 1
fi    
}

WORKING_DIR="/home/work"
mkdir ${WORKING_DIR}

export TEST_LOG="${LOGS_DIR}/${TIMESTAMP}_testrun.txt"

# NB: Redirecting with &>> appends both standard output and standard error to the file

echo "[A6I_TEST_CONTAINER] ---------- Test logs ---------- $(date) ---------- " &>> ${TEST_LOG}
echo                                                        &>> ${TEST_LOG}

echo "[A6I_TEST_CONTAINER] Hostname=$(hostname)"            &>> ${TEST_LOG}
echo                                                        &>> ${TEST_LOG}
cd ${WORKING_DIR}                                           &>> ${TEST_LOG}
echo "[A6I_TEST_CONTAINER] Current directory is $(pwd)"     &>> ${TEST_LOG}
echo "[A6I_TEST_CONTAINER] Current user is is $(whoami)"    &>> ${TEST_LOG}
echo                                                        &>> ${TEST_LOG}

# The container already has Apodeixi, but we need git and python in order to install and then run the tests
#
echo "[A6I_TEST_CONTAINER] Installing git in order to run the tests..." &>> ${TEST_LOG}
# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this action took
SECONDS=0
echo "[A6I_TEST_CONTAINER] ======== Starting apt-get update..."     &>> ${TEST_LOG}
echo                                                        &>> ${TEST_LOG}
apt-get update                                              1>> ${TEST_LOG} 2>/tmp/error
abort_testrun_on_error
echo "[A6I_TEST_CONTAINER]          ... completed apt-get update"     &>> ${TEST_LOG}
echo                                                        &>> ${TEST_LOG}
echo "[A6I_TEST_CONTAINER] ======== Starting apt-get install -y git..."     &>> ${TEST_LOG}
echo                                                        &>> ${TEST_LOG}
apt-get install -y git                                      1>> ${TEST_LOG} 2>/tmp/error
abort_testrun_on_error
echo "[A6I_TEST_CONTAINER] ... completed apt-get install -y git"     &>> ${TEST_LOG}
echo
duration=$SECONDS                                                        &>> ${TEST_LOG}
echo "[A6I_TEST_CONTAINER] ...git successfully installed in container in $duration sec" &>> ${TEST_LOG}
echo                                                        &>> ${TEST_LOG}

echo "[A6I_TEST_CONTAINER] =========== git clone ${APODEIXI_TESTDB_GIT_URL} --branch ${APODEIXI_GIT_BRANCH}" &>> ${TEST_LOG}
# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this action took
SECONDS=0
echo &>> ${TEST_LOG}
git clone  ${APODEIXI_TESTDB_GIT_URL} --branch ${APODEIXI_GIT_BRANCH} 1>> ${TEST_LOG} 2>/tmp/error
abort_testrun_on_error

# Compute how long we took in this script
duration=$SECONDS
echo "[A6I_TEST_CONTAINER]         Completed 'git clone' in $duration sec" &>> ${TEST_LOG}


echo &>> ${TEST_LOG}

echo "[A6I_TEST_CONTAINER] =========== Working area and Python version" &>> ${TEST_LOG}
echo &>> ${TEST_LOG}
#cd /home/work/apodeixi &>> ${TEST_LOG}
cd /usr/local/lib/${UBUNTU_PYTHON_PACKAGE}/dist-packages/apodeixi &>> ${TEST_LOG}

echo "[A6I_TEST_CONTAINER] Current directory is $(pwd)" &>> ${TEST_LOG}
echo &>> ${TEST_LOG}
echo "[A6I_TEST_CONTAINER] Python version is $(python --version)" &>> ${TEST_LOG}
echo "[A6I_TEST_CONTAINER] Python path is $(which python)" &>> ${TEST_LOG}
echo &>> ${TEST_LOG}

echo &>> ${TEST_LOG}
echo "[A6I_TEST_CONTAINER] =========== python -m unittest" &>> ${TEST_LOG}
# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this action took
SECONDS=0
echo &>> ${TEST_LOG}
python -m unittest &>> ${TEST_LOG} 2>/tmp/error
abort_testrun_on_error
# Check if tests passed. We know there is a failure if the next-to-last line is something like "FAILED (failures=1, errors=16)"
test_status= $(tail -n 2 ${TEST_LOG})
if grep -q "FAILED" <<< "$test_status"
    then
        echo "Aborting testrun because not all tests passed"  >/dev/stderr
        echo >/dev/stderr
        echo "${test_status}"  >/dev/stderr
        echo >/dev/stderr
        echo exit 1
    else
        echo "Status of test run:"  >/dev/stdout
        echo >/dev/stdout
        echo "${test_status}"  >/dev/stdout
        echo >/dev/stdout
fi

# Compute how long we took in this script
duration=$SECONDS
echo "[A6I_TEST_CONTAINER]         Completed 'python -m unittest' in $duration sec" &>> ${TEST_LOG}

echo &>> ${TEST_LOG}

echo "[A6I_TEST_CONTAINER] =========== DONE" &>> ${TEST_LOG}