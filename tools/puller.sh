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

    printf "$(tput setaf 2)\nPulling $repo\n"

    if [ ! -d .git ]; then
        printf "$(tput setaf 1)\n$repo is not a git repository\n"
        printf "$(tput setaf 1)\nContinuing\n"
        continue
    fi

    HAS_CHANGES=$(git status --porcelain)
    PREV_BRANCH=$(git branch --show-current)

    if [ -n "$HAS_CHANGES" ] && git -C $repo stash; then
        printf "$(tput setaf 2)\nStashed changes\n"
    else
        printf "$(tput setaf 1)\nUnable to stash changes in $repo\n"
        printf "$(tput setaf 1)\nContinuing\n"
        continue
    fi

    if ! git -C $repo checkout $TARGET_BRANCH; then
        printf "$(tput setaf 1)\nUnable to checkout $TARGET_BRANCH for $repo\n"
        printf "$(tput setaf 1)\nContinuing\n"
        continue
    fi

    if ! git -C $repo pull; then
        printf "$(tput setaf 1)\nUnable to pull $TARGET_BRANCH for $repo\n"
        printf "$(tput setaf 1)\nContinuing\n"
        continue
    fi

    if [ -n "$HAS_CHANGES" ]; then
        git checkout -q $PREV_BRANCH

        if git -C $repo stash pop; then
            printf "$(tput setaf 2)\nUnstashed changes\n"
        else
            printf "$(tput setaf 1)\nUnable to unstash changes\n"
            printf "$(tput setaf 1)\nContinuing\n"
            continue
        fi
    fi

done
