#!/bin/bash

# Updates gittls with the latest changes on master

if [[ -n $(git status --porcelain ) ]]; then

    if ! git stash --all &>/dev/null; then
        printf "$(tput setaf 1)\nUnable to stash local changes\n"
        printf "$(tput setaf 1)\nPlease reinstall\n"
        exit 1
    fi
fi

if ! git checkout main &>/dev/null; then
    printf "$(tput setaf 1)\nUnable to checkout main branch\n"
    printf "$(tput setaf 1)\nPlease reinstall\n"
    exit 1
fi

if ! git pull &>/dev/null; then
    printf "$(tput setaf 1)\nUnable to update gittls\n"
    printf "$(tput setaf 1)\nPlease re-install\n"
    exit 1
fi

printf "$(tput setaf 2)\ngittls successfully updated\n"