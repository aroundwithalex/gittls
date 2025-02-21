#!/bin/bash

# Creates a new branch within all of the git
# repositories in a given directory.

BRANCH_NAME=$1
TARGET_DIR=$2
DEFAULT_BRANCH=$3

if [ -z "$BRANCH_NAME" ]; then
    printf "$(tput setaf 1)\nPlease specify branch name\n"
fi

if [ -z "$TARGET_DIR" ]; then
    printf "$(tput setaf 1)\nPlease specify target directory\n"
    exit 1
elif [ ! -d "$TARGET_DIR" ]; then
    printf "$(tput setaf 1)\n$TARGET_DIR does not exist\n"
    exit 1
fi

if [ -z "$DEFAULT_BRANCH" ]; then
    printf "$(tput setaf 3)\nNo default branch specified\n"
    printf "$(tput setaf 3)\nAssuming main\n"
    DEFAULT_BRANCH="main"

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
