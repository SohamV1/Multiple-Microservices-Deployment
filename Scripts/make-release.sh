#!/bin/bash


set -euo pipefail

SCRIPTDIR="$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd )"
echo $SCRIPTDIR

log() { echo "$1" >&2; }


REPO_PREFIX="${REPO_PREFIX}"
GITHUB_TOKEN="${GITHUB_TOKEN}"
GIT_USER_NAME="${GIT_USER_NAME}"
GIT_REPO_NAME="${GIT_REPO}"
TAG=${BUILD_NUMBER}



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
        image="$REPO_PREFIX$svcname:$TAG"
        echo $image
        file="${SCRIPTDIR}/../kubernetes-manifests/${svcname}.yaml"
        sed -i "s|image:.*$svcname.*|image: ${image}|g" "$file"
    done
    cd ..
    git add kubernetes-manifests/
    git commit -m "updates manifest files to ${TAG} version"
    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:master
}

edit_k8s