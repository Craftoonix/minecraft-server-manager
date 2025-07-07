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

# Adds a pack to the database json file
add_pack() {
    local pack_name="$1"
    local pack_path="$2"
    if [[ -z "$pack_name" || -z "$pack_path" ]]; then
        echo "Usage: add_pack <pack_name> <pack_path>"
        return 1
    fi
    if [[ -v "packs[$pack_name]" ]]; then
        echo "Pack '$pack_name' already exists."
        return 1
    fi
    packs["$pack_name"]="$pack_path"
    jq --arg key "$pack_name" --arg value "$pack_path" '. + {($key): $value}' "$database" > tmp.json && mv tmp.json "$database"
    echo "Pack '$pack_name' added successfully."
}

# Runs the server for the specified pack
run(){
    # Check if the first argument is provided and is a valid pack
    if [[ ! -v "packs[$1]" ]]; then
        echo "Usage: $0 <pack>"
        exit 1
    fi

    # check number of packs
    cd "$workdir"
    numpacks=$(ls -d */ | wc -l)
    if [ "$numpacks" -ne "${#packs[@]}" ]; then
        echo "Number of packs does not match the database."
        echo "Perhaps you forgot to update the database?"
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
}

# mode to add a pack
if [[ "$1" == "add" ]]; then
    shift
    add_pack "$@"
    exit $? # Exit after adding a pack
fi

# mode to run a pack
if [[ "$1" == "run" ]]; then
    shift
    run "$@"
    exit $? # Exit after running a pack
fi