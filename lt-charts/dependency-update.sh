#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )
DIR=$(pwd)

function cleanup {
    cd ${DIR}
}
trap cleanup EXIT

# Update dependencies in the correct order
set -ex

cd ${SCRIPT_DIR}

#helm dependency update util

helm dependency update ceph-helm-toolkit
helm dependency update ceph-helm
helm dependency update ceph
helm dependency update ceph-client

helm dependency update psql-operator
helm dependency update psql-operator-client

set +ex
