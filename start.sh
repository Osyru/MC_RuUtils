#!/bin/bash

# move to script directory
cd "$(dirname $0)"

source config.cfg

# search for existing screen session
# if screen session already exist, exit with no errors
screen -S "$screenServer" -Q select . &> /dev/null
RESULT=$?

if [[ $RESULT -eq 0 ]]
then
  { echo "server"; echo "Screen session \"$screenServer\" found."; } | /bin/bash $writeToLogScript
  { echo "server"; echo "Server already started."; } | /bin/bash $writeToLogScript
  exit 0
fi

{ echo "server"; echo "Starting server..."; } | /bin/bash $writeToLogScript

# move into the directory where the .jar file is located
cd $mcServerDir

# start server on a detached screen
screen -dmS "$screenServer" java -Xms6144M -Xmx6144M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar "$serverJarFile" nogui

sleep 30

# search for screen session
# if screen session not found, exit with error
screen -S "$screenServer" -Q select . &> /dev/null
RESULT=$?

if [[ $RESULT -ne 0 ]]
then
  { echo "server"; echo "No screen session found."; } | /bin/bash $writeToLogScript
  { echo "server"; echo "Server did not start."; } | /bin/bash $writeToLogScript
  exit 1
fi

# send a command to the minecraft console via screen
# if command cannot be found in the latest.log file, exit with error
for i in {1..3}
do
  { echo "$screenServer"; echo "say Server started."; } | /bin/bash $sendCommandScript && sentTime=$(date +"%H:%M:%S")

  sleep 2
  
  # grab the 50 last lines of the latest.log file, searching for the command sent by matching the time and type of command
  tail -n 50 $latestLogs | grep -w "$sentTime" | grep -w "Server thread/INFO" | grep -w "\[Server\] Server started." &> /dev/null
  RESULT=$?

  # screen session is found, but cannot found the sent command in the latest.log file
  if [[ $RESULT -ne 0 ]]
  then
	{ echo "server"; echo "Screen session \"$screenServer\" found, but command couldn't be found in latest.log file."; } | /bin/bash $writeToLogScript
	{ echo "server"; echo "Retrying..."; } | /bin/bash $writeToLogScript
  else
    break
  fi
  
  # abort server start after 3 failed attempt, exit with error
  if [[ $i -eq 3 ]]
  then
	{ echo "server"; echo "3 failed attempt. Aborting server start."; } | /bin/bash $writeToLogScript
	exit 1
  fi
done

{ echo "server"; echo "Server successfully started."; } | /bin/bash $writeToLogScript

sleep 1

exit 0