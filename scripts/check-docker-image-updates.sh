#!/bin/bash

# Checks docker hub for updates on <image> <tag> <ImageId>
# ImageId without sha256: part
# script accepts <image> <tag> <ImageId> or sdtin

# reads file from standard in: lines in the form of
# nginx 1.14-alpine 315798907716a51610bb3c270c191e0e61112b19aae9a3bb0c2a60c53d074750
# mvance/unbound latest 4568745687569875689745689756
#
# Script calls other script ./getdigest. Can be found at github 
# https://gist.github.com/hanscees/5365205765d19c9d50d48f30fb864076 
#
#  if someone improves this script, please let me know, preferably in python
# hanscees@AT@hanscees.com


set -o errexit
> UpdateTheseImages
main() {

REPOS=""
TAG=""
ID=""

if [ -t 0 ] ; then 
  echo terminal input; #and no stdin
  check_args "$@"  #if input not from stdin
  REPOS=$1
  TAG=$2
  ID=$3
  report_result $REPOS $TAG $ID
else 
  echo "not a terminal, so reading stdin"; 
  while read line;  do
  declare -a ImageData=($line) #bash array
  REPOS=${ImageData[0]}
  TAG=${ImageData[1]}
  ID=${ImageData[2]}
  report_result $REPOS $TAG $ID
  done
fi
}  #end main


report_result () {
  REPOS=$1
  TAG=$2
  ID=$3
  echo "repo/image and tag are "
  echo $REPOS $TAG

  check_result=$(check_for_updates $REPOS $TAG $ID)
  echo check_result is $check_result

  if [ $check_result ]
  then 
   echo $REPOS $TAG can be updated: a new version is available
   echo also check file UpdateTheseImages
  else
   echo NO update found for $REPOS $TAG 
  fi	
  }


check_for_updates () {
  REPOS=$1
  TAG=$2
  ID=$3
  local myresult=0 #default return value
  timestamp=`date --rfc-3339=seconds`
  echo $timestamp >> debug
  echo $REPOS $TAG >> debug
  blub=`echo $REPOS | egrep "\/"`
  if [ ! "$blub" ] ; then REPOS=library/$REPOS ;fi  #add library/ before repro if needed
  DockerIdNew=`./get-docker-hub-image-tag-digest.sh $REPOS $TAG | jq -r '.config.digest' | awk -F':' '{print $2}' `
  echo DockeridNew is $DockerIdNew >> debug
  echo DockerIdLocal is $ID >>debug
  if [ ! $DockerIdNew ] ; then myresult="" ;echo $myresult ; exit ;fi    #if empty image was probably built locally

  if [ "$DockerIdNew" == "$ID" ]
  then
    #echo "you r good, no updates for $REPOS:$TAG"
    myresult=""
    echo $myresult
  else
    #echo "update available for $REPOS:$TAG"
    echo "update available for $REPOS:$TAG" >> UpdateTheseImages
    echo "update available for $REPOS:$TAG" >> debug
    myresult=1
    echo $myresult
  fi
  }




check_args() {
  if (($# != 3)); then
    echo "Error:
    Three argument must be provided - $# provided.

    Usage:
      ./check-docker-image-updates.sh <image> <tag> <imageID>
      for instance ./check-docker-image-updates.sh library/mariadb latest 2345623745234753647
      imageID is local digest image without sha256: part
Aborting."
    exit 1
  fi
}

main "$@"

