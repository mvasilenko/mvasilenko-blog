---
title: "Git cheat sheet"
date: 2017-11-28T17:53:31+03:00
tag: ["git", "development"]
categories: ["development"]
topics: ["development"]
banner: "banners/git.png"
draft: false
---


# Moving backward and forward in commit history

`git reset HEAD~3` - move 3 commit backwards
`git reflog` - full commit history
`git reset 'HEAD@{x}'` - move to the specified point in commit history
`git log --graph --decorate --oneline $(git rev-list -g --all)` - show decoraded commit history


# Track remote branches

`git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git`

`for remote in `git branch -r`; do git branch --track ${remote#origin/} $remote; done`


# Delete remote branches

`git push -d <remote_name> <branch_name>`

`git branch -d <branch_name>`

If you wish to set tracking information for this branch you can do so with:

`git branch --set-upstream-to=origin/<branch> test_branch`


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


https://stackoverflow.com/questions/41283955/github-keeps-saying-this-branch-is-x-commits-ahead-y-commits-behind

x commits ahead, y commits behind

```
git remote add upstream https://github/upstream/repo.git

# sync changes from upstream

git pull --rebase upstream master
git push --force-with-lease origin master
```


# undo git pull

git pull is the same as git fetch + git merge
git reset --hard 1234abcd where 1234abcd is the hash of the desired commit.
