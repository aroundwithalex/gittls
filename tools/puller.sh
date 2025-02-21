#!/bin/bash

# Pulls a given branch for all repositories within
# a given directory. Takes the target directory path
# and the branch name as arguments (defaults to main).

TARGET_BRANCH=$1

if [ -z "$TARGET_BRANCH" ]; then
    printf "$(tput setaf 1)\nPlease supply branch name\n"
    exit 1
fi

TARGET_DIR=$2

if [ -z "$TARGET_DIR" ]; then
    printf "$(tput setaf 1)\nPlease supply target directory\n"
    exit 1
elif [ ! -d "$TARGET_DIR" ]; then
    printf "$(tput setaf 1)\n $TARGET_DIR does not exist\n"
    exit 1
fi

cd $TARGET_DIR

for repo in $TARGET_DIR/*/; do

    cd $repo

    if [ ! -d .git ]; then
        printf "$(tput setaf 1)\n$repo is not a git repository\n"
        printf "$(tput setaf 1)\nContinuing\n"
        continue
    fi

    if [ $(git branch --show-current) != $TARGET_BRANCH ]; then

        if [ -z $(git status --porcelain) ]; then
            git checkout $TARGET_BRANCH
        elif ! git -C $repo stash; then
            printf "$(tput setaf 1)\nUnable to stash changes in $repo\n"
            printf "$(tput setaf 1)\nContinuing\n"
            continue
        fi

    git pull

done
