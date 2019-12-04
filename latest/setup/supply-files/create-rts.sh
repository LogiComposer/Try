#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

zoomdata_url="http://localhost:8080/zoomdata"
rts_connector_url="http://localhost:8108/connector/"
rts_connector_name="RTS"

supervisor_cred=""
admin_cred=""

echoscr() { echo "$@" 1>&2; }

createEntity() {
    resource_type=$1
    resource_id=$2
    get_resource_url=$3
    post_resource_url=$4
    post_resource_body=$5
    credentials=$6

    echoscr "Trying to find $resource_type from URL: $get_resource_url"
    res=$(curl -s -X GET -u "$credentials" "$get_resource_url")
    if [[ "$res" == "[]" || "$res" == "{\"bookmarksMap\":[],\"otherBookmarksExist\":false}" ]] ; then
        echoscr "$resource_type is not available. Creating..."
        post_res=$(curl -s -o /dev/null -w "%{http_code}" -X POST -u "$credentials" \
                          --header "Content-Type:application/vnd.zoomdata.v2+json" \
                          -d "$post_resource_body" \
                          "$post_resource_url")
        if [[ "$post_res" =~ ^[3-9][0-9]+$ ]] ; then
            echoscr "Can't create $resource_type with response $post_res. Stopping..."
            exit 1
        fi
        res=$(curl -s -X GET -u "$credentials" "$get_resource_url")
        if [[ "$res" == "[]" ]] ; then
            echoscr "Can't create $resource_type. Stopping..."
            exit 1
        fi
    fi
    REGEX="\"$resource_id\"[^0-9a-z]+([0-9a-z]+)"
    if [[ "$res" =~ $REGEX ]] ; then
        requested_id=${BASH_REMATCH[1]}
        echoscr "Found $resource_type with id = $requested_id"
        echo $requested_id
    else
        echoscr "We are unable to take $resource_type id from response: \"$res\". Stopping..."
        exit 1
    fi
}

createConnector () {
    zoomdata_url=$1
    rts_connector_name=$2
    rts_connector_url=$3
    credentials=$4

    post_body="{\"name\": \"$rts_connector_name\", \"type\": \"HTTP\", \"params\": {\"HTTP_URL\": \"$rts_connector_url\"}}"
    get_url="$zoomdata_url/api/connectors?name=$rts_connector_name"
    post_url="$zoomdata_url/api/connectors"

    i=1
    res=$(curl -s -X GET -u "$credentials" "$get_url")
    while [[ $i -le 5 && "$res" == "[]" ]]; do
        echoscr "$rts_connector_name connector is not available. Waiting for a second for it to be registered via Service Discovery."
        sleep 1
        res=$(curl -s -X GET -u "$credentials" "$get_url")
        let i=i+1
    done

    createEntity "Connector" "id" "$get_url" "$post_url" "$post_body" "$credentials"
}

createConnectionType () {
    zoomdata_url=$1
    rts_connector_name=$2
    connector_id=$3
    credentials=$4

    post_body="{\"name\":\"$rts_connector_name\",\"type\":\"EDC2\",\"enabled\":true, \
                \"connectorId\":\"$connector_id\",\"subStorageType\":\"RTS\",\"parameters\":[]}"
    get_url="$zoomdata_url/api/connection/types?name=$rts_connector_name"
    post_url="$zoomdata_url/api/connection/types"

    createEntity "ConnectionType" "id" "$get_url" "$post_url" "$post_body" "$credentials"
}

createSourceConnection () {
    zoomdata_url=$1
    rts_connection_name="$2 Connection"
    connection_type_id=$3
    credentials=$4

    post_body="{\"name\":\"$rts_connection_name\",\"type\":\"EDC2\",\"subStorageType\":\"RTS\", \
                \"connectionTypeId\":\"$connection_type_id\",\"parameters\":{}}"
    get_url="$zoomdata_url/api/connections?name=$2+Connection"
    post_url="$zoomdata_url/api/connections"

    createEntity "SourceConnection" "id" "$get_url" "$post_url" "$post_body" "$credentials"
}

createSource () {
    zoomdata_url=$1
    rts_name="Real Time Sales"
    connection_id=$3
    credentials=$4

    fields_url="$zoomdata_url/api/sources/fields"
    construct_fields_url="$zoomdata_url/api/sources/fields/construct"
    get_url="$zoomdata_url/api/sources/name/Real%20Time%20Sales"
    post_url="$zoomdata_url/api/sources"

    res=$(curl -s -X GET -u "$credentials" "$get_url")
    if [[ "$res" == "[]" ]] ; then
        source_body="{\"name\":\"$rts_name\", \"timeFieldName\":\"ts\", \"live\":true, \"playbackMode\":true, \
                            \"type\":\"EDC2\",\"subStorageType\":\"RTS\",                                           \
                            \"storageConfiguration\":{                                                              \
                                \"collection\":\"RTS\", \"schema\":\"PUBLIC\", \"connectionId\":\"$connection_id\"   \
                            }, \"objectFields\":"

        fields=$(curl -s --header "Content-Type:application/vnd.zoomdata.v2+json" -X POST -d"$source_body[]}" -u "$credentials" "$fields_url")
        fields=$(curl -s --header "Content-Type:application/vnd.zoomdata.v2+json" -X POST -d"$source_body$fields}" -u "$credentials" "$construct_fields_url")
        post_body="$source_body$fields}"
    fi
    createEntity "Source" "sourceId" "$get_url" "$post_url" "$post_body" "$credentials"
}

createDashboard() {
    zoomdata_url=$1
    source_id=$2
    credentials=$3

    dashboard=$(eval "cat $DIR/demo_bookmark.json")
    dashboard=$(echo $dashboard | sed "s/::sourceId::/$source_id/g")
    get_url="$zoomdata_url/api/dashboards?sourceId=$source_id"
    post_url="$zoomdata_url/api/dashboards"

    createEntity "Dashboard" "id" "$get_url" "$post_url" "$dashboard" "$credentials"
}

usage() {
    echo "Usage: ${0} [OPTIONS]... -a|--admin <username:password> -s|--supervisor <username:password>"
    echo ""
    echo "-a, --admin           Admin credentials"
    echo "-s, --supervisor      Supervisor credentials"
    echo "-z, --zoomdata        Zoomdata URI"
    echo "-c, --connector       RTS connector URI"
    echo "-cn, --con-name       RTS connector name"
    echo ""
    echo "-h, --help            Print this help and exit"
}

while [ "$1" != "" ]; do
    case $1 in
        -z | --zoomdata )       shift
                                zoomdata_url=$1
                                ;;
        -c | --connector )      shift
                                rts_connector_url=$1
                                ;;
        -cn | --con-name )      shift
                                rts_connector_name=$1
                                ;;
        -s | --supervisor )     shift
                                supervisor_cred=$1
                                ;;
        -a | --admin )          shift
                                admin_cred=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [[ "x" == "x${admin_cred}" ]] ; then
    usage
    exit 1
fi

if [[ "x" == "x${supervisor_cred}" ]] ; then
    usage
    exit 1
fi

connector_id=$(createConnector "$zoomdata_url" "$rts_connector_name" "$rts_connector_url" "$supervisor_cred") || exit $?
connection_type_id=$(createConnectionType "$zoomdata_url" "$rts_connector_name" "$connector_id" "$supervisor_cred") || exit $?
connection_id=$(createSourceConnection "$zoomdata_url" "$rts_connector_name" "$connection_type_id" "$admin_cred") || exit $?
source_id=$(createSource "$zoomdata_url" "$rts_connector_name" "$connection_id" "$admin_cred") || exit $?
dashboard_id=$(createDashboard "$zoomdata_url" "$source_id" "$admin_cred") || exit $?
