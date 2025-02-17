#!/bin/bash

if command -v git &> /dev/null; then
    printf "$(tput setaf 1)\ngit is not installed\n"
    printf "$(tput setaf 1)\nPlease install and try again\n"
    exit 1
fi

git clone 