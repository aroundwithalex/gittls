#! /bin/bash

COMMAND="${1#-}"
COMMAND="${COMMAND#-}"

function dir_exists() {
    # Checks to see if a directory argument has been specified
    # and if the directory exists.
    if [[ -z $1 ]]; then
        printf "$(tput setaf 1)\nPlease specify a target directory\n"
        exit 1
    elif [[ ! -d $1 ]]; then
        printf "$(tput setaf 1)\nDirectory $1 does not exist\n"
        exit 1
    fi
}

function parse_args() {
    # Parses arguments into an array that can then be indexed. Ignores
    # the first argument, which is the command, and the last argument
    # which is the expected number of arguments. Handles the names of
    # arguments (e.g., --arg) by doubling the expected number of args
    # and stepping through two at a time.
    MIN_ARGS=${!#}
    MAX_ARGS=$(( MIN_ARGS * 2 ))

    # First arg is going to be the
    # command. Ignore.
    shift
    args=("$@")

    # Last arg is the expected argument
    # count. Remove.
    unset 'args[-1]'

    COUNT=${#args[@]}

    if (( $COUNT == $MIN_ARGS  )); then
        for arg in "${args[@]}"; do
            parsed_args+=("$arg")
        done
    elif (( $COUNT == $MAX_ARGS )); then
        for i in $(seq 1 2 "$MAX_ARGS"); do
            parsed_args+=("${args[i]}")
        done
    else
        printf "$(tput setaf 1)\nIllegal number of arguments supplied.\n"
        printf "$(tput setaf 1)\nExpected $MIN_ARGS or $MAX_ARGS args, got $COUNT\n"
        exit 1
    fi
}

function brancher() {
    # Calls the brancher script and passes in command line args
    # such as the name of the branch, the target directory and
    # the default branch.
    NAME=$1
    TARGET_DIR=$2
    DEFAULT_BRANCH=$3

    if [[ -z "$NAME" ]]; then
        printf "$(tput setaf 1) Please specify branch name."
        exit 1
    fi

    dir_exists $TARGET_DIR

    if [[ -z "$DEFAULT_BRANCH" ]]; then
        DEFAULT_BRANCH="main"
    fi

    $(pwd)/tools/brancher.sh $NAME $TARGET_DIR $DEFAULT_BRANCH

}

function cloner() {
    # Calls the cloner script and passes in command line args, such
    # as the target directory and (optionally) an organisation.
    TARGET_DIR=$1
    ORG=$2
    source $(pwd)/tools/cloner.sh $TARGET_DIR $ORG
}

function config() {
    # Calls the config script and passes in command line args, such as
    # the email address and name of the user.
    EMAIL=$1
    NAME=$2
    source $(pwd)/tools/config.sh $EMAIL $NAME
}

function ssh_adder() {
    # Calls the SSH adder script.
    source $(pwd)/tools/ssh_adder.sh
}

function pull() {
    # Calls the puller script and passes in command line arguments such
    # as the target branch and the target directory.
    TARGET_BRANCH=$1
    TARGET_DIR=$2
    source $(pwd)/tools/puller.sh $TARGET_BRANCH $TARGET_DIR
}

function push() {
    # Calls the pusher script and passes in command line arguments such
    # as the target branch and the target directory.
    TARGET_BRANCH=$1
    TARGET_DIR=$2
    source $(pwd)/tools/pusher.sh $TARGET_BRANCH $TARGET_DIR
}

function show_help() {
    # Shows the help menu.
    source $(pwd)/help.sh
}

INSTALL_PATH=~/.local/share/gittls

declare -a parsed_args

case $COMMAND in
    'branch')
        parse_args "$@" 3
        brancher "${parsed_args[0]}" "${parsed_args[1]}" "${parsed_args[2]}"
        ;;
    'clone')
        parse_args "$@" 1
        cloner "${parsed_args[0]}"
        ;;  
    'config')
        parse_args "$@" 2
        config "${parsed_args[0]}" "${parsed_args[1]}"
        ;;
    'ssh-adder')
        ssh_adder
        ;;  
    'pull')
        parse_args "$@" 2
        pull "${parsed_args[0]}" "${parsed_args[1]}"
        ;;
    'push')
        parse_args "$@" 2
        push "${parsed_args[0]}" "${parsed_args[1]}"
        ;;
    *)
        show_help
        ;;
esac
