#!/bin/bash

# NOTE:  Tested on Ubuntu 20.04.4 LTS with git version 2.25.1.

# Pre-flight checks
function error { echo "ERROR: $*" >&2; exit 1; }
script=$(realpath -- "$0")
script_dir=$(dirname -- "${script}")
if [[ -z "${script_dir}" ]]; then error "script dir missing"; fi
if [[ -d "${script_dir}/test" ]]; then
  rm -rf "${script_dir}/test"
fi
mkdir -p "${script_dir}/test"
cd "$_" || error "could not change into dir"

tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Creating local git repo (./test) to examine 'git diff' output   #"
echo -e "####################################################################\n"
tput sgr0

# Create a new local repo and rename the default branch from 'master' to 'main.'
# NOTE:  This work-around is for older versions of git.  For newer versions (git
#   2.28+, released Jul 27 2020), you can set the default branch as 'main' in
#   your global config:
#     git config --global init.defaultBranch main
#   Git 2.28.0 release info:
#     https://lore.kernel.org/git/xmqq5za8hpir.fsf@gitster.c.googlers.com/
git init
# git branch -m main # for existing branches
git symbolic-ref HEAD refs/heads/main # since no commits, the branch doesn't yet exist

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
git diff B...C > diff-B-3dot-C.txt
git diff A..C  > diff-A-2dot-C.txt
git diff C..B  > diff-C-2dot-B.txt
git checkout working && git diff B > diff-B-from-working.txt
git checkout main    && git diff C > diff-C-from-main.txt

# and show the differences (with color) of the primary modes
tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Executing:  git diff B C                                        #"
echo -e "#  -- This is the CLI DEFAULT mode, which is the same as 2-dot.    #"
echo -e "####################################################################\n"
tput sgr0

git --no-pager diff --color B C

tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Executing:  git diff B..C                                       #"
echo -e "#  -- This is the 2-DOT mode (and is the same as above).           #"
echo -e "####################################################################\n"
tput sgr0

git --no-pager diff --color B..C

tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Executing:  git diff B...C                                      #"
echo -e "#  -- This is the 3-DOT mode, and the Github default for PRs.      #"
echo -e "####################################################################\n"
tput sgr0

git --no-pager diff --color B...C

# These comparisons are a little Inception-y, but they prove the point.
tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Compare output of 'git diff B..C' vs 'git diff B C'             #"
echo -e "#  -- The output should be identical.                              #"
echo -e "####################################################################\n"
tput sgr0

diff --unified --report-identical-files --color \
  diff-B-2dot-C.txt \
  diff-B-space-C.txt

tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Compare output of 'git diff B..C' vs 'git diff B' (from the     #"
echo -e "#  'working' branch)                                               #"
echo -e "#  -- The output should be identical.                              #"
echo -e "####################################################################\n"
tput sgr0

diff --unified --report-identical-files --color \
  diff-B-2dot-C.txt \
  diff-B-from-working.txt

tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Compare output of 'git diff B..C' vs 'git diff C' (from the     #"
echo -e "#  'main' branch)                                                  #"
echo -e "#  -- You might expect the output to be identical (similar to      #"
echo -e "#     above), but note 'git diff C' (from the main branch) means   #"
echo -e "#     'C..B' which is not the same as 'B..C' since changes are     #"
echo -e "#     applied in reverse, i.e. order matters.                      #"
echo -e "####################################################################\n"
tput sgr0

diff --unified --report-identical-files --color \
  diff-B-2dot-C.txt \
  diff-C-from-main.txt

tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Compare output of 'git diff C..B' vs 'git diff C' (from the     #"
echo -e "#  'main' branch)                                                  #"
echo -e "#  -- If you make the comparison again, preserving the correct     #"
echo -e "#     order of operations, the output should be identical.         #"
echo -e "####################################################################\n"
tput sgr0

diff --unified --report-identical-files --color \
  diff-C-2dot-B.txt \
  diff-C-from-main.txt

tput setaf 6
echo -e "\n####################################################################"
echo -e "#  Compare output of 'git diff B...C' vs 'git diff A..C'           #"
echo -e "#  -- 'B' 3-dot 'C' means find the last common commit between      #"
echo -e "#     these two nodes, which is 'A'.                               #"
echo -e "#  -- If 'A' is the last common commit between 'B' and 'C', then   #"
echo -e "#     'B...C' should be identical to 'A..C'.                       #"
echo -e "####################################################################\n"
tput sgr0

diff --unified --report-identical-files --color \
  diff-B-3dot-C.txt \
  diff-A-2dot-C.txt

echo
