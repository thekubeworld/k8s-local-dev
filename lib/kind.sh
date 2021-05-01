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

function kind_create_cluster() {
    ##################################################################
    # Description:                                                   #
    #   Create cluster via kind                                      #
    ##################################################################

    cluster_name="${1}"
    conf="${2}"

    if "${KIND_CMD}" create cluster --name "${cluster_name}" --config "${conf}" ; then
        echo "Cluster created..."
    else
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot create cluster ${cluster_name} ${conf}"
        exit 1
    fi

    wait_cluster_be_ready
}

function kind_load_image() {
    ##################################################################
    # Description:                                                   #
    #   Load image to kind                                           #
    ##################################################################
    container_image="${1}"
    cluster_name="${cluster_name}"

    if "${KIND_CMD}" load docker-image "${container_image}" --name "${CILIUM_CLUSTER_NAME}" ; then
        echo "Image loaded: ${container_image}"
    else
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot load image ${container_image}"
        exit 1
    fi
}

function kind_cleanup_cluster() {
    ##################################################################
    # Description:                                                   #
    #   cleanup the kind cluster                                     #
    ##################################################################

    cluster_name="${1}"

    echo "Cleanup cluster ${cluster_name}..."
    if "${KIND_CMD}" delete cluster --name "${cluster_name}" ; then
        echo "Cluster ${cluster_name} removed..."
    else
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot cleanup cluster ${cluster_name}"
        exit 1
    fi
}
