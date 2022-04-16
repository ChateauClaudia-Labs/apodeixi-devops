#!/usr/bin/env bash

_test_case_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'

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

    # File in which to log output from the tests
    export TEST_LOG="${PROJECT_ROOT}/test/output/logs/${TIMESTAMP}_testrun.txt"
    touch ${TEST_LOG}

    # Log entry prefixes used by Apodeixi DevOps
    export ERR_PROMPT="[A6I CI/CD ERROR]"
    export INFO_PROMPT="[A6I CI/CD INFO]"
}