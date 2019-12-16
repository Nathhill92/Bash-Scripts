#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then
    echo
    echo "Relaunch with root or admin credentials to see PID values"
    echo
fi


#! this script gets the IPv4 ports open, and PID assosciated with the open ports
netstat -4nutlp | grep ':' | awk '{print $4, $NF}' | awk -F ':' '{print $NF}'