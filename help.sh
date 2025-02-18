#!/bin/bash

printf "$(tput setaf 2)\n gittls: A tool for using git command en-masse. \n"
printf "$(tput setaf 2)\n Commands: \n"
printf "$(tput setaf 2)\n\t gittls --branch: Creates and checks out a new branch on multiple repos.\n"
printf "$(tput setaf 2)\n\t Example Usage:\n\n\t\tgittls --branch test --target-dir /target/dir --default-branch main \n\n"
printf "$(tput setaf 2)\n\t gittls --clone: Clones or pulls multiple repositores into appropriate directories\n"
printf "$(tput setaf 2)\n\t Example Usage:\n\n\t\tgittls --clone \n\n"
printf "$(tput setaf 2)\n\t gittls --config: Add basic Git configuration data e.g., email and name.\n"
printf "$(tput setaf 2)\n\t Example Usage:\n\n\t\tgittls --config email@address \"Your Name\" \n\n"
printf "$(tput setaf 5)\n\n Usage:\n"
printf "$(tput setaf 5)\n\t $ sommelier-update \n\n"