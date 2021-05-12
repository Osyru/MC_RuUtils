#!/bin/bash

# move to script directory
cd "$(dirname $0)"

source config.cfg

{ echo "server"; echo "Daily backup and restart started..."; } | /bin/bash $writeToLogScript

# stop the minecraft server
# if server is not stopped, abort and exit with error
/bin/bash $stopScript
RESULT=$?

if [[ $RESULT -ne 0 ]]
then
  { echo "server"; echo "Aborting daily backup and restart."; } | /bin/bash $writeToLogScript
  exit 1
fi

# start backup of the minecraft server
# if any error occurs, abort and exit with error
/bin/bash $backupScript
RESULT=$?

if [[ $RESULT -ne 0 ]]
then
  { echo "server"; echo "Aborting daily backup and restart."; } | /bin/bash $writeToLogScript
  exit 1
fi

sleep 5

# restart virtual machine
/sbin/shutdown -r now