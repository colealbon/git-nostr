#!/bin/bash

usage()
{
echo "
Usage: git nostr create [options]
   ex: git nostr create --privatekey c76bnwp...9mhscg --publickey 0as8f..xj05af --relay ws://nostr.nostrin.gs
   # PUBLICKEY=`nostril --sec $SECRETKEY | jq --raw-output .pubkey`
 Options:
   --privatekey        nostr private key
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
        usage
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

git log --reverse|
grep --line-buffered "^commit "|
sed 's/.* //g'|
grep --line-buffered .| awk\
 -v secretkey="$SECRETKEY"\
 -v relay="$RELAY" \
'{system("publish.sh\
  --secretkey "secretkey"\
  --relay "relay"\
  --commitid "$1)}'