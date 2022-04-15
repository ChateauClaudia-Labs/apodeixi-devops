#!/bin/sh

# This script is meant to run inside the build server container.
#

# NB: /home/output is mounted on this container's host filesystem (see run_build_step.sh)
#
LOGS_DIR="/home/output/logs" # This is a mount of a directory in host machine, so it might already exist
if [ ! -d "${LOGS_DIR}" ]; then
  mkdir ${LOGS_DIR}
fi

WORKING_DIR="/home/work"
mkdir ${WORKING_DIR}

export build_log="${LOGS_DIR}/${TIMESTAMP}_build.txt"

# NB: Redirecting with &>> appends both standard output and standard error to the file

echo "---------- Build logs ---------- $(date) ---------- " &>> ${build_log}
echo  &>> ${build_log}
echo "Hostname=$(hostname)" &>> ${build_log}
echo &>> ${build_log}
cd ${WORKING_DIR} &>> ${build_log}
echo "Current directory is $(pwd)" &>> ${build_log}
echo "Current user is is $(whoami)" &>> ${build_log}
echo &>> ${build_log}
echo "=========== git clone  ${APODEIXI_GIT_URL} --branch v${APODEIXI_VERSION}" &>> ${build_log}
echo &>> ${build_log}
git clone  ${APODEIXI_GIT_URL} --branch v${APODEIXI_VERSION} &>> ${build_log}
echo &>> ${build_log}

echo "=========== Working area and Python version" &>> ${build_log}
echo &>> ${build_log}
cd /home/work/apodeixi &>> ${build_log}
echo "Current directory is $(pwd)" &>> ${build_log}
echo &>> ${build_log}
echo "Python version is $(python --version)" &>> ${build_log}
echo "Python path is $(which python)" &>> ${build_log}
echo &>> ${build_log}
#echo "=========== python setup.py install" &>> ${build_log}
#echo &>> ${build_log}
#python setup.py install &>> ${build_log}
#echo &>> ${build_log}
echo "=========== python setup.py bdist_wheel" &>> ${build_log}
echo &>> ${build_log}
python setup.py bdist_wheel &>> ${build_log}
echo &>> ${build_log}
echo "=========== copy wheel to host" &>> ${build_log}
echo &>> ${build_log}
cp -r dist /home/output/ &>> ${build_log}
echo &>> ${build_log}
echo "=========== DONE" &>> ${build_log}
