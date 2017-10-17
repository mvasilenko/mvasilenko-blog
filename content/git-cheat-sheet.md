---
title: "Git cheat sheet"
date: 2017-09-15T17:53:31+03:00
tag: ["git", "development"]
categories: ["development"]
topics: ["development"]
banner: "banners/git.png"
draft: false
---

https://www.devroom.io/2011/07/05/git-squash-your-latests-commits-into-one/

Merge three last commits into one

`git rebase -i HEAD~3`


Undo last two commits and push to the remote repo

```
git reset --hard HEAD~2
git push -f
```

Moving last 2 commits to a new branch

```
git branch newbranch      # Create a new branch, saving the desired commits
git reset --hard HEAD~2   # Move master back by 2 commits (GONE from master)
git checkout newbranch    # Go to the new branch that still has the desired commits
```

https://stackoverflow.com/questions/1628563/move-the-most-recent-commits-to-a-new-branch-with-git