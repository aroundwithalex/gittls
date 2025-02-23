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
        printf "$(tput setaf 3)\n$repo is not a git repository\n"
        printf "$(tput setaf 3)\nContinuing\n"
        continue
    fi

    if ! git remote &>/dev/null; then
        printf "$(tput setaf 3)\n$repo does not have a remote repository\n"
        printf "$(tput setaf 3)\nPlease set one up before continuing\n"
        continue
    fi

    if ! git rev-parse --abbrev-ref @{upstream} &>/dev/null; then
        printf "$(tput setaf 3)\n$repo does not have an upstream branc\n"
        printf "$(tput setaf 3)\nMoving on to the next repo\n"
    fi

    HAS_CHANGES=$(git status --porcelain)
    PREV_BRANCH=$(git branch --show-current)

    if [[ -n "$HAS_CHANGES" ]]; then
        if git stash --all &>/dev/null; then
            printf "$(tput setaf 2)\nStashed changes in $repo\n"
        else
            printf "$(tput setaf 3)\nUnable to stash changes in $repo\n"
            printf "$(tput setaf 3)\nTo prevent losing work, continuing\n"
            continue
        fi
    fi

    if ! git checkout $TARGET_BRANCH &>/dev/null; then
        printf "$(tput setaf 3)\nUnable to checkout $TARGET_BRANCH for $repo\n"
        printf "$(tput setaf 3)\nContinuing\n"
        continue
    fi

    if ! git pull; then
        printf "$(tput setaf 3)\nUnable to pull $TARGET_BRANCH for $repo\n"
        printf "$(tput setaf 3)\nContinuing\n"
        continue
    fi

    if [[ -n "$HAS_CHANGES" ]]; then
        
        if ! git checkout $PREV_BRANCH &>/dev/null; then
            printf "$(tput setaf 3)\nUnable to checkout $PREV_BRANCH in $repo\n"
            printf "$(tput setaf 3)\nContinuing\n"
            continue
        elif ! git stash pop &>/dev/null; then
            printf "$(tput setaf 3)\nUnable to unstash changes in $repo\n"
            printf "$(tput setaf 3)\nContinuing\n"
            continue
        else
            printf "$(tput setaf 2)\nReapplied changes on $PREV_BRANCH in $repo\n"
        fi
    fi

done
