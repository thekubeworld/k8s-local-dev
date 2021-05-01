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
source ../lib/common.sh
source ../lib/calico.sh

trap calico_cleanup_cluster INT TERM

download_tools

kind_create_cluster \
	"${CALICO_CLUSTER_NAME}" \
	"$(pwd)"/kindConfig.yaml

apply_manifests \
	"${CALICO_MANIFESTS}"

calico_set_node_options

wait_all_pods_status_running \
	"${WAIT_PODS_TO_BECAME_RUNNING_SEC}"

calico_download_client \
	"${BIN_PATH}"/"${CALICO_CLIENT_NAME}"

calico_get_client_info
