#!/usr/bin/env bash

set -e

cd "$(git rev-parse --show-toplevel)"

source deploy/scripts/common.sh

CHANGED=$(date +%s)

CHANGE1=$(printf '{"op": "replace", "path": "/spec/template/spec/containers/0/env/0/value", "value":"%s"}' "$CHANGED")
CHANGE2=$(printf '{"op": "replace", "path": "/spec/template/metadata/labels/revision", "value":"%s"}' "$CHANGED")
PATCH="[$CHANGE1,$CHANGE2]"

kubectl patch deploy/latency-worker --type='json' -p="$PATCH" --namespace $NAMESPACE
kubectl rollout status deploy/latency-worker --namespace $NAMESPACE

echo "Run the following to get logs from our workers"
echo ""

for worker in $(kubectl get pod --namespace redisoutagetest -l "app=worker,revision=$CHANGED" -o jsonpath='{.items[*].metadata.name}'); do
  echo "kubectl logs -f -n $NAMESPACE $worker"
done
