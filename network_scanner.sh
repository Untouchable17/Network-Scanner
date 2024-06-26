#!/bin/bash

if [[ -z $1 ]]; then
    read -p "File: " FILE_PATH
else
    FILE_PATH=$1
fi

COUNT_DOWN_HOSTS=0
COUNT_UP_HOSTS=0

function show_scan_result(){
    COUNT_HOSTS=$(wc -l < "$FILE_PATH")
    echo "Scanned hosts: $COUNT_HOSTS"
    echo "Up hosts: $COUNT_UP_HOSTS"
    echo "Down hosts: $COUNT_DOWN_HOSTS"
}

function show_error_result(){
    echo "Script failed for some reason: "
    echo "1. File not found or not created"
    echo "2. File does not have read permission"
    echo "3. File is empty"
}

function send_icmp_request(){
    if [[ -n $IP_ADDRESS ]]; then
        host_status=$(nmap -sn "$IP_ADDRESS" | grep 'Host is up' | cut -d '(' -f1)
        if [[ -z $host_status ]]; then
            printf "%s is down\n" "$IP_ADDRESS"
            COUNT_DOWN_HOSTS=$((COUNT_DOWN_HOSTS +1 ))
        else
            printf "%s is up\n" "$IP_ADDRESS"
            COUNT_UP_HOSTS=$((COUNT_UP_HOSTS +1 ))
            show_dns_name
        fi
    fi
}

function show_dns_name(){
    dns_name=$(host "$IP_ADDRESS")
    printf "%s\n" "$dns_name"
}

function start_script(){
    if [[ -e $FILE_PATH && -r $FILE_PATH && -s $FILE_PATH ]]; then
        while IFS= read -r ip; do
            IP_ADDRESS=$ip
            send_icmp_request
        done < "$FILE_PATH"
        show_scan_result
    else
        show_error_result
        exit 1
    fi
}

start_script
