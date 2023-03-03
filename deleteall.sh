#!/bin/bash

usage()
{
echo "
Usage: git nostr deleteall [options]
   ex: git nostr deleteall --secretkey 52ed04be330fc70e005fb18b222e0fbaddce7511c19205a874c51c95ac53ebcd --relay ws://0.0.0.0:8080
   Send a delete event for all messages
   convienience command for development
 Options:
   --secretkey         nostr secret key
   --relay             nostr relay url
   "
exit 2
}

while [[ $# -gt 0 ]]

do
    key="$1"
    case $key in
      -h | --help)
        usage
        ;;
      --secretkey)
        SECRETKEY=$2
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

if [ "$SECRETKEY" = "" ]; then
  SECRETKEY=`git config nostr.secretkey`
fi

if [ "$RELAY" = "" ]; then
  RELAY=`git config nostr.relay`
fi

if [ "$SECRETKEY" = "" ]; then
  usage
fi

if [ "$RELAY" = "" ]; then
  usage
fi

PUBLICKEY=`nostril --sec $SECRETKEY | jq --raw-output .pubkey`

queryMessageIDsForDelete () {
  nostril query --kinds 7777 |
  websocat $RELAY |
  jq --raw-output '.[] ' |
  grep \"id\": |
  awk '{print $2}' |
  sed 's/[\",]//g'
}

createDeleteMessages () {
  awk \
    -v secretkey=$SECRETKEY \
    '{system(" \
    nostril \
      --envelope \
      --sec "secretkey" \
      --tag e \""$1"\"  \
      --kind 5" \
    )}'
}

DELETEDIDS=`queryMessageIDsForDelete | \
createDeleteMessages | \
tee \
  >(websocat "$RELAY" | jq -c .|grep OK | jq --raw-output .[1]) \
  >/dev/null \
`
echo $DELETEDIDS > /dev/null