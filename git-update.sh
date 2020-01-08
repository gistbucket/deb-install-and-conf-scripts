#!/bin/bash

# to easily update your Repo with his parent

YourGitRepo=""
ParentGitRepo=""

git clone ${YourGitRepo:-$1}
cd  "$(\ls -1dt ./*/ | head -n 1)"
git remote add upstream ${ParentGitRepo:-$2}
git fetch upstream
git rebase upstream/master
git push origin master --force
