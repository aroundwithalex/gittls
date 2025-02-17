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

INSTALL_PATH=~/.local/share/gittls

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

    $INSTALL_PATH/tools/brancher.sh $NAME $TARGET_DIR $DEFAULT_BRANCH
elif [[ $COMMAND == "clone" ]]; then
    source $INSTALL_PATH/tools/cloner.sh
elif [[ $COMMAND == "help" ]]; then 
    source $INSTALL_PATH/tools/help.sh
elif [[ $COMMAND == "config" ]]; then
    if [ $# -eq 3 ]; then
        EMAIL=$2
        NAME=$3
    elif [ $# -eq 5 ]; then
        EMAIL=$3
        NAME=$5
    else
        printf "$(tput setaf 1)\nIllegal number of arguments\n"
        printf "$(tput setaf 1)\nTypical Usage:\n"
        printf "$(tput setaf 1)\n\tgittls --config email@address \"Your Name\"\n\n"
        exit 1
    fi

    source $INSTALL_PATH/tools/config.sh $EMAIL $NAME
fi
