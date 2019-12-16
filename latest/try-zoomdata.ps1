##############################################################################
## Created by Zoomdata/Logi team Dec/2019
## Author: Niyakiy (jonny.niyakiy@gmail.com)
##############################################################################

New-Item -ItemType Directory -Force -Path data
New-Item -ItemType Directory -Force -Path logs
New-Item -ItemType Directory -Force -Path data/consul

docker-compose `
    -f docker-compose.yml `
    -f docker-compose-windows.yml `
    -f docker-compose-client.yml `
    -f services/docker-compose-data-writer-postgresql.yml `
    -f edc/docker-compose-edc-apache-solr.yml `
    -f edc/docker-compose-edc-rts.yml `
    -f edc/docker-compose-edc-postgresql.yml `
    $args

If ($args[0] -eq "up") {
  Write-Host "Waiting for Zoomdata instance to start. Max 300 seconds"
  support/http-ping.ps1 -url http://localhost:8080/
}
