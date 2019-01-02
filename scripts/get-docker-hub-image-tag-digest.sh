#!/bin/bash

# Retrieves image digest from public
# images in DockerHub
#  if someone improves this script, please let me know, preferably in python
# hanscees@AT@hanscees.com
#adjusted from https://gist.github.com/cirocosta/17ea17be7ac11594cb0f290b0a3ac0d1x

set -o errexit

main() {
  check_args "$@"

  local image=$1
  local tag=$2
  local token=$(get_token $image)
  local digest=$(get_digest $image $tag $token)

echo " $digest" 

}

get_token() {
  local image=$1

  echo "Retrieving Docker Hub token.
    IMAGE: $image
  " >&2

  curl \
    --silent \
    "https://auth.docker.io/token?scope=repository:$image:pull&service=registry.docker.io" \
    | jq -r '.token'
}

# Retrieve the digest, now specifying in the header
# that we have a token (so we can pe...
get_digest() {
  local image=$1
  local tag=$2
  local token=$3

  echo "Retrieving image digest.
    IMAGE:  $image
    TAG:    $tag
  " >&2
#    TOKEN:  $token # add to echo for debug

  curl \
    --silent \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/manifests/$tag"
#    | jq -r '.config.digest'
}

check_args() {
  if (($# != 2)); then
    echo "Error:
    Two arguments must be provided - $# provided.

    Usage:
      ./get-docker-hub-digest.sh <image> <tag>
     for instance ./get-docker-hub-digest library/nginx 1.15-alpine

Aborting."
    exit 1
  fi
}

main "$@"
