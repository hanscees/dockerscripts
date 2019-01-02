#!/bin/bash

# Retrieves image tags from public
# images in DockerHub
#  if someone improves this script, please let me know, preferably in python
# hanscees@AT@hanscees.com
#adjusted from https://gist.github.com/cirocosta/17ea17be7ac11594cb0f290b0a3ac0d1x


set -o errexit

main() {
  check_args "$@"

  local image=$1
  local token=$(get_token $image)
  local tags=$(get_tags $image $token)
  echo "tags reported are:"
  echo $tags
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
get_tags() {
  local image=$1
  local token=$2

  echo "Retrieving image tags.
    IMAGE:  $image
  " >&2

  curl \
    --silent \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/tags/list" \
    | jq -r '.tags'
}
check_args() {
  if (($# != 1)); then
    echo "Error:
    One argument must be provided - $# provided.

    Usage:
      ./get-docker-hub-image-tags.sh <image>
      for instance ./get-docker-hub-image-tags.sh library/mariadb
Aborting."
    exit 1
  fi
}

main "$@"
