#!/bin/bash

usage()
{
echo "
Usage: git nostr clone [options]
   ex: git nostr clone --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay ws://nostr.nostrin.gs
   fetch all patches for public key and apply
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
      --publickey)
        SOURCEPUBLICKEY=$2
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
      *)
        PUBLICKEY="$1"
        shift
        ;;
    esac
done

if [ "$RELAY" = "" ]; then
  RELAY=`git config nostr.relay`
fi

if [ "$SECRETKEY" = "" ]; then
  SECRETKEY=`git config nostr.secretkey`
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

queryManifestForAuthor () {
  nostril query --kinds 7777 --authors $SOURCEPUBLICKEY|
  websocat $RELAY|
  jq -c --raw-output '.[]'|
  grep "git-nostr-publish"|
  tee  >(jq --raw-output .id) > /dev/null
}

PUBLICKEY=`nostril --sec $SECRETKEY | jq --raw-output .pubkey`

git init
git config nostr.publickey $PUBLICKEY
git config nostr.relay $RELAY
queryManifestForAuthor | grep --line-buffered .|
awk -v relay="$RELAY" '{system("nostril query -i "$1"| websocat "relay )}'|
jq '.[]'|jq -c|grep content| jq --raw-output .content|
awk '{system("echo \""$1"\" | base64 -D")}'|
jq --raw-output '.id'|
awk -v relay="$RELAY" '{system("nostril query -i "$1"| websocat "relay )}'|
grep EVENT|
jq '.[]'|
jq --raw-output -c .|
grep --line-buffered "\"content\""|
jq --raw-output .content|
grep --line-buffered .|
awk '{system("echo "$1"|base64 -d")}'|
git am --committer-date-is-author-date

ANNOUNCEMENTID=`nostril --envelope --sec $SECRETKEY --kind 7777 --content "$SOURCEPUBLICKEY --> $PUBLICKEY"  -p "$SOURCEPUBLICKEY" --tag purpose "git-nostr-clone"|\
tee \
  >(websocat $RELAY | jq -c .|grep OK | jq --raw-output .[1]) \
  >/dev/null`

git config nostr.clonesource $SOURCEPUBLICKEY
git config nostr.secretkey $SECRETKEY
git config nostr.relay $RELAY
git config nostr.publickey $PUBLICKEY