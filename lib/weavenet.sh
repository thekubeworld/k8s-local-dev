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

function weavenet_cleanup_cluster() {
    ##################################################################
    # Description:                                                   #
    #   cleanup the kind cluster                                     #
    ##################################################################
    kind_cleanup_cluster "${WEAVENET_CLUSTER_NAME}"
}
