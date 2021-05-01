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
source ../lib/config.sh
source ../lib/common.sh

download_tools

if [[ ! -d "${FLANNEL_DIR_PLUGINS}" ]] ; then
    git clone "${FLANNEL_GIT_TREE}"
    pushd "${FLANNEL_DIR_PLUGINS}" || exit
        ./build_linux.sh
    popd || exit
fi

kind create cluster --name "${FLANNEL_CLUSTER_NAME}" --config kindConfig.yaml
wait_cluster_be_ready

"${KUBECTL_CMD}"  apply -f https://raw.githubusercontent.com/flannel-io/flannel/"${FLANNEL_VERSION}"/Documentation/kube-flannel.yml
