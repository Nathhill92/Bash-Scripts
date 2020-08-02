#!/bin/bash

#   This script runs bash commands on other linux systems over ssh
#
#    USAGE: Enables commands to be run on multiple servers'
#    "$0 [-f FILE_NAME] [-n] [-s] [-v] COMMAND"
#
#    f     -       File name for alternative server list
#    n     -       Dry run. Shows commands without committing them
#    s     -       Super user privileges for commands ran on servers
#    v     -       Verbose. Enables logging


#checks for superuser/root 
if [[ "$(id -u)" -eq 0 ]]
then
    echo "Do not launch as 'sudo $0'"
    echo "Instead use the -s flag '$0 -s'"
    exit 1
fi

#default values
SERVER_LIST="/vagrant/servers"
SSH_OPTIONS='ssh -o ConnectTimeout=2'
SUDO=''

#describes usage
usage(){
    echo
    echo 'USAGE: Enables commands to be run on multiple servers'
    echo "$0 [-f FILE_NAME] [-n] [-s] [-v] COMMAND"
    echo
    echo 'f     -       File name for alternative server list.'
    echo 'n     -       Dry run. Shows commands without committing them.'
    echo 's     -       Super user privileges for commands ran on servers.'
    echo 'v     -       Verbose. Enables logging.'
    echo
    exit 1
} 

#User input flags
while getopts f:nsv OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    n) DRY_RUN='true' ;;
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage ;;
  esac
done

#Gets COMMAND argument
shift "$(( OPTIND - 1 ))"

if [[ "$#" -lt 1 ]]
then
    usage
fi

COMMAND="$@"

#validates server file given
if [[ ! -f "$SERVER_LIST" ]]
then
    echo "File does not exist"
    exit 1
fi

#Sets SERVER_LIST
SERVER_LIST=$(cat "$SERVER_LIST")

#Creates and executes COMMAND based on user flags 
for SERVER in $SERVER_LIST
do
    #Verbose logging
    if [[ "${VERBOSE}" = 'true' ]]
    then
        echo "${SERVER}"
    fi
    
    #constructs command
    SSH_COMMAND="${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"
    #either echos, or executes command
    if [[ "$DRY_RUN" = 'true' ]]
    then
        echo "$SSH_COMMAND"
    else
        ${SSH_COMMAND}
        SSH_EXIT_STATUS="${?}"
        
        #Checks exit status of executed command
        if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
        then
            EXIT_STATUS=${SSH_EXIT_STATUS}
            echo "Execution on ${SERVER} failed." >&2
        fi 
    fi
done

#exits
echo
if [[ "$EXIT_STATUS" -eq 0 ]]
then
    echo "Executed with no errors"
    exit 0
else   
    exit $EXIT_STATUS
fi

