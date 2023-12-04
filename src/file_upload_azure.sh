#!/bin/bash
help_menu (){
    echo "
    Wrong amount of arguments
    Usage: <azure password> <azure username> <container name> <storage-account> <file name> <file path>"
}

if [ "$#" -gt 7 ] || [ "$#" -le 1 ]; then
    help_menu
    exit 1
else
    az_pw="$1"
    az_usr="$2"
    c_name="$3"
    storage_acc="$4"
    f_name="$5"
    f_path="$6"
    if [ -f "$f_path" ]; then
        az login -u "$az_usr" -p "$az_pw"
        if [ $? -ne 0 ]; then
            echo "Something went wrong authenticating user: $az_usr with password: $az_pw"
            exit 1
        else
            az storage blob upload \
            --account-name "$storage_acc" \
            --container-name "$c_name" \
            --name "$f_name" \
            --file "$f_path" \
            --aut-mode login
            if [ $? -ne 0 ]; then
                echo "Something went wrong authenticating user: $az_usr with password: $az_pw"
                exit 1
            else 
                echo "Sucessfuly Uploaded $f_name "
            fi
        
        fi
    else
        echo "Invalid Path: Couldn't find any file at $f_path"
        exit 1
    fi
fi