---
title: "MacOS command line snippets"
date: 2018-01-18T17:58:06+03:00
tag: ["bash", "macos"]
categories: ["bash"]
topics: ["bash"]
draft: false
banner: "banners/bash.png"
---

# bash completion
```bash
brew install bash-completion
brew tap homebrew/completions
```

then add this to `.bash_profile`

```
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi
```


`ifconfig en0 alias 10.132.12.11`