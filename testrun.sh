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
git am --abort
git nostr deleteall --secretkey 84ad36bd1dd55ecdc0533be3a4c9b4d827a863ab5989d564a8c81b815a8a791d --relay wss://nostr.nostrin.gs
git nostr fork --secretkey 84ad36bd1dd55ecdc0533be3a4c9b4d827a863ab5989d564a8c81b815a8a791d --relay wss://nostr.nostrin.gs --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631

cd ~/git-nostr
git nostr forks --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay wss://nostr.nostrin.gs

git nostr issue --secretkey 525a96aa880c4eae758d2d4bb0b92911e6a30d9503efa10066ace7994a26f706 --publickey 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 --relay wss://nostr.nostrin.gs --title "feature new issues command" --description "less chit chat, more bang bang"

nostril query --kinds 7777 -g "p" "0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631"|websocat wss://nostr.nostrin.gs|grep git-nostr-issue|jq .|jq '.[2] | {title: .tags[] | select(.[0] == "title") | .[1], content}'

# git nostr pr --publickey 0f578bd5889ed2ad606ef9b866d531d58e1e50ffcf20e5e34d958220f0430884
# git nostr prs --relay wss://nostr.nostrin.gs --publickey 0f578bd5889ed2ad606ef9b866d531d58e1e50ffcf20e5e34d958220f0430884

# nostril --envelope --tag -e 6e17f0702603e904af540482fd45e6bab8d1242ab84e3513ebf58ec8428729ce --kind 5 --sec 525a96aa880c4eae758d2d4bb0b92911e6a30d9503efa10066ace7994a26f706| websocat wss://nostr.nostrin.gs

# Vanity npub found:         patch target
# Found matching public key: 0f578bd5889ed2ad606ef9b866d531d58e1e50ffcf20e5e34d958220f0430884
# Nostr private key:         84ad36bd1dd55ecdc0533be3a4c9b4d827a863ab5989d564a8c81b815a8a791d
# Nostr public key (npub):   npub1patch4vgnmf26crwlxuxd4f36k8pu58leuswtc6djkpzpuzrpzzqk3jpuq
# Nostr private key (nsec):  nsec1sjknd0ga640vmszn8036fjd5mqn6scattxya2e9geqdczk520ywssxnr2g
# 54211036 iterations (about 5x10^7 hashes) in 375 seconds. Avg rate 144562 hashes/second

# Vanity npub found:         rep0 spurious project manager
# Found matching public key: 1e42fd5aa137e3dfbbe5e954fbe993579202c7664c4d91fb03050c23961a4dfc
# Nostr private key:         525a96aa880c4eae758d2d4bb0b92911e6a30d9503efa10066ace7994a26f706
# Nostr public key (npub):   npub1rep06k4pxl3alwl9a920h6vn27fq93mxf3xer7crq5xz89s6fh7qjwp8xt
# Nostr private key (nsec):  nsec12fdfd25gp382uavd949mpwffz8n2xrv4q0h6zqrx4nnejj3x7urq7muqyr
# 644394 iterations (about 6x10^5 hashes) in 3 seconds. Avg rate 214798 hashes/second

# Vanity npub found:         rep0 spurious developer
# Found matching public key: 1e42f6c9177de929ca8f78651021fd0be49ff49ed9d5415dc8e9cb50dd94636e
# Nostr private key:         8f54b81aa3f9d3d902d86e36cbb6686911e911a763763407e3b9561349cfb3a0
# Nostr public key (npub):   npub1rep0djgh0h5jnj500pj3qg0ap0jflay7m825zhwga894phv5vdhqek6x60
# Nostr private key (nsec):  nsec13a2tsx4rl8fajqkcdcmvhdngdyg7jyd8vdmrgplrh9tpxjw0kwsqclvcuj
