#!/bin/bash

# Uninstalls and removes gittls from a machine

if [ ! -d ~/.local/share/gittls ]; then
    printf "$(tput setaf 3)\ngittls is not installed on this machine\n"
    printf "$(tput setaf 3)\nExiting"
    exit 1
fi

read -p "Are you sure you want to uninstall gittls? [y/N] " ACTION

if [[ "$ACTION" =~ ^(y|Y)$ ]]; then
    sudo rm -rf ~/.local/share/gittls
else
    printf "$(tput setaf 2)\nPlease update for the latest changes.\n"
    exit 0
fi