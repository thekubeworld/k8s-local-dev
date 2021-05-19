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
# set -eou pipefail
# set -xv

DIR_LIBS="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=./config.sh
source "${DIR_LIBS}/config.sh"

function cleanup_cluster() {
    ##################################################################
    # Description:                                                   #
    #   Destroy the kind cluster                                     #
    #                                                                #
    # Args:                                                          #
    #     ${1} = cluster name                                        #
    ##################################################################
    cluster_name="{$1}"
    "${KIND_CMD}" delete cluster --name "${cluster_name}"
    exit 1
} 

function wait_all_pods_status_running() {
    ##################################################################
    # Description:                                                   #
    #   Wait all pods in the cluster be in running status            #
    #                                                                #
    # Args:                                                          #
    #     ${1} = seconds to be used to wait until the next kubectl   #
    #            command                                             #
    ##################################################################
    sleep_sec="${1}"
    while true ; do
        cmd=$("${KUBECTL_CMD}" get pods -A --field-selector=status.phase!=Running -o name)
        if [ -z "${cmd}" ];
        then
           break
        fi
        echo
        numberpods=$(echo "${cmd}" | wc -l)
        echo -e "[\e[1m\e[32m$(date +"%r")\e[0m] The following " \
		"\e[1m\e[32m${numberpods} pods are NOT in RUNNING status " \
		"yet\e[0m... please wait $sleep_sec seconds for a " \
		"auto-refresh.. It might take a while..."
        echo -e "${cmd}"
        sleep "${sleep_sec}"
    done
}

function apply_manifests() {
    ##################################################################
    # Description:                                                   #
    #   Apply any required manifest to CNI                           #
    #                                                                #
    # Args:                                                          #
    #     ${1} = Array with the urls for the manifest                #
    ##################################################################
    manifests="${1}"
    echo
    for manifest in "${manifests[@]}"; do
        echo "Applying ${manifest}..." 1> /dev/null
        if "${KUBECTL_CMD}" apply -f "${manifest}" 1> /dev/null ; then
            continue
        else
            echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot apply ${manifest}"
            exit 1
        fi
    done
}

function download_bin() {
    ##################################################################
    # Description:                                                   #
    #   Download binary to specific path and give permission to exec #
    #                                                                #
    # Args:                                                          #
    #     ${1} = path to store the file                              #
    #     ${2} = URL to download the file                            #
    ##################################################################
    if curl -o "${1}" -LO "${2}" ; then
        echo "Download ${1} completed..."
    else
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot download ${1}"
        exit 1
    fi

    chmod +x "${1}"
}

function download_kind() {
    ##################################################################
    # Description:                                                   #
    #   Download kind tool                                           #
    ##################################################################

    GO111MODULE="on" go get sigs.k8s.io/kind@main
    export PATH="$(go env GOPATH)/bin:${PATH}"
    #echo "Downloading kind ${KIND_VERSION}..."
    #    download_bin \
    #        "${KIND_CMD}" \
    #        "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-$(uname)-amd64"
    #fi
}

function download_kubectl() {
    ##################################################################
    # Description:                                                   #
    #   Download kubectl tool                                        #
    ##################################################################
    echo "Downloading kubectl ${KUBECTL_VERSION}..."
    # not using uname as the case is wrong, and OSTYPE is more portable
    local ostype=""
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        ostype="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ostype="darwin"
    else
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] unsupported OS type $OSTYPE"
        exit 1
    fi
    download_bin \
        "${KUBECTL_CMD}" \
        "https://dl.k8s.io/release/""${KUBECTL_VERSION}""/bin/${ostype}/${KUBECTL_PLATFORM}/kubectl"
}

function set_bin_path() {
    ##################################################################
    # Description:                                                   #
    #   set binary path                                              #
    ##################################################################
    if mkdir -p "${BIN_PATH}"; then
        export PATH="${PATH}:${BIN_PATH}"
    else
        echo -e "[ \e[1m\e[31mFAIL\e[0m  ] cannot create ${BIN_PATH}"
        exit 1
    fi
}

function download_tools() {
    ##################################################################
    # Description:                                                   #
    #   Download all tools required to make the env work             #
    ##################################################################
    echo "Installing tools..."
    set_bin_path
    check_required_tools
    download_kind
    download_kubectl
}

function wait_cluster_be_ready() {
    ##################################################################
    # Description:                                                   #
    #   Wait cluster be ready                                        #
    ##################################################################
    until "${KUBECTL_CMD}" cluster-info;  do
        echo "$(date) Waiting for cluster..."
        sleep "${WAIT_CLUSTER_GET_READY_SEC}"
    done
}

function distro_name() {
    ##################################################################
    # Description:                                                   #
    #   Return the distro name                                       #
    ##################################################################
    source /etc/os-release
    return "${ID}"
}

function replace_kubeproxy_option() {
   ##################################################################
   # Description:                                                   #
   #   replace the kube proxy mode in the file kindConfig.yaml      #
   #   (in the current directory)                                   #
   ##################################################################
   mode="${1}"
   sed -i "s/kubeProxyMode: \"iptables\"/kubeProxyMode: \"${mode}\"/g" "${KIND_CONFIG_FILENAME}"
}

function get_flag_value_stdin_argument() {
    ##################################################################
    # Description:                                                   #
    #   find argument from script args                               #
    #                                                                #
    #   $1 - arguments from users, usually "$@"                      #
    #   $2 - the argument name to be found                           #
    ##################################################################

    # shellcheck disable=SC2206
    ARGUMENTS_FROM_USER=($1)
    FLAG_TO_BE_FOUND="${2}"

    # shellcheck disable=SC2068
    for item in ${ARGUMENTS_FROM_USER[@]}
    do
        case "${item}" in
           "${FLAG_TO_BE_FOUND}")
              shift
              echo "${ARGUMENTS_FROM_USER[$item]}"
              break
        esac
    done
}

function check_required_tools() {
    ##################################################################
    # Description:                                                   #
    #   required tools to start the deploy                           #
    ##################################################################

    # Its required to use --help, otherwise it will return ret as != 0
    bin_files=(
	"git --help"
	"curl --help"
	"make --help"
	"patch --help"
	"helm --help"
    )
    for cmd in "${bin_files[@]}"
    do
        if ${cmd} &> /dev/null; then
            continue
        else
            echo "error ${cmd} is required, please install in the system..."
            exit 1
        fi
    done
}
