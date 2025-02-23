#!/bin/bash

# Uninstalls and removes gittls from a machine

function remove_alias() {
    SHELL_PATH=''
    SHELL_NAME=$(echo $SHELL | rev | cut -d '/' -f1 | rev)

    if [ "$SHELL_NAME" == "bash" ]; then
        SHELL_PATH=~/.bashrc
    elif [ "$SHELL_NAME" == "zsh" ]; then
        SHELL_PATH=~/.zshrc
    elif [ "$SHELL_NAME" == "fish" ]; then
        SHELL_PATH=~/.config/fish/config.fish
    else
        printf "$(tput setaf 1)\nUnable to determine shell\n"
        exit 1
    fi

    if [ ! -f $SHELL_PATH ]; then
        printf "$(tput setaf 3)\n$SHELL_PATH does not exist\n"
        printf "$(tput setaf 3)\nNothing to do\n"
        exit 1
    fi

    sed -i.bak '/alias gittls=/d' "$SHELL_PATH"
}

if [ ! -d ~/.local/share/gittls ]; then
    printf "$(tput setaf 3)\ngittls is not installed on this machine\n"
    printf "$(tput setaf 3)\nExiting"
    exit 1
fi

read -p "$(tput setaf 3)Are you sure you want to uninstall gittls? [y/N] " ACTION

if [[ "$ACTION" =~ ^(y|Y)$ ]]; then
    printf "$(tput setaf 3)\nUninstalling gittls\n"
    sudo rm -rf ~/.local/share/gittls
    remove_alias
    printf "$(tput setaf 3)\ngittls successfully uninstalled\n"
else
    printf "$(tput setaf 2)\nPlease update for the latest changes.\n"
    exit 0
fi