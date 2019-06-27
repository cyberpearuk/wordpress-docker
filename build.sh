#!/bin/bash

IMAGE=$1
VERSION=$2

PROD_PATH=$(pwd)/prod
DEV_PATH=$(pwd)/dev

# Production image
cd $PROD_PATH
docker build -t $IMAGE:$VERSION .

# Development image
cd $DEV_PATH
docker build -t $IMAGE-dev:$VERSION .

