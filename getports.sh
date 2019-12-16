#!/bin/bash

#This script shows open IPv4 ports on a system

netstat -4nutl | grep ':' | awk '{print $4}' | awk -F ':' '{print $NF}'

#IPv6 version:
    #### netstat -nutl | grep ':' | awk '{print $4}' | awk -F ':' '{print $NF}'