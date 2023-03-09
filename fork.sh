#!/bin/bash

usage()
{
echo "
Usage: git nostr fork [options]
   ex: git nostr fork --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --secretkey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay ws://nostr.nostrin.gs
   fetch all patches for public key and apply
 Options:
   --publickey         nostr public key (source repo)
   --secretkey         nostr secret key (target repo)
   --relay             nostr relay url
   "
exit 2
}

# fork a repo

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
      -h | --help)
        usage
        ;;
      --publickey)
        SOURCEPUBLICKEY=$2
        shift
        shift
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

if [ "$RELAY" = "" ]; then
  echo 'missing relay'
  usage
fi

if [ "$SOURCEPUBLICKEY" = "" ]; then
  echo 'missing public key'
  usage
fi

if [ "$SECRETKEY" = "" ]; then
  echo 'missing secret key'
  usage
fi

PUBLICKEY=`nostril --sec $SECRETKEY | jq --raw-output .pubkey`
echo "cloning "$SOURCEPUBLICKEY" to "$PUBLICKEY

git nostr clone --publickey $SOURCEPUBLICKEY --relay $RELAY
git nostr create --secretkey $SECRETKEY --relay $RELAY

ANNOUNCEMENTID=`nostril --envelope --sec $SECRETKEY --kind 7777 --content "$SOURCEPUBLICKEY --> $PUBLICKEY"  -p "$SOURCEPUBLICKEY" --tag purpose "git-nostr-fork"|\
tee \
  >(websocat $RELAY | jq -c .|grep OK | jq --raw-output .[1]) \
  >/dev/null`

git config nostr.forksource $SOURCEPUBLICKEY
git config nostr.secretkey $SECRETKEY
git config nostr.relay $RELAY
git config nostr.publickey $PUBLICKEY