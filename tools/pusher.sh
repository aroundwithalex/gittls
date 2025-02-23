#!/bin/bash

# Goes through each directory within a target
# directory and automatically pushes a branch
# to GitHub. The name of the branch needs to 
# be provided as a command line argument.

TARGET_BRANCH=$1

if [ -z $TARGET_BRANCH ]; then
    printf "$(tput setaf 1)\nPlease supply target branch\n"
    exit 1
fi

TARGET_DIR=$2

if [ -z $TARGET_DIR ]; then
    printf "$(tput setaf 1)\nPlease supply target directory\n"
    exit 1
elif [ ! -d $TARGET_DIR ]; then
    printf "$(tput setaf 1)\n$TARGET_DIR does not exist\n"
    exit 1
fi

for repo in $TARGET_DIR/*; do

    cd $repo

    if [ ! -d .git ]; then
        printf "$(tput setaf 3)\n$repo is not a git repository\n"
        printf "$(tput setaf 3)\nContinuing\n"
        continue
    fi

    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    HAS_CHANGES=$(git status --porcelain)

    if [[ -n $HAS_CHANGES ]]; then

        if git stash &>/dev/null; then
            printf "$(tput setaf 2)\nStashed changes on $BRANCH in $repo\n"
        else
            printf "$(tput setaf 3)\nUnable to stash changes on $BRANCH in $repo\n"
            printf "$(tput setaf 3)\nTo avoid loss of work, continuing\n"
            continue
        fi
    fi

    if git checkout $TARGET_BRANCH &>/dev/null; then
        printf "$(tput setaf 2)\nChecked out $TARGET_BRANCH in $repo\n"
    else
        printf "$(tput setaf 3)\nUnable to checkout $TARGET_BRANCH in $repo\n"
        printf "$(tput setaf 3)\nContinuing"
        continue
    fi

    if ! git remote &>/dev/null; then
        printf "$(tput setaf 3)\n$repo does not have a remote repository on GitHub\n"
        printf "$(tput setaf 3)\nPlease set one up before continuing\n"
        continue
    fi

    if ! git rev-parse --abbrev-ref @{upstream} &>/dev/null; then

        if git branch --set-upstream=origin/$TARGET_DIR &>/dev/null; then
            printf "$(tput setaf 2)\nSet upstream branch for $TARGET_BRANCH"
        else
            printf "$(tput setaf 3)\nUnable to set upstream branch for $TARGET_BRANCH\n"
            printf "$(tput setaf 3)\nContinuing as cannot push to GitHub\n"
            continue
        fi
    fi

    if git push; then
        printf "$(tput setaf 2)\nPushed $BRANCH in $repo to remote repository\n"
    else
        printf "$(tput setaf 3)\nUnable to push $BRANCH in $repo to remote repository\n"
        printf "$(tput setaf 3)\nPlease examine the repo and check for issues\n"
    fi

    if [[ -n $HAS_CHANGES ]]; then

        if ! git checkout $BRANCH &>/dev/null; then
            printf "$(tput setaf 3)\nUnable to checkout $BRANCH\n"
            continue
        elif ! git stash pop &>/dev/null; then
            printf "$(tput setaf 3)\nUnable to unstash changes on $BRANCH in $repo\n"
            continue
        else
            printf "$(tput setaf 2)\nReapplied changes on $BRANCH in $repo\n"
        fi
    fi
    
done
