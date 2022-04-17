#!/usr/bin/env bash

_test_case_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/../" >/dev/null 2>&1 && pwd )"

    # Should uniquely identify the test in the test run
    export TESTCASE_ID="${BATS_TEST_NAME}"

    # Folder for temporary test output
    export TESTCASE_OUTPUT_DIR="${PROJECT_ROOT}/test/output/${TIMESTAMP}_${TESTCASE_ID}"
    if [ ! -d "${PROJECT_ROOT}/test/output" ]
        then
            mkdir "${PROJECT_ROOT}/test/output"
    fi

    mkdir ${TESTCASE_OUTPUT_DIR}

    # For tests, use a test-specific pipeline album, instead of the default "production" album meant for "real" pipelines
    export PIPELINE_ALBUM=${PROJECT_ROOT}/test/scenarios/${TESTCASE_ID}/pipeline_album

    export PIPELINE_OUTPUT="${TESTCASE_OUTPUT_DIR}/pipeline_run"

    # File in which to log output from the tests
    export TEST_LOG="${TESTCASE_OUTPUT_DIR}/test_log.txt"
    touch ${TEST_LOG}
}

_test_file_setup() {

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/../" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$PROJECT_ROOT/src:$PATH"

    # Unique timestamp used e.g., as a prefix in the names of log files
    export TIMESTAMP="$(date +"%y%m%d.%H%M%S")"

    # Log entry prefixes used by Apodeixi DevOps
    export ERR_PROMPT="[A6I CI/CD ERROR]"
    export INFO_PROMPT="[A6I CI/CD INFO]"

}

# This is the default logic for a test case teardown.
# It can be called by a bats test file's teardown function as a way to re-use generic teardown functionality across tests.
_generic_teardown() {
    if [[ -z $KEEP_TEST_OUTPUT && 0 -eq ${status} ]]
        then
            rm -rf ${TESTCASE_OUTPUT_DIR}
    elif [[ 0 -eq ${status} ]] # Test passed, but user had set $KEEP_TEST_OUTPUT
        then 
            # As per Bats documentation (https://bats-core.readthedocs.io/en/stable/writing-tests.html#printing-to-the-terminal),
            # we must redirect to 3 if we want to force printing information to the terminal
            echo >&3
            echo "Test output is being kept at:" >&3
            echo "      ${TESTCASE_OUTPUT_DIR}" >&3 
            echo >&3
            echo "Do 'unset KEEP_TEST_OUTPUT' in command line to discard future output" >&3 
    else
        # In this case, we had failures
        echo >&3
        echo "Test failed with status $status, so output is being kept at:" >&3
        echo "      ${TESTCASE_OUTPUT_DIR}" >&3
    fi    
}