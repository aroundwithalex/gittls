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

    if [[ -z "$TARGET_DIR" ]]; then
        printf "$(tput setaf 1) Please specify target directory."
        exit 1
    elif [[ -d "$TARGET_DIR" ]]; then
        printf "$(tput setaf 1) $TARGET_DIR does not exist."
        exit 1
    fi

    DEFAULT_BRANCH=$6

    if [[ -z "$DEFAULT_BRANCH" ]]; then
        DEFAULT_BRANCH="main"
    fi

    $(pwd)/tools/brancher.sh $NAME $TARGET_DIR $DEFAULT_BRANCH

fi