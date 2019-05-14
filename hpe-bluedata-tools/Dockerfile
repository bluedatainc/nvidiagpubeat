################################################################################
# Build container env for building nvidiagpubeat provider rpm. 
# 
#
################################################################################

################################################################################
# Extract elasticsearch artifact
# Install required plugins
# Set gid=0 and make group perms==owner perms
################################################################################

FROM centos:centos7

RUN yum -y install git python python-setuptools python-argparse cronie initscripts wget unzip which python-virtualenv gcc gcc-c++ make rpm-build rpmdevtools
RUN yum update -y

RUN curl --retry 8 -s http://10.2.12.27:8080/build/thirdparty/gotools/go1.12.5.linux-amd64.tar.gz | tar -C /opt -zxf -

RUN mkdir -p /root/.ssh
ADD known_hosts /root/.ssh

RUN mkdir -p /usr/build/nvidiagpubuild

WORKDIR /usr/build/nvidiagpubuild
ADD start-all.sh /usr/build/nvidiagpubuild/start-all.sh

ENTRYPOINT ["/usr/bin/bash"]

