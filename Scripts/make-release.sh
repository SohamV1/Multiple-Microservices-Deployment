#!/bin/bash

source ./.env
set -euo pipefail

SCRIPTDIR="$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd )"
#echo $SCRIPTDIR

log() { echo "$1" >&2; }

TAG="${TAG:?TAG env variable must be specified}"
REPO_PREFIX="${REPO_PREFIX:?REPO_PREFIX env variable must be specified}"


read_manifests() {
    local dir
    dir=$1
    echo ${dir}
    while IFS= read -d $'\0' -r file; do
        echo "---"
        awk '
        /^[^# ]/ { found = 1 }
        found { print }' "${file}"
    done < <(find "${dir}" -name '*.yaml' -type f -print0)
}

#read_manifests "${SCRIPTDIR}/../kubernetes-manifests/"

edit_k8s() {

    for dir in ../src/*/; 
    do
        svcname="$(basename "${dir}")"
        image="$REPO_PREFIX/$svcname:$TAG"
        file="${SCRIPTDIR}/../kubernetes-manifests/${svcname}.yaml"
        sed -i "s|image:.*$svcname.*|image: ${image}|g" "$file"
    done
}

edit_k8s