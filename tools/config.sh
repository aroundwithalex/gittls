#!/bin/bash

# Creates configuration variables within
# git that sets up a basic configuration.

EMAIL_ADDRESS=$1
FIRST=$2
LAST=$3

if [ -z "$EMAIL_ADDRESS" ]; then
    printf "$(tput setaf 1)\nPlease specify your email address\n"
    exit 1
elif [ -z "$FIRST" ]; then
    printf "$(tput setaf 1)\nPlease specify your first name\n"
    exit 1
elif [ -z "$LAST" ]; then
    printf "$(tput setaf 1)\nPlease specify your last name\n"
    exit 1
fi

git config set --global user.email "$EMAIL_ADDRESS"
git config set --global user.name "$FIRST $LAST"
git config set --global push.autoSetupRemote true
git config set --global pull.rebase true