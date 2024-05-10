#!/bin/bash

set -euo pipefail
SCRIPTDIR="$(cd "$( dirname "$BASH_SOURCE[0]")" && pwd )"
echo $SCRIPTDIR
BUILD_NUMBER="${BUILD_NUMBER}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"
REPO_PREFIX="${REPO_PREFIX}"

log() { echo "$1" >&2; }

TAG=${BUILD_NUMBER}
echo $TAG
REPO_PREFIX=${REPO_PREFIX}
echo $REPO_PREFIX

while IFS= read -d $'\0' -r dir; do
    echo $IFS
    svcname="$(basename "${dir}")"
    if [ $svcname == .* ]
        then
            echo "Skipping hidden directory"
            continue
    fi
    builddir="${dir}"
    image="$REPO_PREFIX$svcname:$TAG"
    (
        if [ $svcname == "cartservice" ] 
        then
            builddir="${dir}/src"
        fi
        cd "${builddir}"
        docker system prune -f 
        docker container prune -f
        log "Building and pushing: ${image}"
        aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin "${REPO_PREFIX}"
        docker build -t "${svcname}" .
        docker tag "$svcname" "${image}"
        docker push "${image}"
    )
done < <(find "${SCRIPTDIR}/../src" -mindepth 1 -maxdepth 1 -type d -print0)

log "Successfully built and pushed all the images"