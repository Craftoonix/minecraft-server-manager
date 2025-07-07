#!/bin/bash

workdir="/home/jowosh/netowork-share/minecraft-servers"
database="${workdir}/database.json"

# check if database file exists
if [ ! -f "$database" ]; then
    echo "Database file not found: $database"
    exit 1
fi

# import packs from database
declare -A packs
while IFS="=" read -r key value; do
    packs["$key"]="$value"
done < <(jq -r 'to_entries | map("\(.key)=\(.value)") | .[]' "$database")

# Check if the first argument is provided and is a valid pack
if [[ ! -v "packs[$1]" ]]; then
    echo "Usage: $0 <pack>"
    exit 1
fi

# change to the pack directory
packdir="${workdir}${packs[$1]}"
cd "$packdir"

# Check if run.sh exists in the pack directory
if [ ! "run.sh" ]; then
    echo "run.sh not found in $packdir"
    exit 1
fi

# Run the server
./run.sh