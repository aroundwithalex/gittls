#! /bin/bash

COMMAND="${1#-}"
COMMAND="${COMMAND#-}"

function dir_exists() {
    if [[ -z $1 ]]; then
        printf "$(tput setaf 1)\nPlease specify a target directory\n"
        exit 1
    elif [[ ! -d $1 ]]; then
        printf "$(tput setaf 1)\n$1 does not exist\n"
        exit 1
    fi
}

if [[ $COMMAND == "branch" ]]; then

    if [ $# -eq 4 ]; then
        NAME=$2
        TARGET_DIR=$3
        DEFAULT_BRANCH=$4
    elif [ $# -eq 6 ]; then
        NAME=$2
        TARGET_DIR=$4
        DEFAULT_BRANCH=$6   
    else
        printf "$(tput setaf 1)\nIllegal number of arguments\n"
        printf "$(tput setaf 1)\nTypical Usage:\n"
        printf "$(tput setaf 1)\n\tgittls --branch test-branch /target/dir main\n\n"
        exit 1
    fi

    if [[ -z "$NAME" ]]; then
        printf "$(tput setaf 1) Please specify branch name."
        exit 1
    fi

    dir_exists $TARGET_DIR

    if [[ -z "$DEFAULT_BRANCH" ]]; then
        DEFAULT_BRANCH="main"
    fi

    $(pwd)/tools/brancher.sh $NAME $TARGET_DIR $DEFAULT_BRANCH
elif [[ $COMMAND == "clone" ]]; then
    $(pwd)/tools/cloner.sh
fi
