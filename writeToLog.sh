#!/bin/bash

# move to script directory
cd "$(dirname $0)"

source config.cfg

# logType = the type of logs ex : server, command, etc...
# inputString = content of the log string
read logType
read inputString

logTemplate='printf "[%s] : %s\n" "$(eval $logStamp)" "$inputString"'

# write the log in the appropriate .log file
# if logType not found, exit with error
case $logType in

  "server")
    eval "$logTemplate" >> $serverLogFile
	;;
	
  "command")
    eval "$logTemplate" >> $commandsLogFile
	;;
	
  *)
    echo "log file doesn't exist"
	exit 1
	;;
esac

exit 0