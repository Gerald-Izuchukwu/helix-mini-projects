#!/bin/bash

# This script is used to run the week 2 assignment for the course.

username="GERALD"
date=$(date +%Y-%m-%d)
report_file="report_${username}.txt"
directory="/tmp/backup"

check_disk_usage(){
    disk_usage=$(df -h | grep "/dev/nvme0n1p2")
    echo "Disk usage for $username on $date:"
    echo "$disk_usage"

    read -a fields <<< "$disk_usage"

    if [[ ${fields[4]%\%} -gt 80 ]]; then
        echo "Warning: Disk usage is above 80%!" >> "$report_file"
    else
        echo "Disk usage is within acceptable limits." >> "$report_file"
    fi
        
}

check_temp_backup(){
    if [ -d "$directory" ]; then
        echo "Directory exists." >> "$report_file"
    else
        echo "Directory "$directory" does not exist, creating it now." >> "$report_file"
        mkdir -p "$directory"
    fi
}

check_disk_usage
check_temp_backup