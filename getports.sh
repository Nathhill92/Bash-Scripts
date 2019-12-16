#!/bin/bash

#This script shows open ports on a system
netstat -nutl | grep ':' | awk '{print $4}' | awk -F ':' '{print $NF}' | sort -hu
