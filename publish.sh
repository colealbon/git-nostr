#!/bin/bash

usage()
{
echo "
Usage: git nostr create <relay> [<publickey>] [options]
   ex: git nostr publish --secretkey 8asfgasrg...xxxasrgqwt34 --relay ws://nostr.nostrin.gs --chunksize 50
   publish a commit patch and a manifest to nostr and return the message manifest id
 Options:
   --secretkey         nostr secret key (noscl keygen) or even (noscl key-gen|grep private|awk '{print$3}')
   --relay             nostr relay url
   --chunksize         length of base64 characters per message
   --commitid          commit id for publishing single commit nostr
   "
}

PRIVATE="0"
CHUNKSIZE="32768"
SECRETKEY=""
RELAY=""
COMMITID=""
MANIFEST=""
SUCCESSMSGS=""

while [[ $# -gt 0 ]]

do
    key="$1"
    case $key in
      -h | --help)
        usage
        ;;
      --commitid)
        COMMITID="$2"
        shift
        shift
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
      *)
        if [ -z "$COMMITID" ]; then
          COMMITID="$1"
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

patchesToBase64WithSortHints() {
  git log --reverse |
  grep --line-buffered "^commit " |
  sed 's/.* //g' |
  awk '{system("echo "$1" `git format-patch --root --stdout --no-stat --minimal --full-index --break-rewrites -1 "$1"|base64`")}' |
  nl -nrz |
  awk -v chunksize="$CHUNKSIZE" '{system("echo "$3"|base64 -d|base64 -b "chunksize"|grep .| nl -nrz|sed \"s\/^\/"$1" "$2" \/g\"")}'
  # $1 commitsort
  # $2 commitid
  # $3 chunksort
  # $4 content
}

base64WithSortHintsToNostrMessages() {
  awk \
    -v secretkey=$SECRETKEY \
    '{system(" \
    nostril \
      --envelope \
      --sec "secretkey" \
      --kind 7777 \
      --tag e "git-nostr-chunk" \
      --tag commitsort "$1" \
      --tag commitid "$2" \
      --tag commitchunksort "$3" \
      --content "$4 \
    )}'
}

if [ "$SECRETKEY" = "" ]; then
  echo
  echo "ERROR: create messages with secret key, then you can relay them"
  usage
  exit 1
fi

if [ "$COMMITID" = "" ]; then
SUCCESSMSGS=`patchesToBase64WithSortHints | \
  tee \
    >(base64WithSortHintsToNostrMessages |\
      grep --line-buffered . | websocat "$RELAY"  ) \
    >/dev/null | \
  jq -c .|grep OK | jq --raw-output .[1]
`
fi

if [ "$COMMITID" != "" ]; then
SUCCESSMSGS=`patchesToBase64WithSortHints |\
  tee \
    >(base64WithSortHintsToNostrMessages |\
      grep --line-buffered "$COMMITID" | websocat "$RELAY"  )\
    >/dev/null |\
  jq -c .|grep OK | jq --raw-output .[1]
`
fi

MANIFEST=`echo $SUCCESSMSGS |sed 's/ /\n/g' | grep --line-buffered .|
awk -v relay="$RELAY" '{system(\
"nostril query -i "$1" | websocat "relay"|\
jq -c .|grep EVENT |jq -c .[]|grep "$1)}'|
jq --raw-output '{
  id: .id,
  commitid: .tags[] | select(.[0] == "commitid") | .[1],
  commitsort: .tags[] | select(.[0] == "commitsort") | .[1],
  commitchunksort: .tags[] | select(.[0] == "commitchunksort") | .[1]
  }'|
base64
`

MANIFESTID=`nostril --envelope --sec "$SECRETKEY" --kind 7777 --tag e "git-nostr-manifest" --content "$MANIFEST"|\
  tee\
   >(websocat "$RELAY" | jq -c .|grep OK | jq --raw-output .[1])\
   >/dev/null`

ANNOUNCEMENTID=`nostril --envelope --sec $SECRETKEY --content "$MANIFESTID" --tag e "git-nostr-announce"|\
tee \
  >(websocat "$RELAY" | jq -c .|grep OK | jq --raw-output .[1]) \
  >/dev/null`

echo $MANIFESTID