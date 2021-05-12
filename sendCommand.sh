#!/bin/bash

# move to script directory
cd "$(dirname $0)"

source config.cfg

# screenDest = name the screen to send the command to
# inputCommand = the command to be send
read screenDest
read inputCommand

# send the command to the screen
# if command could not be sent, exit with error
screen -p 0 -S "$screenDest" -X stuff "$inputCommand^M"
RESULT=$?

if [[ $RESULT -eq 1 ]]
then
  { echo "command"; echo "Command \"$inputCommand\" has not been sent to screen session \"$screenDest\""; } | /bin/bash $writeToLogScript
  { echo "command"; echo "No screen session found."; } | /bin/bash $writeToLogScript
  exit 1
fi

{ echo "command"; echo "Command \"$inputCommand\" sent to screen session \"$screenDest\""; } | /bin/bash $writeToLogScript

exit 0