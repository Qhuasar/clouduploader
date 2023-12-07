#!/bin/bash

export CONFIG_DEFAULT_PATH="/etc/clouduploader/clouduploader.config"
help_menu (){
    echo "Upload a file to your Azure blob"
    echo "Usage: [options] -f FILEPATH -n FILENAME"
    echo "-c     Set Container Name"
    echo "-s     Set Storage Acount"
    echo "-a     Set a configuration path"
    echo "Configurations are saved by default at /etc/clouduploader/clouduploader.config"
}

f_name=""
f_path=""
#if look_for_config = 2 it prevents the script from prompting about  the config file"
look_for_config=0
while getopts ":c:s:hn:f:a:" flag; do
    case $flag in
        h) 
        help_menu
        exit 0
        ;;
        a)
        export CONFIG_DEFAULT_PATH=$OPTARG
        ;;
        f)
        f_path=$OPTARG
        if [ ! -f "$f_path" ]; then
            echo "Invalid Path: Couldn't find any file at $f_path"
            exit 1
        fi
        ;;
        c)
        ((look_for_config++))
        export CONTAINER_NAME=$OPTARG
        ;;
        s)
        export STORAGE_ACC=$OPTARG
        ((look_for_config++))
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

#Checks if user is logged in, if they are not tries to open a login prompt
az ad signed-in-user show > /dev/null
if [ $? -ne 0 ]; then
    az login 
    if [ $? -ne 0 ]; then
        echo "Something went wrong authenticating user"
        exit 1
    fi
fi

#checks if a file exists at the CONFIG_DEFAULT_PATH 
echo "$look_for_config"
if [ ! -f "$CONFIG_DEFAULT_PATH" ] && [[  "$look_for_config" < 2 ]]; then
    echo "No valid config file found at $CONFIG_DEFAULT_PATH. Do you wish to create one?"
    read -p "[Yes]/No: " create_config
    if [ "$create_config" = "y" ] || [ "$create_config" = "Yes" ] || [ "$create_config" = "yes" ]; then
        read -p "Container Name: " cont_name
        echo "container_name=$cont_name" > "$CONFIG_DEFAULT_PATH"
        read -p "Storage Account Name: " storage_account_name
        echo "storage_account_name=$storage_account_name" >> "$CONFIG_DEFAULT_PATH"
    else
        exit 1
    fi
fi

#checks if STORAGE_ACC is already set, if not it trys to get it from the config file
if [ ! -v STORAGE_ACC ] || [ -z STORAGE_ACC ]; then
    while IFS='=' read -r key value; do
        case $key in
            container_name)
            ;;
            storage_account_name) 
            export STORAGE_ACC="$value" 
            ;;
            ?) 
            echo "Invalid key: $key is not a valid configuration option"
            exit 1
            ;;
        esac
    done < "$CONFIG_DEFAULT_PATH"
fi

#checks if CONTAINER_NAME is already set, if not it trys to get it from the config file
if [ ! -v CONTAINER_NAME ] || [ -z CONTAINER_NAME ]; then
    while IFS='=' read -r key value; do
        case $key in
            storage_account_name)
            ;;
            container_name)  
            export CONTAINER_NAME="$value" 
            ;;
            *) 
            echo "Invalid key: $key is not a valid configuration option"
            exit 1
            ;;
        esac
    done < "$CONFIG_DEFAULT_PATH"
fi
echo "$CONFIG_DEFAULT_PATH"
if [ ! -v STORAGE_ACC ] || [ -z STORAGE_ACC ]; then
    echo "Storage Account not set. Check -h for more information"
    exit 1
fi
if [ ! -v CONTAINER_NAME ] || [ -z CONTAINER_NAME ]; then
    echo "Container name not set. Check -h for more information"
    exit 1
fi
az storage blob upload \
    --account-name "$STORAGE_ACC" \
    --container-name "$CONTAINER_NAME" \
    --name "$f_name" \
    --file "$f_path" \
    --auth-mode login
if [ $? -ne 0 ]; then
    echo "Error: Something went wrong uploading the file check your config file"
    exit 1
else 
    echo "Sucessfuly Uploaded $f_name "
fi
