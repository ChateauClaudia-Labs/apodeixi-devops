#!/usr/bin/env bash

setup_file() {
    load 'test_helper/common-setup'
    _test_file_setup
    cd $PROJECT_ROOT/src/pipeline_steps
}

setup() {
    load 'test_helper/common-setup'
    _test_case_setup
    echo "================ $BATS_TEST_NAME ==========" >> $TEST_LOG

    # For tests, use a test-specific pipeline album, instead of the default "production" album meant for "real" pipelines
    export PIPELINE_ALBUM=${PROJECT_ROOT}/test/pipelines
}

@test "build stage" {
    run ./request_build.sh 1001t

    echo "_______status: ${status}" >> $TEST_LOG
    echo "_______output:" >> $TEST_LOG
    echo "$output" >> $TEST_LOG

    # Validate that there are no errors in the log. And if we have errors, this will display the first one
    refute_line --partial "${ERR_PROMPT}"
}

teardown() {
    echo "Nothing to tear down" > /dev/null
}

teardown_file() {
    echo "Nothing to tear down" > /dev/null
}