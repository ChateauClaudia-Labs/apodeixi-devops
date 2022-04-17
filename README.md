# apodeixi-devops
CI/CD pipeline for Apodeixi

This pipeline will:

* Build a distribution for Apodeixi, packaged as a multi-platform `wheel` artifact (i.e., works both in Windows and Linux)
* Create a Docker Apodeixi image with it, provisioning all
  dependencies required by Apodeixi.
* Start an Apodeixi container and run Apodeixi tests on it
* Deploy an Apodeixi container to a target environment

The pipeline is implemented as a suite of Bash scripts.

This pipeline and its associated tooling are only is meant to be run in Linux, even if Apodeixi itself is 
multi-platform (Windows and Unix).

Windows developers must therefore rely on WSL to run the CI/CD pipeline.

# Installing dependencies as GIT submodules

GIT submodule functionality is used to inject dependencies into this project. So after cloning this project, you will
need to set up the following submodules for the functionality of apodeixi-devops to work properly:

`git submodule add https://github.com/bats-core/bats-core.git test/bats`
`git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support`
`git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert`
`git submodule add https://github.com/bats-core/bats-file.git test/test_helper/bats-file`

# Running the CI/CD pipeline for Apodeixi

Docker must be running. If you are using a WSL environment, you can start the Docker daemon like this:

`sudo service docker start`

Once Docker is running, you may run the CI/CD pipeline by:

`<TBD - currently there is no Jenkins orchestration yet>`

# Running the tests for the pipeline itself

The CI/CD pipeline is a program (written as various Bash scripts), and it is tested using Bats (https://bats-core.readthedocs.io/en/stable/index.html), a testing framework for Bash scripts.

All tests and their tooling lies in the test folder.

To run all the tests, change directory to the root of the apodeixi-devlops project and run this command in Bash:

`./test/bats/bin/bats -r test/src`

To run a particular test, replace `test` by its relative path. For example, to run the `test/test_build.bats`,
run this in Bash:

`./test/bats/bin/bats test/src/docker_flow/test_build.bats`

If tests fail and we need to see the temporary output (e.g., logs and such), set this environment variable before running
the tests:

`export KEEP_TEST_OUTPUT=1`

and later unset it when you no longer want to retain temporary output:

`unset KEEP_TEST_OUTPUT`


