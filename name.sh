#!/bin/bash

usage()
{
echo "
Usage: git nostr name <relay> [<publickey>] [options]
   ex: git nostr name --secretkey 8asfgasrg...xxxasrgqwt34 --relay ws://nostr.nostrin.gs
   publish a friendly name for a repo
 Options:
   --secretkey         nostr secret key (noscl keygen) or even (noscl key-gen|grep private|awk '{print$3}')
   --relay             nostr relay url
   --name              the name
   "
}

SUCCESSMSGS=""

while [[ $# -gt 0 ]]

do
    key="$1"
    case $key in
      -h | --help)
        usage
        ;;
      --relay)
        RELAY="$2"
        shift
        shift
        ;;
      --secretkey)
        SECRETKEY="$2"
        shift
        shift
        ;;
      --name)
        NAME="$2"
        shift
        shift
        ;;
      *)
        if [ -z "$COMMITID" ]; then
          NAME="$1"
        fi
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

SEVENTID=`nostril --envelope --sec "$SECRETKEY" --kind 7777 -p "$PUBLICKEY" --tag purpose "git-nostr-name" --content "$NAME"|\
  tee\
   >(websocat "$RELAY" | jq -c .|grep OK | jq --raw-output .[1])\
   >/dev/null`

echo $EVENTID