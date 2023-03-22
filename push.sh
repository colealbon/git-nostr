#!/bin/bash

usage()
{
echo "
Usage: git nostr push <relay> [<publickey>] [options]
   ex: git nostr push --secretkey 8asfgasrg...xxxasrgqwt34 --relay ws://nostr.nostrin.gs --chunksize 50
   publish all unpublished patches
 Options:
   --secretkey         nostr secret key (noscl keygen) or even (noscl key-gen|grep private|awk '{print$3}')
   --relay             nostr relay url
   --chunksize         length of base64 characters per message
   "
}

PRIVATE="0"
CHUNKSIZE="32768"
SECRETKEY=""
RELAY=""

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
      --chunksize)
        CHUNKSIZE="$2"
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

queryManifestForAuthor () {
  nostril query --kinds 7777 --authors $PUBLICKEY|
  websocat $RELAY|
  jq -c --raw-output '.[] '|
  grep "git-nostr-publish"|
  tee  >(jq --raw-output .id) > /dev/null |
  awk -v relay="$RELAY" '{system("nostril query -i "$1"| websocat "relay )}'|
  jq '.[]'|jq -c|grep content| jq --raw-output .content|
  awk '{system("echo \""$1"\" | base64 -D")}'|
  jq -s 'sort_by(.sort)'
}

LOCALCOMMITS=`git log --reverse|grep  "^commit " |sed 's/.* //g'`
REMOTECOMMITS=`queryManifestForAuthor`

for LOCALCOMMIT in "$LOCALCOMMITS"; do
    CHECKALREADYPUBLISHED=""
    CHECKALREADYPUBLISHED=`echo $REMOTECOMMITS| jq -r --arg commitid "$LOCALCOMMIT" '.[] | select(.commitid == $commitid) | .id'`
    if [ "$CHECKALREADYPUBLISHED" = "" ]; then
      ./publish.sh "$@" $LOCALCOMMIT
    fi
done