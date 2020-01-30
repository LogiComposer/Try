#!/bin/sh

set -e

DEFAULT_TIMEOUT=300
timeout_counter=0

mkdir -p data
mkdir -p logs
mkdir -p data/consul
mkdir -p data/pgdata

docker-compose \
    -f docker-compose.yml \
    -f docker-compose-client.yml \
    -f services/docker-compose-data-writer-postgresql.yml \
    -f edc/docker-compose-edc-apache-solr.yml \
    -f edc/docker-compose-edc-rts.yml \
    -f edc/docker-compose-edc-postgresql.yml \
    "$@"

if [ "$1" == "up" ]; then
    echo "Waiting for Zoomdata instance to start. Max 300 seconds"
    until $(curl --output /dev/null --silent --head --fail http://zoomdata-web:8080); do
        printf '.'
        sleep 1
        timeout_counter=$((timeout_counter+1))
        if [ $timeout_counter -ge $DEFAULT_TIMEOUT ]; then
            break
        fi
    done
    echo
fi
