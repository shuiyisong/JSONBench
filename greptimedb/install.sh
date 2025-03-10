#!/bin/bash

RELEASE_VERSION=v0.13.0-nightly-20250310
BASEDIR=greptimedb_data

# stop the existing victorialogs instance if any and drop its data
while true
do
    pidof greptime && kill `pidof greptime` || break
    sleep 1
done
rm -rf ${BASEDIR}

# check if greptime executable already exists
if [ -f "./greptime" ] && [ -x "./greptime" ]; then
    echo "Found existing greptime executable, skipping download."
else
    # download greptimedb
    wget "https://github.com/GreptimeTeam/greptimedb/releases/download/${RELEASE_VERSION}/greptime-linux-amd64-${RELEASE_VERSION}.tar.gz"
    tar xzf greptime-linux-amd64-${RELEASE_VERSION}.tar.gz
    mv greptime-linux-amd64-${RELEASE_VERSION}/greptime ./
    rm -rf greptime-linux-amd64-${RELEASE_VERSION}
    rm -rf greptime-linux-amd64-${RELEASE_VERSION}.tar.gz
    echo "Downloaded greptimedb."
fi

# start greptimedb
export GREPTIMEDB_STANDALONE__WAL__DIR="${BASEDIR}/wal"
export GREPTIMEDB_STANDALONE__STORAGE__DATA_HOME="${BASEDIR}"
export GREPTIMEDB_STANDALONE__LOGGING__DIR="${BASEDIR}/logs"
export GREPTIMEDB_STANDALONE__LOGGING__APPEND_STDOUT=false
./greptime standalone start &

echo "Starting greptimedb."

while true
do
    curl -s --fail http://localhost:4000/health && break
    sleep 1
done
echo "Started greptimedb."

# init pipeline
curl -s -XPOST 'http://localhost:4000/v1/events/pipelines/jsonbench' -F 'file=@pipeline.yaml'
echo "Pipeline initialized."

# Check if vector is installed, if not install it
if [ -f "./vector" ] && [ -x "./vector" ]; then
    echo "Vector not found, installing..."
    wget https://packages.timber.io/vector/0.45.0/vector-0.45.0-x86_64-unknown-linux-gnu.tar.gz
    tar xvf vector-0.45.0-x86_64-unknown-linux-gnu.tar.gz
    mv vector-0.45.0-x86_64-unknown-linux-gnu/bin/vector ./vector
    echo "Downloaded vector."
else
    echo "Vector already installed, skipping installation."
fi