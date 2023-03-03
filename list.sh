#!/bin/bash

usage()
{
echo "
Usage: git nostr list [options]
   ex: git nostr list --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay ws://nostr.nostrin.gs
   list repos for a public key
   # PUBLICKEY=`nostril --sec $SECRETKEY | jq --raw-output .pubkey`
 Options:
   --publickey         nostr public key
   --relay             nostr relay url
   "
exit 2
}

PUBLICKEY=""
RELAY=""

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
      -h | --help)
        usage
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


queryManifestMessageIDs () {
  nostril query --kinds 7777|
  websocat $RELAY|
  jq -c --raw-output '.[] '|
  grep "git-nostr-manifest"|
  tee  >(jq --raw-output .id) > /dev/null
}

queryManifestForAuthor () {
  nostril query --kinds 7777 --authors $PUBLICKEY|
  websocat $RELAY|
  jq -c --raw-output '.[] '|
  grep "git-nostr-manifest"|
  tee  >(jq --raw-output .id) > /dev/null
}

if [ "$PUBLICKEY" = "" ]; then
  queryManifestMessageIDs
  exit 0
fi

queryManifestForAuthor