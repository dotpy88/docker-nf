#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

[[ "$DEBUG" == "true" ]] && set -x

#start syslog
echo "Starting syslog service"
service rsyslog restart

#stop apache2
service apache2 stop

#Wipe existing files if installed.flag is removed.  Install nfsen if not.  
FILE=/opt/nfsen/installed.flag
if [ -f "$FILE" ]; then
    echo "Skipping cleanup.  Nfsen service is already installed.  Stop service and run reconfig"
    /opt/nfsen/bin/nfsen stop
    echo "y" | /opt/nfsen/bin/nfsen reconfig

else
    echo "Cleaning up files for new Nfsen installation"
    rm -rf /opt/nfsen/*
    #install nfsen
    echo "Running Nfsen install script"
    echo | ./install.pl ./etc/nfsen.conf || true #This returns true even though semaphore error causes non-true return
    #Add flag so we know it's installed
    echo "Touching file to mark installation"
    touch $FILE
fi

# Starting nfsend
echo "Starting Nfsen service"
/opt/nfsen/bin/nfsen start
echo "Nfsen service is now started"

exec "$@"