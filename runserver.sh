#!/bin/bash

workdir="/home/jowosh/netowork-share/minecraft-servers"

declare -A packs=(
    ["p2"]="/prominence-2"
    ["cte2"]="/craft-to-exile-2"
)

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