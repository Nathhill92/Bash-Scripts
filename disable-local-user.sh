#!/bin/bash

#Checks for root priveleges
if [[ "$UID" -ne 0 ]]
    then
        echo 'Please run with sudo or as root'
        exit 1
fi

#make directory for archiving if not made
mkdir /home/archive 2> /dev/null
#clear error log
> errorlog.err

#Reports usage
usage(){
    echo
    echo "Usage: $0 [-v] [-d] [-a] [-r] USER_NAME [USER_NAME]..."
    echo 'Note: requires at least one USER_NAME entry to run'
    echo
    echo '-v    enable logging'
    echo '-d    Deletes accounts instead of disabling them'
    echo '-r    Removes home directory asscociated with account'
    echo '-a    Creates an archive of the home directory in /archives'
    echo
    exit_message
}

# Used to output to console when VERBOSE is true
log(){
    local MESSAGE=$@
    if [[ "$VERBOSE" = 'true' ]]
    then
        echo "$MESSAGE"
    fi
}

exit_message(){
    echo "Script cancelled"
    if [[ "$VERBOSE" != 'true' ]]
    then
        echo 'Enable verbose logging (-v) for detailed information'
        echo
    fi
    exit 1
}

# Parses arguments passed into script
while getopts vdra OPTION
    do
        case $OPTION in
            (v)
                VERBOSE='true'
                log 'Verbose is enabled' ;;
            (d)
                #ensures that you user wants to delete the user
                echo
                echo "You have selected -d, are you sure that you want to delete the user(s) specified?"
                read -p "y/n:" SELECTION
                #exits if the user changed their mind/made a mistake
                if [[ "$SELECTION" != 'y' ]]
                    then
                        exit_message
                fi

                DELETE_USER="true" 
                log "Delete user selected";;

            (r)
                REMOVE_HOME_DIRECTORY='true' 
                log 'Remove home directory selected';;
            (a)
                ARCHIVE_HOME_DIRECTORY='true'
                log 'Archive home directory selected';;
            (*)
                log 'Unsupported character selected in script. See usage info'
                usage ;;
        esac
done

#Checks if USER_NAME(s) is(are) supplied
shift $(( OPTIND - 1 ))
if [[ "$#" -lt 1 ]]
    then
        log 'Script requires USER_NAME arguments to run'
        usage
fi

#Applies chosen OPTIONS to given USER_NAMES
while [ "$#" -ne 0 ]
    do    
        echo
        #checks if UID is under 1001, IE a service account
        if [[ "$(id -u $1)" < 1001 ]] 2>> ./errorlog.err
            then
                log 'Either (1) the account does not exist' '(2) you are attempting to delete an account with a UID below 1000'
                exit 1
        fi
        
        #BEGIN applying options
        #archives
        if [[ "$ARCHIVE_HOME_DIRECTORY" = 'true' ]]
        then
            tar -f "/home/archive/$1.tar.gz" -z -c "/home/$1" 2>> ./errorlog.err \
                && log "directory archived for $1" \
                || log "could not archive home directory for $1"
        fi

        #remove home directory
        if [[ "$REMOVE_HOME_DIRECTORY" = 'true' ]]
        then
            rm -r /home/$1 2>> ./errorlog.err \
            && log "directory removed for $1" \
            || log "could not remove home directory for $1"
        fi

        #deletes, or disables users
        if [[ "$DELETE_USER" = 'true' ]]
        then
            deluser "$1" 2>> ./errorlog.err \
            && log "Deleted user $1" \
            || log "Unable to Delete user $1"
        else
            chage -E 0 "$1" 2>> ./errorlog.err \
            && log "Disabled user $1" \
            || log "Unable to disable user $1"
        fi 

        #shifts list down
        shift
done

echo 'Script completed. Check errorlog.err file for detailed information.'
exit 0