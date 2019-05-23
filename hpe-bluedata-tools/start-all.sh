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

OPTS=$(getopt -u --options $SHORTOPTS --longoptions "$LONGOPTS" -- "$@")

DEFAULT_NVIDIAGPUBEAT_BRANCH=mainline
DEFAULT_GO_DAEMON_BRANCH=master
DEFAULT_BEATS_DEV_BRANCH=master

# Initialize to defaults.  If set otherwise, use those values.

NVIDIAGPUBEAT_BRANCH=$DEFAULT_NVIDIAGPUBEAT_BRANCH
GO_DAEMON_BRANCH=$DEFAULT_GO_DAEMON_BRANCH
BEATS_DEV_BRANCH=$DEFAULT_BEATS_DEV_BRANCH

print_usage() {

    echo "Usage:  ./start-all.sh -n mainline -g master -b master"
    echo "OPTIONAL: -n branch of nvidiagpubeat project" 
    echo "OPTIONAL: -g branch of go daemon project" 
    echo "OPTIONAL: -b branch of beats development project (used to build nvidiagpubeat)" 

}

while getopts ":n:g:b:" opt; do
    case $opt in
        n)
            NVIDIAGPUBEAT_BRANCH=$OPTARG
            ;;
        g)
            GO_DAEMON_BRANCH=$OPTARG
            ;;
        b)
            BEATS_DEV_BRANCH=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG."
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
    print_usage
            exit 1
            ;;
    esac
done

###################################################################
#
# Compile Time!
#
##################################################################


# Tell everyone where our go compiler executable is when compile time comes around.
export PATH=$PATH:/opt/go/bin

#Clone and build the go-daemon
GIT_SSL_NO_VERIFY=true git clone -b $GO_DAEMON_BRANCH git@github.com:bluedatainc/go-daemon.git

cd go-daemon
# Compile the go-daemon
make

# Back to the main build directory
cd /usr/build/nvidiagpubuild

#Setup and build nvidiagpubeat dev environment
mkdir beats_dev

export WORKSPACE=`pwd`/beats_dev
export GOPATH=$WORKSPACE
GIT_SSL_NO_VERIFY=true git clone -b $BEATS_DEV_BRANCH git@github.com:bluedatainc/beats.git ${GOPATH}/src/github.com/elastic/beats --branch 6.5

#Clone nvidiagpubeat
mkdir $WORKSPACE/src/github.com/ebay
cd $WORKSPACE/src/github.com/ebay
GIT_SSL_NO_VERIFY=true git clone -b $NVIDIAGPUBEAT_BRANCH git@github.com:bluedatainc/nvidiagpubeat.git

#Build The Current version of nvidiagpubeat - we may want to make the branch a commandline variable.
cd $WORKSPACE/src/github.com/ebay/nvidiagpubeat/

make setup
make

#RPM Packaging Step
# Rename the executable for the go-daemon so it's user is recognizable 
ln -s /usr/build/nvidiagpubuild/go-daemon/god nvidiagpubeat-god

# Build the rpm
rpmbuild -bb nvidiagpubeat.spec

echo "rpm in: /root/rpmbuild/RPMS/x86_64/"

# Place the rpm where we can find it.
cp /root/rpmbuild/RPMS/x86_64/*.rpm /usr/build/nvidiagpubuild

cd /usr/build/nvidiagpubuild

# Show everyone our beautiful fresh newly built rpm.
ls -al

# And we're done.
exit 0

