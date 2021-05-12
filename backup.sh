#!/bin/bash

# move to script directory
cd "$(dirname $0)"

source config.cfg

# search for existing screen session
# if screen session is found, server is not stopped, exit with error
screen -S "$screenServer" -Q select . > /dev/null
RESULT=$?

if [[ $RESULT -eq 0 ]]
then
  { echo "server"; echo "Screen session \"$screenServer\" found."; } | /bin/bash $writeToLogScript
  { echo "server"; echo "Server is not stopped. Aborting server backup."; } | /bin/bash $writeToLogScript
  exit 1
fi

{ echo "server"; echo "Server backup started..."; } | /bin/bash $writeToLogScript

# checking how many files exist in the backup directory
# if number of file found exceeds the limit, delete all oldest files until number of files is equal to max minus one
if [[ $(ls $backupsDir | wc -l) -ge $maxBackupFiles ]]
then
  { echo "server"; echo "Maximum number of backup files exceeded."; } | /bin/bash $writeToLogScript
  { echo "server"; echo "Deleting oldest backup files..."; } | /bin/bash $writeToLogScript
  
  while [ $(ls $backupsDir | wc -l) -ge $maxBackupFiles ]
  do
    fileToDelete=$(find $backupsDir -type f -printf "%T@ %h/%f\n" | sort -k1n,1 | awk 'NR==1 {print $NF}')
    rm -f $fileToDelete
	
	{ echo "server"; echo "File deleted -> $fileToDelete"; } | /bin/bash $writeToLogScript
  done
fi

{ echo "server"; echo "Creating tar.gz archive..."; } | /bin/bash $writeToLogScript

# create a .tar.gz archive of the entire server directory, ignoring the backup folder
# if error while creating the archive, exit with error
archivePath=$backupsDir"/$(eval $backupStamp).tar.gz"
startTime=$(date +%s.%N)
tar -czf $archivePath --exclude=$backupsDir $mcServerDir
RESULT=$?

if [[ $RESULT -ne 0 ]]
then
  { echo "server"; echo "An error occured while creating tar.gz archive. Aborting server backup."; } | /bin/bash $writeToLogScript
  
  rm -f $archivePath
  exit 1
fi

endTime=$(date +%s.%N)

{ echo "server"; echo "Done in $(echo "$endTime $startTime" | awk '{printf "%.3f\n", $1-$2}') sec."; } | /bin/bash $writeToLogScript

sleep 1

exit 0