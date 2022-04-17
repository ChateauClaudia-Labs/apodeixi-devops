#!/usr/bin/env bash

setup_file() {
    load 'test_helper/common-setup'
    _test_file_setup
    cd $PROJECT_ROOT/src/docker_flow/pipeline_steps
}

setup() {
    load 'test_helper/common-setup'
    _test_case_setup
    echo "================ $BATS_TEST_NAME ==========" >> $TEST_LOG
}

@test "1001" {
    echo "_______Test case description: build stage" >> $TEST_LOG

    run ./request_build.sh "ABC"

    echo "_______status: ${status}" >> $TEST_LOG
    echo "_______output:" >> $TEST_LOG
    echo "$output" >> $TEST_LOG

    # Validate that there are no errors in the log. And if we have errors, this will display the first one
    refute_line --partial "${ERR_PROMPT}"

    # Even if there are no errors in the log, if something more fatal happened, catch it here
    assert [ ${status} -eq 0 ]
}

teardown() {
    _generic_teardown  
}

teardown_file() {

    echo "Nothing to tear down in file" > /dev/null

}