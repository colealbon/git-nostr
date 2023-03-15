#!/bin/bash

usage()
{
echo "
Usage: git nostr issue [options] --secretkey --publickey --relay --title --description
   ex: git nostr issue --secretkey npub1rep06k4pxl3alwl9a920h6vn27fq93mxf3xer7crq5xz89s6fh7qjwp8xt --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay ws://nostr.nostrin.gs --title "feature new issues command" --description "issues are like notes with a title, description, and public key of the related repository"
   add a new issue referencing a git repository public key
 Options:
   --publickey         nostr public key
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
      --title)
        TITLE=$2
        shift
        shift
        ;;
      --description)
        DESCRIPTION=$2
        shift
        shift
        ;;
      --publickey)
        PUBLICKEY=$2
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
      *)
        TITLE="$1"
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

if [ "$SECRETKEY" = "" ]; then
  SECRETKEY=`git config nostr.secretkey`
fi

if [ "$PUBLICKEY" = "" ]; then
PUBLICKEY=`git config nostr.publickey`
fi

if [ "$PUBLICKEY" = "" ]; then
PUBLICKEY=`nostril --sec $SECRETKEY | jq --raw-output .pubkey`
fi

if [ "$PUBLICKEY" = "" ]; then
  usage
fi

if [ "$TITLE" = "" ]; then
  usage
fi

ISSUEID=`nostril --envelope --sec "$SECRETKEY" --kind 7777 --tag purpose "git-nostr-issue" --tag title "$TITLE" --content "$DESCRIPTION" -p $PUBLICKEY  |\
  tee\
   >(websocat "$RELAY" | jq -c .|grep OK | jq --raw-output .[1])\
   >/dev/null`