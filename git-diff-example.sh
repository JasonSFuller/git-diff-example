#!/bin/bash

# Pre-flight checks
function error { echo "ERROR: $*" >&2; exit 1; }
if [[ -d ~/src/git-diff-example/test ]]; then
  rm -rf ~/src/git-diff-example/test
fi
mkdir -p ~/src/git-diff-example/test
cd "$_" || error "could not change into dir"

# Create a new local repo and rename the default branch from 'master' to 'main.'
# NOTE:  This work-around is for older versions of git.  For newer versions (git
#   2.28+, released Jul 27 2020), you can set the default branch as 'main' in
#   your global config:
#     git config --global init.defaultBranch main
#   Git 2.28.0 release info:
#     https://lore.kernel.org/git/xmqq5za8hpir.fsf@gitster.c.googlers.com/
git init
git branch -m main
git symbolic-ref HEAD refs/heads/main

# Just in case you're on a box where there defaults haven't been set, set the
# required git variables and make them local to this repo only.
git config user.name "Example"
git config user.email "user@example.com"

# create node A
date '+content file A -- %F %T.%N%z' > file_A.txt
git add file_A.txt
git commit -m 'adding A'
git tag A

# create a new branch
git branch -avv
git checkout -b working main

# make a new commit
date '+content example 1 -- %F %T.%N%z' > file_example1.txt
git add file_example1.txt
git commit -m 'adding example1'

# create node C
date '+content file C -- %F %T.%N%z' > file_C.txt
git add file_C.txt
git commit -m 'adding C'
git tag C

# examine branch history
git log

# checkout main branch to begin making new changes
git checkout main

# make two new commits
date '+content example 2 -- %F %T.%N%z' > file_example2.txt
git add file_example2.txt
git commit -m 'adding example2'
date '+content example 3 -- %F %T.%N%z' > file_example3.txt
ate -Ins > file_example3.txt
git add file_example3.txt
git commit -m 'adding example3'

# create node C
date '+content file B -- %F %T.%N%z' > file_B.txt
git add file_B.txt
git commit -m 'adding B'
git tag B

# examine the main branch's history
git log

# record the various 'git diff' variations (default, 2-dot, 3-dot, etc)
git diff B C   > diff-B-space-C.txt
git diff B..C  > diff-B-2dot-C.txt
git checkout working
git diff B > diff-B-from-main.txt
git checkout main
git diff C > diff-C-from-working.txt

git diff B...C > diff-B-3dot-C.txt


# and show the differences (with color)
echo '--- git diff B C # default ----------------------------------------------'
git diff --color B C

echo '--- git diff B..C # 2dot ------------------------------------------------'
git diff --color B..C

echo '--- git diff B...C # 3dot -----------------------------------------------'
git diff --color B...C

echo '--- diff of 2-dot output and the default --------------------------------'
diff --unified --report-identical-files --color \
  diff-B-2dot-C.txt \
  diff-B-space-C.txt

echo '--- diff of 2-dot output and B (from the main branch) -------------------'
diff --unified --report-identical-files --color \
  diff-B-2dot-C.txt \
  diff-B-from-main.txt

echo '--- diff of 2-dot output and C (from the working branch) ----------------'
diff --unified --report-identical-files --color \
  diff-B-2dot-C.txt \
  diff-C-from-working.txt

