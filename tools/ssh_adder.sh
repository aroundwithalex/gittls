#!/bin/bash

# Creates and adds an SSH key to GitHub by creating
# it locally and then pushing it.

function create_linux_ssh_key() {
    ssh-add ~/.ssh/id_ed25519
}

function create_mac_ssh_key() {
    if [ ! -f ~/.ssh/config ]; then
        touch ~/.ssh/config
    fi

    echo "Host github.com" >> ~/.ssh/config
    echo "  AddKeysToAgent yes" >> ~/.ssh/config
    echo "  UseKeychain yes" >> ~/.ssh/config
    echo "  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config

    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
}

declare -a FILES=("id_rsa.pub" "id_ecdsa.pub" "id_ed25519.pub")

KEY_EXISTS=false

cd ~/.ssh
for file in "${FILES[@]}"; do

    if [ -f $file ]; then
        KEY_EXISTS=true
    fi
done

if [ "$KEY_EXISTS" == "true" ]; then

    printf "$(tput setaf 3)\nA GitHub SSH key already exists.\n"
    printf "$(tput setf 3)\nContinuing could overwrite this key.\n\n"
    read -p "$(tput setaf 3)Continue? [y/N] " CONFIRM

    if [[ ! "$CONFIRM" =~ ^(y|Y)$ ]]; then
        exit 1
    fi
fi

printf "\n"
read -p "$(tput setaf 2)Enter your email: " EMAIL
ssh-keygen -t ed25519 -C $EMAIL

printf "$(tput setaf 2)\nAdding to local SSH\n"

eval "$(ssh-agent -s)"

OS=$(uname)

if [ "$OS" == "Linux" ]; then
    create_linux_ssh_key
elif [ "$OS" == "Darwin" ]; then
    create_mac_ssh_key
fi

read -p "$(tput setaf 2)Enter name for key (blank for default): " NAME

if [ -z $NAME ]; then
    NAME="$OS GitHub SSH Key"
fi 

gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication --title "$NAME"

printf "$(tput setaf 2)\nTesting SSH connection\n"
ssh -T git@github.com
