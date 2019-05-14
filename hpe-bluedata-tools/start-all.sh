# start-all.sh
#
# Author:  Anne Marie Merritt anne.merritt@hpe.com
#
# This script automates the building of buildnvidiagpubeat-1.1.tar.gz.
#
# TODO: take an arg for the nvidiagpubeat branch being build. We will need this for
# Jenkins official build automation.
#
# Note:  if not using 'master' branch, checkout the relevant branch for your build(s).

# Tell everyone where our go path is when compile time comes around.
export PATH=$PATH:/opt/go/bin

#Clone and build the go-daemon
GIT_SSL_NO_VERIFY=true git clone https://github.com/bluedatainc/go-daemon

cd go-daemon
# Compile the go-daemon
make

cd /usr/build/nvidiagpubuild

#Setup and build nvidiagpubeat dev environment
mkdir beats_dev

export WORKSPACE=`pwd`/beats_dev
export GOPATH=$WORKSPACE
GIT_SSL_NO_VERIFY=true git clone git@github.com:bluedatainc/beats.git ${GOPATH}/src/github.com/elastic/beats --branch 6.5

#Clone nvidiagpubeat
mkdir $WORKSPACE/src/github.com/ebay
cd $WORKSPACE/src/github.com/ebay
GIT_SSL_NO_VERIFY=true git clone git@github.com:bluedatainc/nvidiagpubeat.git


#Build The Current version of nvidiagpubeat - we may want to make the branch a commandline variable.
cd $WORKSPACE/src/github.com/ebay/nvidiagpubeat/
git checkout gseidler/epic40

make setup
make

#RPM Packaging Step

ln -s /usr/build/nvidiagpubuild/go-daemon/god nvidiagpubeat-god

rpmbuild -bb nvidiagpubeat.spec

echo "rpm in: /root/rpmbuild/RPMS/x86_64/"

cp /root/rpmbuild/RPMS/x86_64/*.rpm /usr/build/nvidiagpubuild


cd /usr/build/nvidiagpubuild

ls -al

