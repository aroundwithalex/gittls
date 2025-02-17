#!/bin/bash

# Automatically clones all public, private
# and forked libraries using the GitHub CLI.

set -e

if ! command -v gh &> /dev/null; then
    printf "$(tput setaf 2)\n Please install the GitHub CLI\n"
    printf "$(tput setaf 2)\n You will also need to login with the CLI\n"
    exit 1
fi

function get_gh_repos() {
    # Lists repositories on GitHub by visibility. Note that the
    # GitHub CLI only supports public, private and internal as
    # arguments.

    if [ -z $2 ]; then
        echo $(gh repo list --visibility $1 --json name --jq '.[].name')
    else
        echo $(gh repo list $2 --visibility $1 --json name --jq '.[].name')
    fi
}

function clone_or_pull() {
    # Clones or pulls a repository from GitHub depending on
    # whether it already exists at the target_dir path.

    TARGET_DIR=$1
    REPO_NAME=$2

    REPO_PATH=$TARGET_DIR/$REPO_NAME

    if [ ! -d $REPO_PATH ]; then
        printf "$(tput setaf 2)\nCloning $REPO_NAME to $REPO_PATH\n"
        gh repo clone $repo $REPO_PATH
    else
        cd $REPO_PATH

        DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin | cut -d '/' -f2)

        printf "$(tput setaf 2)\n$REPO_NAME already exists. Updating...\n"

        PREV_BRANCH=''

        if [ ! $(git branch --show-current) == $DEFAULT_BRANCH ]; then
            PREV_BRANCH=$(git branch --show-current)

            if [[ -n $(git status --porcelain) ]] ; then
                git stash
            fi

            git checkout $DEFAULT_BRANCH
        fi

        git pull

        if [ -n "$PREV_BRANCH" ]; then
            git checkout $PREV_BRANCH
            git stash pop
        fi
    fi

}

ORG_NAME=''

PRIVATE_DIR=~/Development/Private
mkdir -p $PRIVATE_DIR
for repo in $(get_gh_repos "private" $ORG_NAME); do
    clone_or_pull $PRIVATE_DIR $repo
done

PUBLIC_DIR=~/Development/Public
mkdir -p $PUBLIC_DIR
for repo in $(get_gh_repos "public" $ORG_NAME); do
    clone_or_pull $PUBLIC_DIR $repo
done

#TODO: Create a path generator
FORK_DIR=~/Development/Forks
mkdir -p $FORK_DIR
for repo in $(gh repo list --fork $ORG_NAME); do
    clone_or_pull $FORK_DIR $repo
done

ARCHIVE_DIR=~/Development/Archive
mkdir -p $ARCHIVE_DIR
for repo in $(gh repo list --archived $ORG_NAME); do
    clone_or_pull $ARCHIVE_DIR $repo
done