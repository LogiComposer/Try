#!/bin/sh

set -e

DEFAULT_TIMEOUT=300

timeout_counter=0

echo "Waiting until Zoomdata start"
until $(curl --output /dev/null --silent --head --fail http://zoomdata-web:8080); do
    printf '.'
    sleep 1
    timeout_counter=$((timeout_counter+1))
    if [ $timeout_counter -ge $DEFAULT_TIMEOUT ]; then
        break
    fi
done
echo

if [ $timeout_counter -lt $DEFAULT_TIMEOUT ]; then
    echo "Setting up predefined passwords"
    curl -L -X POST http://zoomdata-web:8080/zoomdata/api/user/initUsers \
        -u "admin:admin" \
        -H "Content-Type: application/vnd.zoomdata.v2+json" \
        -H "Accept: */*" \
        -d '[{"user": "admin", "password": "admin"}, {"user": "supervisor", "password": "supervisor"}]'
else
    echo "Zoomdata wasn't able to start within $DEFAULT_TIMEOUT seconds. Examine the docker logs."
fi

