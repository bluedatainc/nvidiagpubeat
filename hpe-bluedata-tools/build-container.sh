#!/bin/bash
#
# Builds epic/<containername> image
#
# Usage:
#     > ./build-container.sh --imgversion 1.1 --containername buildnvidiagpubeat
#
#set -x

set -a # export all the variable assignments in this file.

#define these for the case this script is called directly standalone
THIS_SCRIPT=$( readlink -m $( type -p $0 ))
CURR_DIR=`dirname ${THIS_SCRIPT}`

DEFAULT_BUILDCONTAINER_VERSION='1.1'
DEFAULT_BUILDCONTAINER_NAME='container'
IMGVERSION=''

print_help() {
    echo
    echo "USAGE: $0 [ -h ]"
    echo
    echo "            -h    : Prints usage details and exits."
    echo
    echo "     --imgversion : Base image version of MAJOR.MINOR format."
    echo "     --containername: name of container, e.g. 'monitoring' or 'buildnvidiagpubeat'"
    echo
}

parse_options() {
    while [ $# -gt 0 ]; do
        case $1 in
            -h|--help)
                print_help
                exit 0
                ;;
            --imgversion)
                IMGVERSION=$2
                shift
                ;;
            --containername)
                CONTAINERNAME=$2
                shift
                ;;
            --)
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    if [[ -z "${IMGVERSION}" ]]; then
        echo "NOTE:  --imgversion not specified. Using default version $DEFAULT_BUILDCONTAINER_VERSION instead."
        IMGVERSION=$DEFAULT_BUILDCONTAINER_VERSION
    fi
    if [[ -z "${CONTAINERNAME}" ]]; then
        echo "NOTE:  --containername not specified. Using default version $DEFAULT_BUILDCONTAINER_NAME instead."
        CONTAINERNAME=$DEFAULT_BUILDCONTAINER_NAME
    fi
}

SHORTOPTS="h"
LONGOPTS="containername:,imgversion:,help"
OPTS=$(getopt -u --options=$SHORTOPTS --longoptions=$LONGOPTS -- "$@")
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to parse the option(s) provided."
    print_help
    exit 1
fi

parse_options $OPTS

BUILDCONTAINER_BUNDLE_BASENAME="$CONTAINERNAME-$IMGVERSION.tar"
echo "NOTE: BUILDCONTAINER_BUNDLE_BASENAME is $BUILDCONTAINER_BUNDLE_BASENAME ."

BUILDCONTAINER_STRING="epic/$CONTAINERNAME"
echo "NOTE: BUILDCONTAINER_STRING is $BUILDCONTAINER_STRING ."

build_docker_image() {
    echo "Building docker image:  docker build -t $1 ."
    docker build -t $1 $CURR_DIR
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to build docker image: $1"
        exit 1
    fi
}

save_docker_image() {
    echo "Saving docker image : docker save -o ${BUILDCONTAINER_BUNDLE_BASENAME} $1"
    docker save -o ${BUILDCONTAINER_BUNDLE_BASENAME} $1
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to save docker image: ${BUILDCONTAINER_BUNDLE_BASENAME}"
        exit 1
    fi
    echo "Gzip'ing docker image : gzip -f9 ${BUILDCONTAINER_BUNDLE_BASENAME}"
    gzip -f9 ${BUILDCONTAINER_BUNDLE_BASENAME}
    echo "Image ${BUILDCONTAINER_BUNDLE_BASENAME}.gz successfully saved."
}

echo "Removing previous docker image with this version, if it exists."
docker rmi ${BUILDCONTAINER_STRING}:${IMGVERSION}
echo "Removing previously saved and gzip'd docker image, if it exists."
rm -rf ${BUILDCONTAINER_BUNDLE_BASENAME}.gz

echo "Building $BUILDCONTAINER_STRING image $BUILDCONTAINER_STRING:$IMGVERSION"
build_docker_image "${BUILDCONTAINER_STRING}:${IMGVERSION}"

echo "Saving $BUILDCONTAINER_STRING image $BUILDCONTAINER_STRING:$IMGVERSION"
save_docker_image "${BUILDCONTAINER_STRING}:${IMGVERSION}"
echo "Cleaning up docker to remove the image just built. Comment out to keep it."
docker rmi ${BUILDCONTAINER_STRING}:${IMGVERSION}

echo "Build complete! $BUILDCONTAINER_STRING image: ${BUILDCONTAINER_STRING}:${IMGVERSION} filename: ${BUILDCONTAINER_BUNDLE_BASENAME}.gz"

exit 0

