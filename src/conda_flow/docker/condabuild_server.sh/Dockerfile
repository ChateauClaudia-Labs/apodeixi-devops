ARG UBUNTU_IMAGE
FROM ${UBUNTU_IMAGE}
RUN apt update && apt upgrade -y

# Get GIT
RUN apt install -y git

# Get curl (needed to download Conda)
RUN apt install curl

# Get Conda. This requires multiple steps. Based on instructions from https://linuxhint.com/install_anaconda_ubuntu/
#


# As explained in https://devopscube.com/keep-docker-container-running/, to ensure that the build server keeps running
# after running build script, in case that we want to debug it, we must have an entrypoint:
#
ENTRYPOINT ["tail", "-f", "/dev/null"]


