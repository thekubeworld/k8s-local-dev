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
############## GENERAL ###################################
# Use docker or podman
if [[ -z "${CONTAINER_CMD_INTERFACE}" ]]; then
    CONTAINER_CMD_INTERFACE="docker"
fi

HELM_CMD="helm"

# Possible values: iptables, ipvs, none
KUBE_PROXY_ALL_MODES="iptables, ipvs and none"
KUBE_PROXY_MODE="iptables"

export CONTAINER_CMD_INTERFACE \
       HELM_CMD	\
       KUBE_PROXY_MODE \
       KUBE_PROXY_ALL_MODES

############## BIN FILES LOCATION ########################
# root dir of project
BIN_PATH="$(dirname "$(pwd)")/bin"
export BIN_PATH

############## CNI INFO ########################
CLUSTER_NAME=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 6 ; echo '')

################### FLANNEL ####################
if [[ -z "${FLANNEL_VERSION}" ]]; then
    FLANNEL_VERSION="v0.13.0"
fi
FLANNEL_CLUSTER_NAME="flannel-$(date '+%F')-${CLUSTER_NAME}"
FLANNEL_GIT_TREE="https://github.com/containernetworking/plugins.git"
FLANNEL_DIR_PLUGINS="plugins"
FLANNEL_MANIFESTS=(https://raw.githubusercontent.com/flannel-io/flannel/"${FLANNEL_VERSION}"/Documentation/kube-flannel.yml)
################### FLANNEL ####################

################### ANTREA ####################
if [[ -z "${ANTREA_VERSION}" ]]; then
    ANTREA_VERSION="v0.13.1"
fi
ANTREA_CLUSTER_NAME="antrea-$(date '+%F')-${CLUSTER_NAME}"
ANTREA_DIR="antrea"
ANTREA_IMAGE_NAME="projects.registry.vmware.com/antrea/antrea-ubuntu"
################### ANTREA ####################

################### CILIUM ####################
CILIUM_CLUSTER_NAME="cilium-$(date '+%F')-${CLUSTER_NAME}"
if [[ -z "${CILIUM_VERSION}" ]]; then
    CILIUM_VERSION="v1.9.5"
fi
CILIUM_IMAGE="quay.io/cilium/cilium:${CILIUM_VERSION}"
CILIUM_HELM_REPO_URL="https://helm.cilium.io/"
CILIUM_HELM_REPO_NAME="cilium"
CILIUM_HELM_NAMESPACE="kube-system"
CILIUM_HELM_NODEINIT_ENABLED="true"
CILIUM_HELM_KUBEPROXY_REPLACEMENT="partial"
CILIUM_HELM_HOSTSERVICES_ENABLED="false"
CILIUM_HELM_EXTERNALIPS_ENABLED="true"
CILIUM_NODEPORT_ENABLED="true"
CILIUM_HOSTPORT_ENABLED="true"
CILIUM_BPF_MASQUERADE="false"
CILIUM_IMAGE_PULLPOLICY="IfNotPresent"
CILIUM_IPAM_MODE="kubernetes"
################### CILIUM ####################

################### KINDNET ###################
KINDNETD_CLUSTER_NAME="kindnetd-$(date '+%F')-${CLUSTER_NAME}"
################### KINDNET ###################

################### CALICO ####################
CALICO_CLUSTER_NAME="calico-$(date '+%F')-${CLUSTER_NAME}"
CALICO_CLIENT_NAME="calicoctl"

if [[ -z "${CALICO_CLIENT_VERSION}" ]]; then
    CALICO_CLIENT_VERSION="v3.18.1"
fi

CALICO_CLIENT_DOWNLOAD_URL="https://github.com/projectcalico/calicoctl/releases/download/${CALICO_CLIENT_VERSION}/calicoctl"
CALICO_NODE_OPTIONS=(FELIX_IGNORELOOSERPF=true FELIX_XDPENABLED=false)
CALICO_MANIFESTS=(https://docs.projectcalico.org/manifests/calico.yaml)
CALICO_DAEMONSET_ENV="daemonset/calico-node"
################### CALICO ####################

################### OVN ####################
OVN_KUBERNETES_GIT_TREE="https://github.com/ovn-org/ovn-kubernetes"
OVN_KUBERNETES_DIR="ovn-kubernetes"
OVN_KUBERNETES_DISTRO="ubuntu"
################### OVN ####################

################### WEAVENET ####################
WEAVENET_CLUSTER_NAME="weavenet-$(date '+%F')-${CLUSTER_NAME}"
WEAVENET_MANIFESTS=(https://raw.githubusercontent.com/weaveworks/weave/master/prog/weave-kube/weave-daemonset-k8s-1.9.yaml)
################### WEAVENET ####################

export	FLANNEL_CLUSTER_NAME \
	FLANNEL_VERSION \
	FLANNEL_GIT_TREE \
	FLANNEL_DIR_PLUGINS \
	FLANNEL_MANIFESTS \
	ANTREA_CLUSTER_NAME \
	ANTREA_VERSION \
	ANTREA_DIR \
	ANTREA_IMAGE_NAME \
	CILIUM_CLUSTER_NAME \
	CILIUM_VERSION \
	CILIUM_IMAGE \
	CILIUM_HELM_REPO_NAME \
	CILIUM_HELM_REPO_URL \
	CILIUM_HELM_NAMESPACE \
	CILIUM_HELM_NODEINIT_ENABLED \
	CILIUM_HELM_KUBEPROXY_REPLACEMENT \
	CILIUM_HELM_HOSTSERVICES_ENABLED \
	CILIUM_HELM_EXTERNALIPS_ENABLED \
	CILIUM_NODEPORT_ENABLED \
	CILIUM_HOSTPORT_ENABLED \
	CILIUM_BPF_MASQUERADE \
	CILIUM_IMAGE_PULLPOLICY \
	CILIUM_IPAM_MODE \
	CALICO_CLUSTER_NAME \
	CALICO_CLIENT_NAME \
	CALICO_CLIENT_VERSION \
	CALICO_CLIENT_DOWNLOAD_URL \
	CALICO_NODE_OPTIONS \
	CALICO_MANIFESTS \
	CALICO_DAEMONSET_ENV \
	OVN_KUBERNETES_GIT_TREE \
	OVN_KUBERNETES_DIR \
	OVN_KUBERNETES_DISTRO \
	KINDNETD_CLUSTER_NAME \
	WEAVENET_CLUSTER_NAME \
	WEAVENET_MANIFESTS

############### KIND/KUBECTL SETTINGS ##########################

KIND_CMD="${BIN_PATH}"/kind
if [[ -z "${KIND_VERSION}" ]]; then
    KIND_VERSION="main"  # It can be v0.10.0 v0.11.0 etc
    KIND_CMD="kind"
fi
KIND_CONFIG_FILENAME="kindConfig.yaml"

if [[ -z "${KUBECTL_VERSION}" ]]; then
    KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
fi

KUBECTL_CMD="${BIN_PATH}"/kubectl

if [[ -z "${KUBECTL_PLATFORM}" ]]; then
    KUBECTL_PLATFORM="amd64"
fi

WAIT_CLUSTER_GET_READY_SEC=2
WAIT_PODS_TO_BECAME_RUNNING_SEC=5

export	KIND_VERSION \
	KIND_CMD \
	KIND_CONFIG_FILENAME \
	KUBECTL_VERSION \
	KUBECTL_CMD \
	KUBECTL_PLATFORM \
	WAIT_CLUSTER_GET_READY_SEC \
	WAIT_PODS_TO_BECAME_RUNNING_SEC
