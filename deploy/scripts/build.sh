#!/usr/bin/env bash

set -e

cd "$(git rev-parse --show-toplevel)"

NAME=${IMAGE_REGISTRY}redis-latency-tester

docker build . -t $NAME
if [[ ! -z $IMAGE_REGISTRY ]]; then
    docker push $NAME
fi
