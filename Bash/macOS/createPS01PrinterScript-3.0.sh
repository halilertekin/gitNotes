#!/bin/bash

#############################################
#
# Takes in a .csv file,parses the it, parses the file into
# three separate colmns, and then
# finds and replaces the queue, pdds, and locations
# in the apple script. Then the resulting script is opened
# in a text editor for varification.
#
# ToDo:
#
# Done - See if there is a way to auto inject
# content into Apple
# script.
# - Have the script take in a .xml file and convert it
# to a .csv file.
#
#
# Created by: Matt Wilson | John Reeber
# Location: Kennesaw State University
# Date: 2016.09.07
# Version: 2.0
#
# Example:
#
# ./createPS01PrinterScript-2.0.sh [somecsvfile.csv]
#
##############################################



# Save user input
csv=$1

# Save each column to a separtate file
/bin/cat $csv | /usr/bin/cut -d, -f1 > Queues.csv
/bin/cat $csv | /usr/bin/cut -d, -f2 > PPDs.csv
/bin/cat $csv | /usr/bin/cut -d, -f3 > Locations.csv

# Adds " "," " to the front of the file, middle, and end, and removes \n
# character and spaces
queues=$(awk 'BEGIN{print "\""} NR > 1{print line"\",\""}{line=$0;} END{print $0"\""}' Queues.csv | tr -d '\n')
ppds=$(awk 'BEGIN{print "\""} NR > 1{print line"\",\""}{line=$0;} END{print $0"\""}' PPDs.csv | tr -d '\n')
locations=$(awk 'BEGIN{print "\""} NR > 1{print line"\",\""}{line=$0;} END{print $0"\""}' Locations.csv | tr -d [:space:] | tr -d [-*1])

# Replace current queues, ppds, & locations in applescript
sed -e 's/set queue to.*/set queue to {'"$queues"'}/' \
    -e 's/set ppd to.*/set ppd to {'"$ppds"'}/' \
    -e 's/set location to.*/set location to {'"$locations"'}/' <Printer\ WIP.applescript >Printer\ WIP\ TEMP.applescript

# Updates Version Number and adds Release Note Line
ver=$(cat Printer\ WIP\ Temp.applescript | grep Version | awk '{print $2}')
newver=$(echo "$ver + .01" | bc -l)
sed -e 's/Version '$ver'/Version '$newver'/' \
    -e 's/--Release Notes:/--Release Notes:\
--'$newver' - /' <Printer\ WIP\ TEMP.applescript >Printer\ WIP\ New.applescript
rm -rf Printer\ WIP\ TEMP.applescript
rm -rf Locations.csv PPDs.csv Queues.csv

# Opens the applescript using Script Editor application
path=$(echo "$(pwd)/Printer WIP.app")
/usr/bin/open -a /Applications/Utilities/Script\ Editor.app/ Printer\ WIP\ New.applescript
osascript -e 'tell application "Script Editor" to save front document as "application" in ("'"$path"'")'
osascript -e 'tell application "Script Editor" to open "'"$path"'"'
/usr/bin/open -a /Applications/Utilities/Script\ Editor.app/ Printer\ WIP\ New.applescript