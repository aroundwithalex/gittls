#!/bin/bash

# Creates configuration variables within
# git that sets up a basic configuration.

EMAIL_ADDRESS=$1
NAME=$2

git config set --global user.email $EMAIL_ADDRESS
git config set --global user.name $NAME
git config set --global push.autoSetupRemote true
git config set --global pull.rebase true