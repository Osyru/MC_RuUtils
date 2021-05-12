#!/bin/bash

# move to script directory
cd "$(dirname $0)"

source config.cfg

# search for existing screen session
# if screen session does not exist, exit with no errors
screen -S "$screenServer" -Q select . > /dev/null
RESULT=$?

if [[ $RESULT -ne 0 ]]
then
  { echo "server"; echo "No screen session found."; } | /bin/bash $writeToLogScript
  { echo "server"; echo "Server already stopped."; } | /bin/bash $writeToLogScript
  exit 0
fi

{ echo "server"; echo "Stopping server..."; } | /bin/bash $writeToLogScript

# sending shutdown messages to the players via the minecraft console
# 60 sec cooldown before server shutdown
{ echo "$screenServer"; echo "say Server shutdown started..."; } | /bin/bash $sendCommandScript
{ echo "$screenServer"; echo "say Please disconnect before server shutdown."; } | /bin/bash $sendCommandScript

sleep 1

{ echo "server"; echo "60 sec countdown started..."; } | /bin/bash $writeToLogScript

for i in {60..1..-1}
do
  if [[ $i -eq 60 ]] || [[ $i -eq 30 ]] || [[ $i -eq 10 ]] || [[ $i -eq 5 ]] || [[ $i -eq 4 ]] || [[ $i -eq 3 ]] || [[ $i -eq 2 ]] || [[ $i -eq 1 ]]
  then
    { echo "$screenServer"; echo "say Server shutting down in $i sec..."; } | /bin/bash $sendCommandScript
  fi
  
  sleep 1
done

{ echo "$screenServer"; echo "say Server shutting down..."; } | /bin/bash $sendCommandScript

sleep 2

# sending the "stop" command to the minecraft console via screen
# if screen session still exist, exit with error
for a in {1..3}
do
  { echo "$screenServer"; echo "stop"; } | /bin/bash $sendCommandScript
  
  sleep 20
  
  # check if screen session still exist
  screen -S "$screenServer" -Q select . > /dev/null
  RESULT=$?

  if [[ $RESULT -eq 0 ]]
  then
	{ echo "server"; echo "Screen session \"$screenServer\" found. Server did not stop."; } | /bin/bash $writeToLogScript
	{ echo "server"; echo "Retrying..."; } | /bin/bash $writeToLogScript
  else
    break
  fi
  
  # abort server shutdown after 3 failed attempt, exit with error
  if [[ $a -eq 3 ]]
  then
	{ echo "server"; echo "3 failed attempt. Aborting server shutdown."; } | /bin/bash $writeToLogScript
	exit 1
  fi
done

{ echo "server"; echo "Server successfully stopped."; } | /bin/bash $writeToLogScript

sleep 1

exit 0