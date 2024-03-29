#!/bin/bash

usage()
{
echo "
Usage: git nostr names [options]
   ex: git nostr names --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay ws://nostr.nostrin.gs
   list other people's forks forks for a public key
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
      *)
        PUBLICKEY="$1"
        shift
        ;;
    esac
done

if [ "$RELAY" = "" ]; then
  RELAY=`git config nostr.relay`
fi

if [ "$RELAY" = "" ]; then
  usage
fi

if [ "$PUBLICKEY" = "" ]; then
  PUBLICKEY=`git config nostr.publickey`
fi

if [ "$PUBLICKEY" = "" ]; then
  usage
fi

nostril query --kinds 7777|
websocat $RELAY|grep git-nostr-name|
jq -r '{event: .[2].id, name: .[2].content, pubkey: .[2].pubkey}' |jq -c|sort -u|grep -v null
