#! /bin/bash

COMMAND="${1#-}"
COMMAND="${COMMAND#-}"

if [[ $COMMAND == "branch" ]]; then
    NAME=$2

    if [[ -z "$NAME" ]]; then
        printf "$(tput setaf 1) Please specify branch name."
        exit 1
    fi

    TARGET_DIR=$4

    dir_exists $TARGET_DIR

    DEFAULT_BRANCH=$6

    if [[ -z "$DEFAULT_BRANCH" ]]; then
        DEFAULT_BRANCH="main"
    fi

    $(pwd)/tools/brancher.sh $NAME $TARGET_DIR $DEFAULT_BRANCH
elif [[ $COMMAND == "clone" ]]; then
    $(pwd)/tools/cloner.sh
fi

function dir_exists() {
    if [[ -z $1 ]]; then
        printf "$(tput setaf 1)\nPlease specify a target directory\n"
        exit 1
    elif [[ ! -d $1 ]]; then
        printf "$(tput setaf 1)\n$1 does not exist\n"
        exit 1
    fi
}
