#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )
DIR=$(pwd)

function cleanup {
    cd ${DIR}
}
trap cleanup EXIT

set -e

for folder in $(find ${SCRIPT_DIR} -name build.sh -printf "%h\n"); do
    cd ${folder}
    ./build.sh
    cd ${DIR}
done

set +e
