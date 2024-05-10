#!/bin/bash

set -euo pipefail
SCRIPTDIR="$(cd "$( dirname "$BASH_SOURCE[0]")" && pwd )"
echo $SCRIPTDIR
BUILD_NUMBER="{env.BUILD_NUMBER}"
echo $BUILD_NUMBER
REPO_PREFIX="{env.REPO_PREFIX}"
echo $REPO_PREFIX
log() { echo "$1" >&2; }

TAG=${BUILD_NUMBER}
echo $TAG
REPO_PREFIX=${REPO_PREFIX}
echo $REPO_PREFIX

while IFS= read -d $'\0' -r dir; do
    echo $IFS
    svcname="$(basename "${dir}")"
    builddir="${dir}"
    image="$svcname:$TAG"
    (
        cd "${builddir}"
        log "Building and pushing: ${image}"
        docker build -t "${image}" .
    )
done < <(find "${SCRIPTDIR}/../src" -mindepth 1 -maxdepth 1 -type d -print0)

log "Successfully built and pushed all the images"