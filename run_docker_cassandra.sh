#!/usr/bin/env bash
docker pull cassandra
NETWORK_NAME="cassandranet"
if ! docker network ls | grep -Fq "$NETWORK_NAME" 1>/dev/null; then
    echo "Network $NETWORK_NAME not found"
    docker network create $NETWORK_NAME
fi
CONTAINER_NAME="cassandra"
if ! docker container ls -a | grep -Fq "$CONTAINER_NAME" 1>/dev/null; then
    echo "Container $CONTAINER_NAME not found."

    docker run --name $CONTAINER_NAME -d \
    --net $NETWORK_NAME \
    -e CASSANDRA_START_RPC=true \
    -p 9042:9042  \
    cassandra

    echo "wait for cassandra to start"
    while ! docker logs $CONTAINER_NAME | grep "Created default superuser role"
    do
     echo "$(date) - still trying"
     sleep 30
    done
    echo "$(date) - connected successfully"

    echo 'edit cassandra.yaml file to allow create materialized view and indexes'
    docker cp $CONTAINER_NAME:/etc/cassandra/cassandra.yaml docker/cassandra/

    echo 'replace enable_materialized_views: false to true'
    sed -i -r 's/enable_materialized_views: false/enable_materialized_views: true/' docker/cassandra/cassandra.yaml
    echo 'replace enable_sasi_indexes: false to true'
    sed -i -r 's/enable_sasi_indexes: false/enable_sasi_indexes: true/' docker/cassandra/cassandra.yaml

    docker cp docker/cassandra/cassandra.yaml $CONTAINER_NAME:/etc/cassandra
fi

echo "copy db script in container"
docker exec $CONTAINER_NAME rm -rf /dbscripts
docker cp docker/cassandra/dbscripts $CONTAINER_NAME:/dbscripts
docker exec $CONTAINER_NAME cqlsh localhost -f dbscripts/initial.cql

