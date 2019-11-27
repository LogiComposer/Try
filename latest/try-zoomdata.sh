#!/bin/sh

set -e

mkdir -p data
mkdir -p logs
mkdir -p data/consul
mkdir -p data/pgdata

docker-compose build

docker-compose \
    -f docker-compose.yml \
    -f docker-compose-client.yml \
    -f services/docker-compose-data-writer-postgresql.yml \
    -f edc/docker-compose-edc-apache-solr.yml \
    -f edc/docker-compose-edc-rts.yml \
    -f edc/docker-compose-edc-postgresql.yml \
    "$@"

echo
echo "Zoomdata trial was installed and started"
echo "Visit http://localhost:8080 to explore the power of Zoomdata!"
echo "***************************************************"
echo "Use admin/admin to access data and visualizations"
echo "Use supervisor/supervisor to configure the instance"
echo "***************************************************"
