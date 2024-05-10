#!/bin/bash


set -euo pipefail

SCRIPTDIR="$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd )"
echo $SCRIPTDIR

log() { echo "$1" >&2; }

BUILD_NUMBER="${BUILD_NUMBER}"
REPO_PREFIX="${REPO_PREFIX}"
TAG=${BUILD_NUMBER}
REPO_PREFIX=${REPO_PREFIX}"


# read_manifests() {
#     local dir
#     dir=$1
#     echo ${dir}
#     while IFS= read -d $'\0' -r file; do
#         echo "---"
#         awk '
#         /^[^# ]/ { found = 1 }
#         found { print }' "${file}"
#     done < <(find "${dir}" -name '*.yaml' -type f -print0)
# }

#read_manifests "${SCRIPTDIR}/../kubernetes-manifests/"

edit_k8s() {

    for dir in ../src/*/; 
    do
        svcname="$(basename "${dir}")"
        if [[ $svcname == .* ]]
        then
            echo "Skipping hidden directory: $svcname"
            continue
        fi
        image="$REPO_PREFIX/$svcname:$TAG"
        file="${SCRIPTDIR}/../kubernetes-manifests/${svcname}.yaml"
        sed -i "s|image:.*$svcname.*|image: ${image}|g" "$file"
        git add .
        git commit -m "update in manifest files to ${TAG}"
        git push origin master
    done
}

edit_k8s