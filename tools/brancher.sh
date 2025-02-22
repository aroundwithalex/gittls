#!/bin/bash

# Creates a new branch within all of the git
# repositories in a given directory.

function unstash_changes() {
    # Unstashes changes within the given directory

    PREV_BRANCH=$1
    if [ -z $PREV_BRANCH ]; then
        printf "$(tput setaf 1)\nBranch name was not specified\n"
        exit 1
    fi

    if ! git checkout $PREV_BRANCH &>/dev/null; then
        printf "$(tput setaf 3)\nUnable to checkout $PREV_BRANCH\n"
        printf "$(tput setaf 3)\nContinuing\n"
    elif ! git stash pop &>/dev/null; then
        printf "$(tput setaf 3)\nUnable to unstash commits on $PREV_BRANCH in $repo"
        printf "$(tput setaf 3)\nContinuing\n"
    else
        printf "$(tput setaf 2)\nChecked out $PREV_BRANCH and unstashed changes\n"
    fi
}

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
fi

for repo in $TARGET_DIR/*/; do
    cd $repo

    if [ ! -d .git ]; then
        printf "$(tput setaf 3)\n$repo is not a git repository\n"
        printf "$(tput setaf 3)\nContinuing\n"
        continue
    fi

    HAS_CHANGES=$(git status --porcelain)
    PREV_BRANCH=$(git branch --show-current)

    if [[ -n $HAS_CHANGES ]]; then
        if git stash --all &>/dev/null; then
            printf "$(tput setaf 2)\nStashed changes in $repo\n"
        else
            printf "$(tput setaf 3)\nUnable to stash changes in $repo\n"
            printf "$(tput setaf 3)\nContinuing\n"
            continue
        fi
    fi

    if git checkout $DEFAULT_BRANCH &>/dev/null; then
        printf "$(tput setaf 2)\nChecked out $DEFAULT_BRANCH\n"
    else
        printf "$(tput setaf 3)\nUnable to checkout $DEFAULT_BRANCH\n"
        printf "$(tput setaf 3)\nContinuing\n"
        unstash_changes $PREV_BRANCH
        continue
    fi

    if git checkout -b $BRANCH_NAME; then
        printf "$(tput setaf 2)\nCreated and checked out $BRANCH_NAME\n"
    else
        printf "$(tput setaf 3)\nUnable to create $BRANCH_NAME branch in $repo\n"
        unstash_changes $PREV_BRANCH
        continue
    fi

    if [[ -n $HAS_CHANGES ]]; then
        unstash_changes $PREV_BRANCH
    fi
done
