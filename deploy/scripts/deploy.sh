#!/usr/bin/env bash

set -e
cd "$(git rev-parse --show-toplevel)"

source deploy/scripts/common.sh

sed "s/XXX_NAMESPACE_XXX/$NAMESPACE/" deploy/k8s/namespace.yml | kubectl apply -f -

sed "s/XXX_NAMESPACE_XXX/$NAMESPACE/" deploy/k8s/redis.yml | kubectl apply -f -

sleep 5
kubectl rollout status "statefulset/redis-shard0" --namespace $NAMESPACE
kubectl rollout status "statefulset/redis-shard1" --namespace $NAMESPACE
kubectl rollout status "statefulset/redis-shard2" --namespace $NAMESPACE

PULL_POLICY=Always
if [[ -z $IMAGE_REGISTRY ]]; then
  PULL_POLICY=Never
fi

CHANGED=$(date +%s)

sed "s/XXX_NAMESPACE_XXX/$NAMESPACE/" deploy/k8s/deployment.yml \
  | sed "s/XXX_CHANGED_XXX/$CHANGED/" \
  | sed "s/XXX_IMAGE_PULL_POLICY_XXX/$PULL_POLICY/" \
  | sed "s=XXX_IMAGE_REGISTRY_XXX=$IMAGE_REGISTRY=" \
  | kubectl apply -f -

kubectl rollout status deploy/latency-worker --namespace $NAMESPACE

echo ""
echo "==="
echo "=== DEPLOYED"
echo "==="
echo ""

echo "Run the following to get logs from our workers"
echo ""

for worker in $(kubectl get pod --namespace redisoutagetest -l "app=worker,revision=$CHANGED" -o jsonpath='{.items[*].metadata.name}'); do
  echo "kubectl logs -f -n $NAMESPACE $worker"
done

echo ""
echo "When you're ready, run ./deploy/scripts/change_redis.sh and see that there is a few minute outage"
