#!/bin/sh

set -e

# Checking if Docker is installed
if [ ! -x "$(command -v docker)" ]; then
    echo "[ERROR] Docker is required to run Zoomdata trial"
    echo "   Try something like this to install Docker:"
    echo "   curl -fsSL https://get.docker.com | sudo /bin/sh"
    exit 1
fi

# Checking if Docker-Compose is installed
if [ ! -x "$(command -v docker-compose)" ]; then
    echo "[ERROR] Docker-Compose is required to run Zoomdata trial"
    echo "   Try something like this to install Docker-Compose:"
    echo '   sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
    echo "   and make sure '/usr/local/bin/' is in your $PATH enviroment variable"
    exit 1
fi

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

case "$1" in 
  *up*)
    echo
    echo "Waiting until Zoomdata start"
    until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
        printf '.'
        sleep 1
    done
    ;;
esac

echo
echo "Zoomdata trial was installed and started"
echo "Visit http://localhost:8080 to explore the power of Zoomdata!" 
