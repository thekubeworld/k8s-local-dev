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
source ../lib/common.sh

download_tools

if [[ ! -d "${OVN_KUBERNETES_DIR}" ]] ; then
    git clone "${OVN_KUBERNETES_GIT_TREE}"
fi

pushd "${OVN_KUBERNETES_DIR}" || exit
  pushd go-controller || exit
      make
  popd || exit

  pushd dist/images || exit
      make "${OVN_KUBERNETES_DISTRO}"
  popd || exit

  pushd contrib || exit
      KUBECONFIG="${HOME}"/admin.conf ./kind.sh
  popd || exit
popd || exit
