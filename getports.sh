#!/bin/bash

#This script shows open IPv4 ports on a system

netstat -nutl | grep ':' | awk '{print $4}' | awk -F ':' '{print $NF}' | sort -hu

#IPv6 version:
    #### netstat -nutl | grep ':' | awk '{print $4}' | awk -F ':' '{print $NF}'