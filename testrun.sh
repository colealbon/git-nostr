TARGETSECRETKEY="84ad36bd1dd55ecdc0533be3a4c9b4d827a863ab5989d564a8c81b815a8a791d"
RELAY="wss://nostr.nostring.gs"
FORKSOURCE="0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631"
SECRETKEY=`git config nostr.secretkey`

cd ~/git-nostr
git nostr deleteall --secretkey `git config nostr.secretkey` --relay `git config nostr.relay`
git nostr create --secretkey `git config nostr.secretkey` --relay `git config nostr.relay`
cd ~/target;
rm -r -f *;
cd ~/target/.git;
rm -r -f rebase-apply FETCH_HEAD ORIG_HEAD description index logs packed-refs HEAD hooks info objects refs;
cd ~/target
git init
git nostr deleteall --secretkey 84ad36bd1dd55ecdc0533be3a4c9b4d827a863ab5989d564a8c81b815a8a791d --relay wss://nostr.nostrin.gs
git nostr fork --secretkey 84ad36bd1dd55ecdc0533be3a4c9b4d827a863ab5989d564a8c81b815a8a791d --relay wss://nostr.nostrin.gs 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631

cd ~/git-nostr
nostril query --kinds 7777 -g "p" "0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631"| websocat wss://nostr.nostrin.gs

# Vanity npub found:         patch target
# Found matching public key: 0f578bd5889ed2ad606ef9b866d531d58e1e50ffcf20e5e34d958220f0430884
# Nostr private key:         84ad36bd1dd55ecdc0533be3a4c9b4d827a863ab5989d564a8c81b815a8a791d
# Nostr public key (npub):   npub1patch4vgnmf26crwlxuxd4f36k8pu58leuswtc6djkpzpuzrpzzqk3jpuq
# Nostr private key (nsec):  nsec1sjknd0ga640vmszn8036fjd5mqn6scattxya2e9geqdczk520ywssxnr2g
# 54211036 iterations (about 5x10^7 hashes) in 375 seconds. Avg rate 144562 hashes/second