#!/bin/bash

usage()
{
echo "
Usage: git nostr pullrequest [options] --secretkey --publickey --relay --title --description
   ex: git nostr pullrequest --secretkey npub1rep06k4pxl3alwl9a920h6vn27fq93mxf3xer7crq5xz89s6fh7qjwp8xt --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay ws://nostr.nostrin.gs --title "feature new pullrequests command" --description "pullrequests are like notes with a title, description, and public key of the related repository"
   add a new pullrequest referencing a git repository public key
   1) generate a patch with manifestid using 'git nostr publish' or 'git-nostr-list'

 Options:
   --publickey         nostr public key of the target repo (where to apply the pr)
   --relay             nostr relay url
   --secretkey         secret key to publish the pull request message
   --manifestid        nostr message id of the manifest (result from git nostr publish)
   --title             title suggestion for merge commit
   --description       description suggestion for merge commit
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
      --description)
        DESCRIPTION=$2
        shift
        shift
        ;;
      --manifestid)
        MANIFESTID=$2
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

if [ "$SECRETKEY" = "" ]; then
  usage
fi

if [ "$PUBLICKEY" = "" ]; then
  usage
fi

if [ "$MANIFESTID" = "" ]; then
  usage
fi

PULLREQUESTID=`nostril --envelope --sec "$SECRETKEY" --kind 7777 --tag purpose "git-nostr-pr" --tag title "$TITLE" --content "$DESCRIPTION" -p $PUBLICKEY  |\
  tee\
   >(websocat "$RELAY" | jq -c .|grep OK | jq --raw-output .[1])\
   >/dev/null`

echo $PULLREQUESTID