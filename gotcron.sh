#!/bin/bash

## Retry variables
MAX_RETRIES=3
ATTEMPT=1
SLEEP_SEC=5

## wget variables
WGET_PARAMS='-np -P client --reject-regex (Special:|Star_Trek_Timelines:|Category:Crew|Category:Missions|Category_talk:|Cadets$|Main_Page|Mobile_Apps|Missions)'
WGETSOURCE_CATEGORIES=data/wgetcategories.txt
WGETSOURCE_MORECREW=data/wgetmorecrew.txt

CATEGORIES=( 'Common' 'Uncommon' 'Rare' 'Super_Rare' 'Super_Rare?pagefrom=Ruk' 'Legendary' 'Away_Team_Missions' 'Space_Battle_Missions' )

generate_wgetsources() {
    echo "Generating source files for wget"
    > $WGETSOURCE_CATEGORIES
    for item in ${CATEGORIES[*]}
    do
        printf "https://stt.wiki/wiki/Category:%s\n" $item >> $WGETSOURCE_CATEGORIES
    done

    # Sort morejson by Category (Stars) then by name
    jq  -r 'sort_by(.stars,.wiki)|.[].wiki | sub("/wiki/"; "https://stt.wiki/wiki/")' client/morecrew.json >$WGETSOURCE_MORECREW
}

download_wiki() {
    echo "Fetching Wiki Categories"
    wget $WGET_PARAMS -m -l1 -o ./logs/categories.log -i $WGETSOURCE_CATEGORIES
    grep -A 3 FINISHED logs/categories.log

    echo "Fetching MoreCrew"
    wget $WGET_PARAMS -x -N -o ./logs/morecrew.log -i $WGETSOURCE_MORECREW

    grep -A 3 FINISHED logs/morecrew.log
}

echo "Checking for new characters"
node lib/newchars.js

echo "Creating wget source files"
generate_wgetsources

# Removing Category pages to ensures subpages are refreshed
rm client/stt.wiki/wiki/Category*

while [ $ATTEMPT -le $MAX_RETRIES ]
do
    echo "Starting download of wiki - attempt $ATTEMPT"
    download_wiki
    BADDOWNLOADS=$( find client/stt.wiki/wiki/ -size -10k |wc -l )
    if [ $BADDOWNLOADS -eq 0 ]
    then
        break
    fi
    echo "Bad downloads detected!"
    find client/stt.wiki/wiki/ -size -10k -exec rm {} \;
    sleep $SLEEP_SEC
    ATTEMPT=$(( $ATTEMPT + 1 ))
done

if [ $ATTEMPT -gt $MAX_RETRIES ]
then
    echo "Unable to download all files at this time"
    exit 1
fi

echo "Starting cachewiki"
node lib/cachewiki.js

echo "Telling bot to restart "
if [ -f /etc/alpine-release ] 
then
    pkill -f lib/index.js
else
    pkill -F ../data/run.pid
fi
