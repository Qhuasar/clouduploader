#!/bin/bash

export DEFAULT_DIRECTORY_PATH="/etc/clouduploader"
export USERNAME=$(whoami)
export CLOUDUPLOADER_PATH=$(pwd)

read -p "This installation will reset your terminal. Do you wish to proceed? yes/[no]" quit_install

if [ $quit_install = "y" ] || [ $quit_install = "yes" ] || [ $quit_install = "Yes" ]; then 
    if [[ ! -d "$DEFAULT_DIRECTORY_PATH" ]]; then
        sudo mkdir "$DEFAULT_DIRECTORY_PATH"
        sudo chown "$USERNAME":"$USERNAME" "$DEFAULT_DIRECTORY_PATH"
    fi
    echo "export PATH=\"$CLOUDUPLOADER_PATH/src:"'$PATH"' >> ~/.bashrc
    source ~/.bashrc
    echo "Installaiton completed with success"
else 
    echo "Installaiton canceled"
    exit 0
fi