#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

FILES="reference/vrouter \
       util/filter-net/config.json \
       util/filter-net/nodes.json \
       util/filter-net/ref-router.lnx \
       util/filter-net/your-router.lnx \
       util/filter-net/tester.lnx \
       util/test_sender \
       util/vnet_filter_run \
       util/vnet_run"

TO_EXEC="
       reference/vrouter \
       util/test_sender \
       util/vnet_filter_run \
       util/vnet_run"

__check_exists() {
    local _path
    _path=$1

    if [[ ! -e  $_path ]]; then
	echo "Unable to find ${_path} in current directory.  Are you running this script from the main dir of your repository?"
	exit 1
    fi
}

URL_PREFIX="https://github.com/brown-csci1680/ipstack-template/raw/refs/heads/f24-src/"

main() {

    __check_exists ${SCRIPT_DIR}/reference/vrouter
    __check_exists ${SCRIPT_DIR}/util/vnet_run

    if [[ ! -e $(which wget) ]]; then
	echo "ERROR:  wget not found on your system"
	echo "Are you sure you're running in the container?"
	echo "If you are, run:"
	echo "    sudo apt-get update && sudo apt-get install wget"
	echo "and then try again."
	exit 1
    fi

    for target in $FILES; do
	target_dir=$(dirname $target)

	if [[ ! -e $target_dir ]]; then
	    mkdir -p $target_dir
	fi

	wget -O $target ${URL_PREFIX}/$target
    done

    for target in $TO_EXEC; do
	chmod -v +x $target
    done

    echo "Done."
}


main $@
