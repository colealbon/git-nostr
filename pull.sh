#!/bin/bash

usage()
{
echo "
Usage: git nostr pull [options]
   ex: git nostr pull 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631
   fetch all patches for public key and apply
 Options:
   --publickey         nostr public key
   --relay             nostr relay url
   "
exit 2
}
COMMITID=""
RELAY=""
PUBLICKEY=""
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
      -h | --help)
        usage
        ;;
      --manifestid)
        MANIFESTID=$2
        shift
        shift
        ;;
      --commitid)
        COMMITID=$2
        shift
        shift
        ;;
      --publickey)
        PUBLICKEY=$2
        shift
        shift
        ;;
      --relay)
        RELAY="$2"
        shift
        shift
        ;;
      *)
        COMMITID="$1"
        shift
        ;;
    esac
done

if [ "$RELAY" = "" ]; then
  RELAY=`git config nostr.relay`
fi

if [ "$RELAY" = "" ]; then
  usage
  exit 1
fi

if [ "$PUBLICKEY" = "" ]; then
  PUBLICKEY=`git config nostr.publickey`
fi

if [ "$PUBLICKEY" = "" ]; then
  queryManifestMessageIDs
  exit 0
fi

queryManifestForAuthor () {
  nostril query --kinds 7777 --authors $PUBLICKEY|
  websocat $RELAY|
  jq -c --raw-output '.[] '|
  grep "git-nostr-manifest"|
  tee  >(jq --raw-output .id) > /dev/null |
  awk -v relay="$RELAY" '{system("nostril query -i "$1"| websocat "relay )}'|
  jq '.[]'|jq -c|grep content| jq --raw-output .content|
  awk '{system("echo \""$1"\" | base64 -D")}'|
  jq -s 'sort_by(.sort)'
}

if [ "$COMMITID" != "" ]; then
  queryManifestForAuthor |
  jq -r --arg commitid "$COMMITID" '.[] | select(.commitid == $commitid) | .id' |
  awk -v relay="$RELAY" '{system("nostril query -i "$1"| websocat "relay )}' |
  jq '.[]'|jq -c|grep content| jq -r .content|
  awk '{system("echo \""$1"\" | base64 -D")}'|
  git am --reject
fi

if [ "$COMMITID$MANIFESTID" = "" ]; then
  queryManifestForAuthor |
  jq -r '.[] | .id' |
  awk -v relay="$RELAY" '{system("nostril query -i "$1"| websocat "relay )}' |
  jq '.[]'|jq -c|grep content| jq -r .content|
  awk '{system("echo \""$1"\" | base64 -D")}'|
  git am
fi

# TODO: publish a nostr message when commitid is applied


# scratch code is research to not fetch already applied patches
# REMOTECOMMITIDS=`
#   queryManifestForAuthor | grep --line-buffered . |
#   awk -v relay="$RELAY" '{system("nostril query -i "$1"| websocat "relay )}' |
#   jq '.[]'|jq -c|grep content| jq --raw-output .content|
#   awk '{system("echo \""$1"\" | base64 -D")}' |
#   jq --raw-output '.commitid'
# `

# COMMITIDS=`
#   git log |grep --line-buffered "^commit " |\
#   sed 's/.* //g'| sed 's/ /\n/g'
# `