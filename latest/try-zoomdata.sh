#!/bin/sh

set -e

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
