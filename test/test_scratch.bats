#!/usr/bin/env bash

# Idioms and structure in this test file are as suggested in https://www.baeldung.com/linux/testing-bash-scripts-bats
# and in https://bats-core.readthedocs.io/en/stable/tutorial.html
#
# GOTCHA: the Baeldung link above has a typo in one of the lines, so don't copy and paste blindly.
#   Instead of:
#           git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-files
#       (typo is: bats-assert.git is not where bat-files resides! And it is bat-file, not bat-files!)
#   Use:
#           git submodule add https://github.com/bats-core/bats-file.git test/test_helper/bats-file

DEPRECATEDsetup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "should run script" {
    scratch.sh 'Hello ' 'Baeldung' '/tmp/output'
}
@test "should return concatenated strings" {
    run scratch.sh 'Hello ' 'Baeldung' '/tmp/output'

    assert_output 'Hello Baeldung'
    assert_output --partial 'Baeldung'
    refute_output 'Hello World'
}
@test "should create file" {
    run scratch.sh 'Hello ' 'Baeldung' '/tmp/output'

    assert_exist /tmp/output
}
@test "should write to file" {
    run scratch.sh 'Hello ' 'Baeldung' '/tmp/output'

    file_content=`cat /tmp/output`
    [ "$file_content" == 'Hello Baeldung' ]
}
@test "should write logs" {
    skip "Logs are not implemented yet"
    run scratch.sh 'Hello ' 'Baeldung' '/tmp/output'

    file_content=`cat /tmp/logs`
    [ "$file_content" == 'I logged something' ]
}
@test "test python version" {
    run python --version
    #python --version

    assert_output --partial "Python 3.9"
}
teardown() {
    rm -f /tmp/output
}