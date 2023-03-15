# git-nostr (pre-prototype stage)
- A command line tool `git-nostr` for managing nostr git
- Git repo on [git-nostr][git-nostr]
```
# git-nostr patches public key: 0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631
nostril query \
  --kinds=7777 \
  --authors=0f578badfbc982c36aac5ca8ea973a0bea5ab93adaef9885e163fbe8d7e5e631 |
  websocat ws://nostr.nostrin.gs |
  jq .
```
# team
- Cole Albon: npub1c0le4pgu49j76fnt54xfyclkszlfrcjx2c5vvjatdfvey5sat3ws76lcvg

# install (manual)
- add git-nostr directory to path
- create a keypair for each repo with [noscl]
- run git nostr (without arguments) for help
```
noscl keygen
```

# todo
* [x] publish       publish commit to nostr as base64 encoded patch
* [x] deleteall     send delete request for every message for a given publickey
* [x] list          list manifest ids for git-nostr repos
* [x] clone         clone a git repo from "git nostr publish manifestid
* [x] create        set git nostr.publickey to public key and upload all commits to nostr
* [x] pull          create patch, send to repo public key
* [x] fork          Fork a git repo on nostr
* [x] forks         List forks of a repo
* [x] issues        List issues for a repo
* [x] pull-request  Create a pull-request
* [x] prs           List pull requests for a repo
* [x] authors       List contributors to a repo
* [ ] log           List history of updates to a repo
* [ ] name          Name a repo
* [ ] named         Search for repos by name
* [ ] web           Serve a web server for repos
* [ ] help          Get help about a command
* [ ] reconstruct   Reconstruct blobs for a git-update nostr message
* [ ] find-object   Find a git object in a repo
* [ ] remote-add    A git remote helper git-remote-nostr for using `nostr://` URLs with git

* [ ] create bounty   create a request for task and escrow payment
* [ ] claim bounty    link bounty to a git patch (aka invoice)
* [ ] approve claim   release paymeht for bounty

# kind=7777 tags (eventual NIPS)
- --tag purpose "git-nostr-chunk"
- --tag purpose "git-nostr-fork"
- --tag purpose "git-nostr-publish"
- --tag purpose "git-nostr-issue"
- --tag purpose "git-nostr-pullrequest"


tools required:
- [git]
- [nostril]
- [noscl]
- [websocat]
- [jq]

research:
- [nip17][nip17]
- [git-nostr-tools][git-nostr-tools]
- [git-ssb][git-ssb]
- [radicle][radicle]
- [export-git-patches.sh][export-git-patches.sh]
- [Formatting git patches for partially transplanting a repository][Formatting git patches for partially transplanting a repository]
- [extend-git-with-custom-commands][extend-git-with-custom-commands]
- [ssb-git-repo][ssb-git-repo]
- [git-remote-ssb][git-remote-ssb]

[git-nostr]: http://git.nostrin.gs/?p=git-nostr.git
[jq]: https://stedolan.github.io/jq/
[websocat]: https://docs.rs/crate/websocat
[nostril]: https://github.com/jb55/nostril
[nostr-tools]: https://www.npmjs.com/package/nostr-tools
[git-nostr]: https://github.com/colealbon/git-nostr
[nostr]: https://github.com/nostr-protocol
[git]: https://git-scm.com/
[git-ssb]:
https://git.scuttlebot.io/%25n92DiQh7ietE%2BR%2BX%2FI403LQoyf2DtR3WQfCkDKlheQU%3D.sha256
[radicle]: https://radicle.xyz/
[git-remote-ssb]: https://git.scuttlebot.io/%25ZVTOK3GA2aewEDI2rPxJqKXEIv4OIUN2swMPE2FeJm8%3D.sha256
[ssb-git-repo]: https://git.scuttlebot.io/%25xChSOex77EjNh%2BoS8LPLdq%2B4nK1gylButbAgjS1IINs%3D.sha256
[export-git-patches.sh]: https://gist.github.com/michitux/f7fdb2c36e728887b411e9aecb8e52ff
[Formatting git patches for partially transplanting a repository]: https://spoiledcat.com/blog/formatting-git-patches-for-partially-transplanting-a-repository/
[extend-git-with-custom-commands]: https://coderwall.com/p/bt93ia/extend-git-with-custom-commands
[noscl]: https://github.com/fiatjaf/noscl
[nip17]: https://github.com/nip17/nips/blob/master/17.md
[git-nostr-tools]: http://git.jb55.com/git-nostr-tools/file/README.txt.html