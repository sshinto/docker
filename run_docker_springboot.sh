#!/usr/bin/env bash
scripts/run_setup.sh
sleep 1
# Spring boot
CONTAINER_NAME=springboot-api
echo -e "\nSet docker container name as ${CONTAINER_NAME}\n"
IMAGE_NAME=${CONTAINER_NAME}:dev
echo -e "\nSet docker image name as ${IMAGE_NAME}\n"
echo -e "Create jar...\n"
mvn clean install -DskipTests -Dmaven.wagon.http.ssl.insecure=true
echo -e "\nStop running Docker containers with image tag ${CONTAINER_NAME}...\n"
docker stop $(docker ps -a | grep ${CONTAINER_NAME} | awk '{print $1}')
docker rm $(docker ps -a | grep ${CONTAINER_NAME} | awk '{print $1}')

echo -e "\nDocker build image with name ${IMAGE_NAME}...\n"
docker image rm ${IMAGE_NAME}
docker build -t ${IMAGE_NAME} -f docker/springboot/Dockerfile .

echo -e "\nStart Docker container of the image ${IMAGE_NAME} with name ${CONTAINER_NAME}...\n"
docker run -p 8083:8080 --name ${CONTAINER_NAME} --net cassandranet --env-file env ${IMAGE_NAME}
