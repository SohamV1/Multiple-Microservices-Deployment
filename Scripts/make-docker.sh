#!/bin/bash
source ./.env
set -euo pipefail
SCRIPTDIR="$(cd "$( dirname "$BASH_SOURCE[0]")" && pwd )"
echo $SCRIPTDIR

log() { echo "$1" >&2; }

TAG="${TAG:?TAG env variable must be specified}"
#REPO_PREFIX="${REPO_PREFIX:?REPO_PREFIX env variable must be specified}"

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