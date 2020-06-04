#!/bin/sh

##############################################################################
## Created by LogiAnalytics team May/2020
## Author: Niyakiy (eugene.chepurniy@logianalytics.com)
##############################################################################

set -e

DEFAULT_TIMEOUT=300
timeout_counter=0

mkdir -p data
mkdir -p logs
mkdir -p data/consul
mkdir -p data/pgdata

docker-compose "$@"

if [ "$1" == "up" ]; then
    echo "Waiting for LogiComposer instance to start. Max 300 seconds"
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
