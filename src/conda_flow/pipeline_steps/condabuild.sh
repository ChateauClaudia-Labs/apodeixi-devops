#!/usr/bin/env bash

# This script is meant to run inside the condabuild server container.
#

# NB: /home/output is mounted on this container's host filesystem
#

LOGS_DIR="/home/output/logs" # This is a mount of a directory in host machine, so it might already exist
if [ ! -d "${LOGS_DIR}" ]; then
  mkdir ${LOGS_DIR}
fi

export CONDA_BUILD_LOG="${LOGS_DIR}/${TIMESTAMP}_condabuild.txt"

echo "[A6I_CONDA_BUILD_SERVER] ---------- Conda build logs ---------- $(date) ---------- " &>> ${CONDA_BUILD_LOG}

echo "[A6I_CONDA_BUILD_SERVER] Hostname=$(hostname)" &>> ${CONDA_BUILD_LOG}
echo &>> ${CONDA_BUILD_LOG}

echo "[A6I_CONDA_BUILD_SERVER] Current directory is $(pwd)" &>> ${CONDA_BUILD_LOG}
echo "[A6I_CONDA_BUILD_SERVER] Current user is is $(whoami)" &>> ${CONDA_BUILD_LOG}
echo &>> ${CONDA_BUILD_LOG}

echo "[A6I_CONDA_BUILD_SERVER] =========== conda-build  ${CONDA_RECIPE_DIR}" &>> ${CONDA_BUILD_LOG}
# Initialize Bash's `SECONDS` timer so that at the end we can compute how long this action took
SECONDS=0
echo &>> ${CONDA_BUILD_LOG}

/home/anaconda3/bin/conda-build /home/conda_build_recipe            &>> ${CONDA_BUILD_LOG}
if [[ $? != 0 ]]; then
    error=$(</tmp/error)
    echo "${ERR_PROMPT} ${error}" &>> ${CONDA_BUILD_LOG}
    # Signal error again, this time for caller to catch
    echo "Aborting build because: ${error}"  >/dev/stderr
    exit 1
fi
# Compute how long we took in this script
duration=$SECONDS
echo &>> ${CONDA_BUILD_LOG}
echo "[A6I_CONDA_BUILD_SERVER]         Completed 'conda-build' in $duration sec" &>> ${CONDA_BUILD_LOG}

echo &>> ${CONDA_BUILD_LOG}
echo "[A6I_CONDA_BUILD_SERVER] =========== Convert to all platforms and creating distribution folder" &>> ${CONDA_BUILD_LOG}
echo &>> ${CONDA_BUILD_LOG}

if [ ! -d /home/output/dist ]
    then
        mkdir /home/output/dist
fi

/home/anaconda3/bin/conda convert --platform all \
    /home/anaconda3/conda-bld/linux-64/apodeixi-${APODEIXI_VERSION}-py*.tar.bz2 \
    -o /home/output/dist        &>> ${CONDA_BUILD_LOG}
if [[ $? != 0 ]]; then
    error=$(</tmp/error)
    echo "${ERR_PROMPT} ${error}" &>> ${CONDA_BUILD_LOG}
    # Signal error again, this time for caller to catch
    echo "Aborting build because: ${error}"  >/dev/stderr
    exit 1
fi

echo &>> ${CONDA_BUILD_LOG}
echo "[A6I_CONDA_BUILD_SERVER] Created these distributions:" &>> ${CONDA_BUILD_LOG}
echo &>> ${CONDA_BUILD_LOG}
echo "$(ls /home/output/dist)" &>> ${CONDA_BUILD_LOG}
echo &>> ${CONDA_BUILD_LOG}
echo "[A6I_CONDA_BUILD_SERVER] =========== DONE" &>> ${CONDA_BUILD_LOG}
