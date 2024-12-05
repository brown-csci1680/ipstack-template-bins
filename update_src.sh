#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

FILES="reference/vrouter \
       reference/arm64/vrouter \
       util/filter-net/config.json \
       util/filter-net/nodes.json \
       util/filter-net/ref-router.lnx \
       util/filter-net/your-router.lnx \
       util/filter-net/tester.lnx \
       util/vnet_filter_run \
       util/vnet_run \
       util/stakeholder-nets/pair1/config.json \
       util/stakeholder-nets/pair1/filter.lnx \
       util/stakeholder-nets/pair1/inside.lnx \
       util/stakeholder-nets/pair1/nodes.json \
       util/stakeholder-nets/pair1/outside.lnx \
       util/stakeholder-nets/pair2/config.json \
       util/stakeholder-nets/pair2/filter.lnx \
       util/stakeholder-nets/pair2/inside.lnx \
       util/stakeholder-nets/pair2/nodes.json \
       util/stakeholder-nets/pair2/outside.lnx \
       util/stakeholder-nets/pair3/config.json \
       util/stakeholder-nets/pair3/filter.lnx \
       util/stakeholder-nets/pair3/inside.lnx \
       util/stakeholder-nets/pair3/nodes.json \
       util/stakeholder-nets/pair3/outside.lnx \
       util/stakeholder-nets/pair4/config.json \
       util/stakeholder-nets/pair4/filter.lnx \
       util/stakeholder-nets/pair4/inside.lnx \
       util/stakeholder-nets/pair4/nodes.json \
       util/stakeholder-nets/pair4/outside.lnx \
       util/stakeholder-nets/pair5/config.json \
       util/stakeholder-nets/pair5/filter.lnx \
       util/stakeholder-nets/pair5/inside.lnx \
       util/stakeholder-nets/pair5/nodes.json \
       util/stakeholder-nets/pair5/outside.lnx \
       util/stakeholder-nets/pair6/config.json \
       util/stakeholder-nets/pair6/filter.lnx \
       util/stakeholder-nets/pair6/inside.lnx \
       util/stakeholder-nets/pair6/nodes.json \
       util/stakeholder-nets/pair6/outside.lnx \
"

TO_EXEC="
       reference/vrouter \
       reference/arm64/vrouter \
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

    echo "WARNING:  About to download several files.  Before continuing, please commit"
    echo "any unsaved changes to your git repository."
    echo ""
    echo "Press Enter to continue, Ctrl+C to exit."
    read

    # Download all files
    for target in $FILES; do
	target_dir=$(dirname $target)

	if [[ ! -e $target_dir ]]; then
	    mkdir -p $target_dir
	fi

	url="${URL_PREFIX}/$target"
	wget --no-verbose -O $target $url
    done

    # Make files executables
    for target in $TO_EXEC; do
	chmod -v +x $target
    done

    echo "util/vnet_filter_run text eol=lf" >> .gitattributes

    echo "Fetch complete!"
    echo "About to add all fetched files to git"
    echo ""
    echo "Press Enter to continue, Ctrl+C to exit."
    read

    # Add everything to git
    for target in $FILES; do
	git add -f $target
    done

    git add -f .gitattributes

    echo "Done."
}


main $@
