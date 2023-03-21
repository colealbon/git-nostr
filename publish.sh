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

if [ "$COMMITID" = "" ]; then
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

CHECKALREADYPUBLISHED=`queryManifestForAuthor | jq -r --arg commitid "$COMMITID" '.[] | select(.commitid == $commitid) | .id'`

if [ "$CHECKALREADYPUBLISHED" != "" ]; then
  echo $COMMITID
  exit 1
fi


patchesToBase64WithSortHints() {
  git log --reverse |
  grep --line-buffered "^commit " |
  sed 's/.* //g' |
  awk '{system("echo \
    `git show "$1" --no-patch --oneline --no-abbrev-commit|cat|sed \"s/ .*$//g\"`\
    `git format-patch --root --stdout --no-stat --minimal --full-index --break-rewrites -1 "$1"|base64`\
    `git show "$1" --no-patch --oneline --no-abbrev-commit|cat|sed \"s/^[^ ]* //\"|base64`\
    ")}'|
  nl -nrz|
  awk -v chunksize="$CHUNKSIZE" '{system("echo "$3"|base64 -d|base64 -b "chunksize"|grep .| nl -nrz | sed \"s/^/"$1" "$2" "$4" /g\"")}'
  # $1 commitchunksort
  # $2 commitid
  # $3 description base64
  # $4 commitsort
  # $5 content base64
}

base64WithSortHintsToNostrMessages() {
  awk \
    -v secretkey=$SECRETKEY \
    '{system(" \
    nostril \
      --envelope \
      --sec "secretkey" \
      --kind 7777 \
      --tag sort "$1$4" \
      --tag commitid "$2" \
      --tag description \"`echo "$3"|base64 -D`\" \
      --content "$5 \
    )}'
}

if [ "$SECRETKEY" = "" ]; then
  echo
  echo "ERROR: create messages with secret key, then you can relay them"
  usage
  exit 1
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

MANIFESTID=""
RETRIES=0

while [ "$MANIFESTID" = "" ]
do
  sleep $((1 + 3 * $RETRIES))
  RETRIES=$(( $RETRIES + 1 ))
  if [ $RETRIES = 3 ]
  then
    RETRIES=0
    MANIFESTID="failed"
    echo "$COMMITID failed"
  fi
  MANIFEST=`echo $SUCCESSMSGS |sed 's/ /\n/g' | grep --line-buffered .|
  awk -v relay="$RELAY" '{system(\
  "nostril query -i "$1" | websocat "relay"|\
  jq -c .|grep EVENT |jq -c .[]|grep "$1)}'|
  jq --raw-output '{
    id: .id,
    commitid: .tags[] | select(.[0] == "commitid") | .[1],
    sort: .tags[] | select(.[0] == "sort") | .[1],
    description: .tags[] | select(.[0] == "description") | .[1],
    }'| base64
  `
  MANIFESTID=`nostril --envelope --sec "$SECRETKEY" --kind 7777 --tag purpose "git-nostr-publish" --content "$MANIFEST"|\
    tee\
    >(websocat "$RELAY" | jq -c .|grep OK | jq --raw-output .[1])\
    >/dev/null`
done

echo $COMMITID