#!/bin/bash

IMAGE=$1
VERSION=$2

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker push $IMAGE:$VERSION
docker push $IMAGE-dev:$VERSION

