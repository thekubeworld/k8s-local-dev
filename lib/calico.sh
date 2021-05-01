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
# shellcheck source=./config.sh
source "${DIR_LIBS}/config.sh"

function calico_set_node_options() {
    ##################################################################
    # Description:                                                   #
    #   Set Node Options                                             #
    ##################################################################
    for opt in "${CALICO_NODE_OPTIONS[@]}"; do
        echo "Setting ${opt} to calico-node..."
        if "${KUBECTL_CMD}" -n kube-system set env "${CALICO_DAEMONSET_ENV}" "${opt}" ; then
            continue
        else
            echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot to set ${opt} into the calico node"
            calico_cleanup_cluster "${CALICO_CLUSTER_NAME}"
            exit 1
        fi
    done
}

function calico_download_client() {
    ##################################################################
    # Description:                                                   #
    #   Download calicoctl and make the file executable              #
    ##################################################################
    echo
    echo "Downloading calicoctl.."
    path_calicoctl="${1}"
    if curl -o "${path_calicoctl}" -L "${CALICO_CLIENT_DOWNLOAD_URL}" ; then
        echo "Downloaded calico client ${CALICO_CLIENT_VERSION}..."
    else
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot download calicoctl ${CALICO_VERSION}"
        exit 1
    fi
    chmod +x "${path_calicoctl}"
}

function calico_cleanup_cluster() {
    ##################################################################
    # Description:                                                   #
    #   cleanup the kind cluster                                     #
    ##################################################################
    kind_cleanup_cluster "${CALICO_CLUSTER_NAME}"
}

function calico_get_client_info() {
    ##################################################################
    # Description:                                                   #
    #   Show information about client and server                     #
    ##################################################################
    echo -e "\n==========================="
    echo -e "\e[1m\e[32mCalico client output\e[0m"
    echo -e "==========================="
    "${CALICO_CLIENT_NAME}" version
}
