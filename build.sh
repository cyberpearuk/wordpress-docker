#!/bin/bash

set -e

IMAGE=$1
VERSION=$2

PROD_PATH=$(pwd)/prod
DEV_PATH=$(pwd)/dev

# Production image
docker build --target=production -t $IMAGE:$VERSION .

# Development image
docker build --target=development -t $IMAGE-dev:$VERSION .

