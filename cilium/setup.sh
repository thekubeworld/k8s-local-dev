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
source ../lib/config.sh
source ../lib/common.sh
source ../lib/kind.sh

download_tools

kind_create_cluster \
	"${CILIUM_CLUSTER_NAME}" \
        "$(pwd)"/kindConfig.yaml

wait_cluster_be_ready

${HELM_CMD} repo add "${CILIUM_HELM_REPO_NAME}" "${CILIUM_HELM_REPO_URL}"
${CONTAINER_CMD_INTERFACE} pull "${CILIUM_IMAGE}"

kind_load_image \
	"${CILIUM_IMAGE}" \
	"${CILIUM_CLUSTER_NAME}"

${HELM_CMD} install \
        "${CILIUM_HELM_REPO_NAME}" \
        "${CILIUM_HELM_REPO_NAME}"/"${CILIUM_HELM_REPO_NAME}" \
        --version "${CILIUM_VERSION}" \
        --namespace "${CILIUM_HELM_NAMESPACE}" \
        --set nodeinit.enabled="${CILIUM_HELM_NODEINIT_ENABLED}" \
        --set kubeProxyReplacement="${CILIUM_HELM_KUBEPROXY_REPLACEMENT}" \
        --set hostServices.enabled="${CILIUM_HELM_HOSTSERVICES_ENABLED}" \
        --set externalIPs.enabled="${CILIUM_HELM_EXTERNALIPS_ENABLED}" \
        --set nodePort.enabled="${CILIUM_NODEPORT_ENABLED}" \
        --set hostPort.enabled="${CILIUM_HOSTPORT_ENABLED}" \
        --set bpf.masquerade="${CILIUM_BPF_MASQUERADE}" \
        --set image.pullPolicy="${CILIUM_IMAGE_PULLPOLICY}" \
        --set ipam.mode="${CILIUM_IPAM_MODE}"
