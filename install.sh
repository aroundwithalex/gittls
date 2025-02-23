#!/bin/bash

if ! command -v git &> /dev/null; then
    printf "$(tput setaf 1)\ngit is not installed\n"
    printf "$(tput setaf 1)\nPlease install and try again\n"
    exit 1
fi

cd ~/.local/share

# Remove existing installation
if [ -d gittls ]; then
    read -p "$(tput setaf 3)Existing gittls installation found. Replace? [y/N] " ACTION

    if [[ "$ACTION" =~ ^(y|Y)$ ]]; then
        sudo rm -rf ~/.local/share/gittls
    else
        printf "$(tput setaf 2)\nPlease update for the latest changes\n"
        exit 0
    fi
fi

printf "$(tput setaf 2)\nInstalling gittls\n"

git clone https://github.com/aroundwithalex/gittls.git --single-branch &> /dev/null

SHELL=$(echo $SHELL | rev | cut -d '/' -f1 | rev)

SHELL_PATH=''
case $SHELL in
    'bash')
        SHELL_PATH=~/.bashrc
        ;;
    'zsh')
        SHELL_PATH=~/.zshrc
        ;;
    'fish')
        SHELL_PATH=~/.config/fish/config.fish
        ;;
    *)
        printf "$(tput setaf 1)\nUnrecognised shell: $SHELL\n"
        exit 1
esac

echo "alias gittls='~/.local/share/gittls/run.sh'" >> $SHELL_PATH

printf "$(tput setaf 2)\ngittls successfully installed\n"
printf "$(tput setaf 2)\nPlease restart your shell\n"