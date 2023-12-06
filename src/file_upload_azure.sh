#!/bin/bash
help_menu (){
    echo "
    Wrong amount of arguments
    Usage: <azure password> <azure username> <container name> <storage-account> <file name> <file path>"
}

az_pw=""
az_usr=""
c_name=""
storage_acc=""
f_name=""
f_path=""

while getopts ":a:p:c:s:h:n:f:" flag; do
 case $flag in
   h) 
   help_menu
   ;;
   a) 
   az_usr=$OPTARG
   ;;
   f)
   f_path=$OPTARG
   if [ -f "$f_path" ]; then
    echo "Invalid Path: Couldn't find any file at $f_path"
    exit 1
   fi
   ;;
   p)
   az_pw=$OPTARG
   ;;
   c)
   c_name=$OPTARG
   CONTAINER_NAME="$c_name"
   export CONTAINER_NAME
   ;;
   s)
   storage_acc=$OPTARG
   STORAGE_ACC="$storage_acc"
   export STORAGE_ACC
   ;;
   n)
   f_name=$OPTARG
   BLOB_FILE_NAME="$fname"
   export BLOB_FILE_NAME
   ;;
   :)
   echo "Option -${OPTARG} requires an argument."
   exit 1
   ;;
   ?)
   echo "Invalild Flag"
   help_menu
   ;;
 esac
done
if [ -z $f_name ] || [ -z $f_path ]; then
    echo "Missing path and file name"
    help_menu
    exit 1
fi
az ad signed-in-user show > /dev/null
if [ $? -ne 0 ]; then
    az login -u "$az_usr" -p "$az_pw"
    if [ $? -ne 0 ]; then
        echo "Something went wrong authenticating user: $az_usr with password: $az_pw"
        echo "Check the help flag for more information"
        exit 1
    fi
fi
if [ ! -v BLOB_FILE_NAME]; then
    echo "Blob file name not set. Check -h for more information"
    exit 1
fi
if [ ! -v STORAGE_ACC]; then
    echo "Storage Account not set. Check -h for more information"
    exit 1
fi
if [ ! -v CONTAINER_NAME]; then
    echo "Container name not set. Check -h for more information"
    exit 1
fi
az storage blob upload \
    --account-name "$storage_acc" \
    --container-name "$c_name" \
    --name "$f_name" \
    --file "$f_path" \
    --aut-mode login
if [ $? -ne 0 ]; then
    echo "Something went wrong uploading the file"
    exit 1
else 
    echo "Sucessfuly Uploaded $f_name "
fi
fi
