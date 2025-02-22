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

    # Args:
    #   VIS: Visibility of the repo (public, private, internal)
    #   ORG: Name of the associated organisation.

    VIS=$1
    ORG=$2

    if [ -z $2 ]; then
        echo $(gh repo list --visibility $VIS --json name --jq '.[].name')
    else
        echo $(gh repo list $ORG --visibility $VIS --json name --jq '.[].name')
    fi
}

function cloner() {
    # Clones a repository from GitHub

    REPO_PATH=$1
    REPO_NAME=$2

    printf "$(tput setaf 2)\nCloning $REPO_NAME to $REPO_PATH\n"
    gh repo clone $REPO_NAME $REPO_PATH
    return

}

function puller() {
    # Pulls a repository in case it already exists.

    REPO_PATH=$1
    REPO_NAME=$2

    cd $REPO_PATH

    printf "$(tput setaf 2)\n$REPO_NAME already exists. Updating...\n"

    DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin | cut -d '/' -f2)

    PREV_BRANCH=$(git branch --show-current)
    HAS_CHANGES=$(git status --porcelain)

    if [[ -n $HAS_CHANGES ]]; then

        if git stash --all &>/dev/null; then
            printf "$(tput setaf 2)\nStashed changes on $PREV_BRANCH in $repo\n"
        else
            printf "$(tput setaf 3)\nUnable to stash changes on $PREV_BRANCH in $repo\n"
            printf "$(tput setaf 3)\nTo avoid losing work, continuing\n"
            return
        fi
    fi

    if git checkout $DEFAULT_BRANCH &>/dev/null; then
        printf "$(tput setaf 2)\nChecked out $DEFAULT_BRANCH\n"
    else
        printf "$(tput setaf 3)\nCannot checkout $DEFAULT_BRANCH in $repo\n"
        printf "$(tput setaf 3)\nPlease look at the repo and find any issues.\n"
        return
    fi

    git pull

    if [[ -n "$HAS_CHANGES" ]]; then

        if git checkout $PREV_BRANCH &>/dev/null; then
            printf "$(tput setaf 2)\nChecked out $PREV_BRANCH in $repo\n"
        else
            printf "$(tput setaf 3)\nUnable to checkout $PREV_BRANCH in $repo\n"
            printf "$(tput setaf 3)\nCannot unstash previous changes. Continuing\n"
            return
        fi

        if git stash pop &>/dev/null; then
            printf "$(tput setaf 2)\nReapplied changes on $PREV_BRANCH in $repo\n"
        else
            printf "$(tput setaf 3)\nUnable to unstash changes on $PREV_BRANCH in $repo\n"
            printf "$(tput setaf 3)\nPlease look at the repo and find any issues.\n"
            return
        fi
    fi
}

function clone_or_pull() {
    # Clones or pulls a repository from GitHub depending on
    # whether it already exists at the target_dir path.
    # Args:
    #   TARGET_DIR: Target directory for cloning into
    #   REPO_NAME: Name of the repository

    HOME_DIR=$1
    REPO_NAME=$2

    REPO_PATH=$HOME_DIR/$REPO_NAME

    if [ ! -d $REPO_PATH ]; then
        cloner $REPO_PATH $REPO_NAME
    else
        puller $REPO_PATH $REPO_NAME
    fi
}

function make_dir() {
    # Creates a directory to hold a repository if it
    # does not already exist.
    # Args:
    #   TARGET_DIR: Target directory to make the repo in.
    #   NAME: The name of the directory

    TARGET_DIR=$1
    NAME=$2

    if [ -z $TARGET_DIR ]; then
        printf "$(tput setaf 1)\nPlease specify target directory\n"
        exit 1
    fi

    if [ -z $NAME ]; then
        printf "$(tput setaf 1)\nPlease specify directory name\n"
        exit 1
    fi

    DIR_PATH=$TARGET_DIR/$NAME

    mkdir -p $DIR_PATH

    echo $DIR_PATH
}

TARGET_DIR=$1

if [ -z "$TARGET_DIR" ]; then
    printf "$(tput setaf 1)\nPlease specify target directory\n"
    exit 1
elif [ ! -d "$TARGET_DIR" ]; then
    printf "$(tput setaf 1)\n$TARGET_DIR does not exist\n"
    exit
fi

ORG_NAME=$2

DIR_PATH=$(make_dir $TARGET_DIR "Private")
for repo in $(get_gh_repos "private" $ORG_NAME); do
    clone_or_pull $DIR_PATH $repo
done

DIR_PATH=$(make_dir $TARGET_DIR "Public")
for repo in $(get_gh_repos "public" $ORG_NAME); do
    clone_or_pull $DIR_PATH $repo
done

DIR_PATH=$(make_dir $TARGET_DIR "Forks")
for repo in $(gh repo list --fork $ORG_NAME); do
    clone_or_pull $DIR_PATH $repo
done

DIR_PATH=$(make_dir $TARGET_DIR "Archive")
for repo in $(gh repo list --archived $ORG_NAME); do
    clone_or_pull $DIR_PATH $repo
done