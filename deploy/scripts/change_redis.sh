#!/usr/bin/env bash

set -e

cd "$(git rev-parse --show-toplevel)"

source deploy/scripts/common.sh

CURRENT=$(kubectl get pod --namespace redisoutagetest -l kubedb.com/name=redis -o jsonpath='{.items[0].spec.containers[0].resources.requests.memory}')

NEW="1Gi"
if [[ "$CURRENT" == "$NEW" ]]; then
  NEW="1.1Gi"
fi

PATCH=$(printf '[{"op": "replace", "path": "/spec/podTemplate/spec/resources/requests/memory", "value":"%s"}]' "$NEW")

echo "Changing redis memory requests to $NEW (was $CURRENT)"
kubectl patch redis/redis --type='json' -p="$PATCH" --namespace $NAMESPACE

sleep 5
kubectl rollout status "statefulset/redis-shard0" --namespace $NAMESPACE
kubectl rollout status "statefulset/redis-shard1" --namespace $NAMESPACE
kubectl rollout status "statefulset/redis-shard2" --namespace $NAMESPACE
