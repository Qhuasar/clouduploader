#!/bin/bash
help_menu (){
    echo "Upload a file to your Azure blob"
    echo "Usage: [options] -f FILEPATH -n FILENAME"
    echo "-c     Set Container Name"
    echo "-s     Set Storage Acount"
    echo "Note: Configurations only persist for the lifetime of the current shell"
}

c_name=""
storage_acc=""
f_name=""
f_path=""

while getopts ":c:s:hn:f:" flag; do
    case $flag in
        h) 
        help_menu
        exit 0
        ;;
        f)
        f_path=$OPTARG
        if [ ! -f "$f_path" ]; then
            echo "Invalid Path: Couldn't find any file at $f_path"
            exit 1
        fi
        ;;
        c)
        c_name=$OPTARG
        export CONTAINER_NAME="$c_name"
        
        ;;
        s)
        storage_acc=$OPTARG
        export STORAGE_ACC="$storage_acc"
        ;;
        n)
        f_name=$OPTARG
        ;;
        :)
        echo "Option -${OPTARG} requires an argument."
        exit 1
        ;;
        ?)
        echo "Invalild Flag"
        help_menu
        exit 1
        ;;
    esac
done

if [ -z $f_name ] || [ -z $f_path ]; then
    echo "Missing path or file name"
    help_menu
    exit 1
fi


az ad signed-in-user show > /dev/null
if [ $? -ne 0 ]; then
    az login 
    if [ $? -ne 0 ]; then
        echo "Something went wrong authenticating user"
        exit 1
    fi
fi

if [ ! -v STORAGE_ACC ] || [ -z STORAGE_ACC ]; then
    echo "Storage Account not set. Check -h for more information"
    exit 1
fi
if [ ! -v CONTAINER_NAME ] || [ -z CONTAINER_NAME ]; then
    echo "Container name not set. Check -h for more information"
    exit 1
fi

az storage blob upload \
    --account-name "$storage_acc" \
    --container-name "$c_name" \
    --name "$f_name" \
    --file "$f_path" \
    --auth-mode login
if [ $? -ne 0 ]; then
    echo "Something went wrong uploading the file"
    exit 1
else 
    echo "Sucessfuly Uploaded $f_name "
fi
