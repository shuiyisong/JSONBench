#!/bin/bash

# Check if the required arguments are provided
if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <DATA_DIRECTORY> <MAX_FILES> <SUCCESS_LOG> <ERROR_LOG>"
    exit 1
fi

# Arguments
DATA_DIRECTORY="$1"
MAX_FILES="$2"
SUCCESS_LOG="$3"
ERROR_LOG="$4"

# Validate arguments
[[ ! -d "$DATA_DIRECTORY" ]] && { echo "Error: Data directory '$DATA_DIRECTORY' does not exist."; exit 1; }
[[ ! "$MAX_FILES" =~ ^[0-9]+$ ]] && { echo "Error: MAX_FILES must be a positive integer."; exit 1; }

# Lets use vector to ingest data
if [ -f "./vector" ] && [ -x "./vector" ]; then
    echo "Vector already installed, skipping installation."
else
    echo "Vector not found, installing..."
    wget -N https://packages.timber.io/vector/0.45.0/vector-0.45.0-x86_64-unknown-linux-gnu.tar.gz
    tar xvf vector-0.45.0-x86_64-unknown-linux-gnu.tar.gz
    rm vector-0.45.0-x86_64-unknown-linux-gnu.tar.gz
    mv vector-x86_64-unknown-linux-gnu/bin/vector ./vector
    rm -rf vector-x86_64-unknown-linux-gnu
    echo "Downloaded vector."
fi

DATA_PATHS=""
case $MAX_FILES in
    1)
        DATA_PATHS="\"$DATA_DIRECTORY/file_0001.json.gz\""
        ;;
    10)
        DATA_PATHS="\"$DATA_DIRECTORY/file_000?.json.gz\", \"$DATA_DIRECTORY/file_0010.json.gz\""
        ;;
    100)
        DATA_PATHS="\"$DATA_DIRECTORY/file_00??.json.gz\", \"$DATA_DIRECTORY/file_0100.json.gz\""
        ;;
    1000)
        DATA_PATHS="\"$DATA_DIRECTORY/file_*.json.gz\""
        ;;
    *)
        echo "Unsupported range. Please use 1, 10, 100, or 1000."
        return 1
        ;;
esac

# Make config file
DATA_PATHS=$DATA_PATHS envsubst < vector.toml.tpl > vector.toml
mkdir ./vector_checkpoint
# Start vector
echo "Starting loading data."
./vector -c vector.toml > $SUCCESS_LOG 2> $ERROR_LOG &
while true
do
    curl -s --fail http://localhost:8686/health && break
    sleep 1
done

# Check progress
echo "Checking loading progress."
./detect_loading.sh

# Done loading, stop vector
while true
do
    pidof vector && kill `pidof vector` || break
    sleep 1
done

rm -rf ./vector_checkpoint
rm vector.toml

curl -XPOST -H 'Content-Type: application/x-www-form-urlencoded' \
          http://localhost:4000/v1/sql \
          -d "sql=admin flush_table('jsontable')"

echo "Loaded $MAX_FILES data files from $DATA_DIRECTORY to greptimedb."