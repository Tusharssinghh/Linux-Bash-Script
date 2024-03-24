#!/bin/bash

function display_help() {
    echo "Usage : internstcl"
    echo "options: "
    echo "--help Display this help and exit"
    echo "--version Output version information and exit"
}

function display_version() {
    echo "internsctl version v0.1.0" 
}

function get_cpu_info() {
    lscpu
}

function get_memory_info() {
    free
}

function create_user() {
    sudo useradd -m "$1"
}

function list_users() {
    awk -F: '$3 >= 10000 && $3 != 65534 {print $1}' /etc/passwd
}

function list_sudo_users() {
    grep -Po '^sudo.+:\K.*$' /etc/group
}
function get_file_info_no_option(){

    if [ ! -f "$1" ]; 
    then
        echo "Error: File '$1' not found."
        exit 1
    fi

    #get file info
    filename="$1"
    permissions=$(start -c "%A" "$filename")
    size=$(stat -c "%s" "$filename")
    owner=$(stat -c "%U" "$filename")
    modification=$(stat -c "%y" "$filename")

    #display file info
    echo "file : $filename"
    echo "Access : $permissions"
    echo "Size(B) : $size"
    echo "Owner : $owner"
    echo "Modify : $modification"    
}

function get_file_info() {
    #check if file exists
    if [ ! -f "$1" ];
    then    
        echo "Error : File '$1' not found."
        exit 1
    fi
    #get file info
    filename="$1"
    #checking option
    while [[ "$2" =~ ^- ]]; do
        case $2 in 
            --size|-s)
                size=$(stat -c "%s" "$filename")
                echo "Size(B): $size"
                ;;
            --permissions|-p)
                permissions=$(stat -c "%A" "$filename")
                echo "Permissions: $permissions"
                ;;
            --owner|-o)
                owner=$(stat -c "%U" "$filename")
                echo "Owner : $owner"
                ;;
            --last-modified|-m)
                last_modified=$(stat -c "%y" "$filename")
                echo "Last modified: $last_modified"
                ;;
            *)
                echo "Error : Unknown option '$2'."
                exit 1
                ;;
        esac
        shift
    done
}

#check command line options
case "$1" in    
    --help)
        display_help
        ;;
    --version)
        display_version
        ;;
    cpu)
        if [[ "$2" == "getinfo" ]]; then
            get_cpu_info
        fi
        ;;
    memory)
        if [[ "$2" == "getinfo" ]]; then
            get_memory_info
        fi
        ;;
    user)
        case "$2" in    
            create)
                create_user "$3"
                ;;
            list)
                if [[ "$3" == "--sudo-only" ]]; then    
                    list_sudo_users
                else
                    list_users
                fi
                ;;
        esac
        ;;

        file)
            if [[ "$2" == "getinfo" ]]; then
                num_args=$(( $# - 2))
                #echo "Number of additional args = $num_args"

                if [[ num_args -gt 1 ]]; then       
                    get_file_info "$4" "$3"
                else 
                get_file_info_no_option "$3"
                fi
            fi
            ;;
        *)  
                echo "Invalid option. Try 'internsct --help' for more information."
                ;;

esac