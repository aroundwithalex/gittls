#!/bin/bash

# Creates a new branch within all of the git
# repositories in a given directory.

BRANCH_NAME=$1
TARGET_DIR=$2
DEFAULT_BRANCH=$3

for repo in $TARGET_DIR/*/; do
    cd $repo

    if [[ -n $(git status --porcelain) ]]; then
        git stash
    fi

    if [[ $DEFAULT_BRANCH != $(git branch --show-current) ]]; then
        git checkout $DEFAULT_BRANCH
    fi

    git checkout -b $BRANCH_NAME

done
