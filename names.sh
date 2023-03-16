#!/bin/bash

usage()
{
echo "
Usage: git nostr forks [options]
   ex: git nostr forks --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay ws://nostr.nostrin.gs
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

nostril query --kinds 7777 -g "p" "$PUBLICKEY"|
websocat $RELAY|grep git-nostr-name
#| jq -r '.[2].pubkey'|sort -u|grep -v null
