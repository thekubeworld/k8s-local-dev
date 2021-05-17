#!/usr/bin/env bash
#
# Copyright 2021 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# this utility prints out the golang install dir, even if go is not installed
# IE it prints the directory where `go install ...` would theoretically place
# binaries
#

DIR_LIBS="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./kind.sh
source "${DIR_LIBS}/kind.sh"
# shellcheck source=./common.sh
source "${DIR_LIBS}/common.sh"

function antrea_clone_repo_and_set_version() {
    ##################################################################
    # Description:                                                   #
    #   Clone the repo and set version                               #
    #                                                                #
    #   Args: ${1} - version                                         #
    ##################################################################
    version="${1}"
    if [[ ! -d "${ANTREA_DIR}" ]] ; then
        echo "Cloning antrea git tree..."
        git clone https://github.com/vmware-tanzu/antrea.git 1> /dev/null
        pushd "${ANTREA_DIR}" 1> /dev/null || exit
            echo "Checkout to version ${version}..."
            git checkout "${version}"
        popd 1> /dev/null || exit
    fi
}

function antrea_cleanup_cluster() {
    ##################################################################
    # Description:                                                   #
    #   cleanup the kind cluster                                     #
    ##################################################################
    kind_cleanup_cluster "${ANTREA_CLUSTER_NAME}"
}

function antrea_create_cluster() {
    ##################################################################
    # Description:                                                   #
    #   create the kind cluster                                      #
    #                                                                #
    #   Args: ${1} - image name                                      #
    #         ${2} - version                                         #
    ##################################################################
    image_name="${1}"
    version="${2}"
    if [[ ! -d "${ANTREA_DIR}" ]] ; then
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] ${ANTREA_DIR} git tree is required."
        exit 1
    fi
    pushd "${ANTREA_DIR}"/ci/kind 1> /dev/null || exit
        echo "Setting cluster..."
        # kind-setup.sh will deploy Antrea with a Geneve overlay, for which
        # there is a know issue when using the OpenvSwitch userspace
        # datapath. By providing '--antrea-cni false' we can deploy Antrea
        # ourselves with a manifest that uses VXLAN instead of Geneve.
        if ./kind-setup.sh create "${ANTREA_CLUSTER_NAME}" --antrea-cni false; then
            echo "Cluster created"
        else
            echo -e "[ \e[1m\e[31mFAIL\e[0m  ] couldn't finish completely the kind deploy in the cluster"
	    exit 1
        fi
    popd 1> /dev/null || exit
    echo "Deploying Antrea..."
    IMG_NAME="${image_name}" IMG_TAG="${version}" "${ANTREA_DIR}"/hack/generate-manifest.sh --mode release --kind --tun vxlan | "${KUBECTL_CMD}" apply --context "kind-${ANTREA_CLUSTER_NAME}" -f -
}
