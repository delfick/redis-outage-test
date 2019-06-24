Redis test
==========

This repository contains a sample kubedb redis installation with an example go
app that uses it.

The purpose is to demonstrate that deploying changes to the redis causes an
outage.

The scripts in here will create a k8s namespace called redisoutagetest in your
kubernetes context and installs redis and an example go app in that
namespace.

The example application will spin up 10 goroutines each with it's own redis
client and will proceed to keep writing keys and then reading keys from redis.
It will print every 30 seconds a line that looks like::

   2019/06/25 01:11:16 Metrics: ReadFail:       0 || ReadSuccess:   42516 || WriteFail:       1 || WriteSuccess:   42511

ReadFail is the number of times a read failed in the last 30 seconds, read success
is the number of times the reads succeeded, and the write numbers are the
equivalent for writing values to redis.

We will also print out what errors we get every so often with the number of times
each error happens.

This was tested on a Google Cloud GKE cluster with three 6vCPU nodes.

To start, run the following::

   $ export IMAGE_REGISTRY=gcr.io/my-amazing-company/
   $ ./deploy/scripts/build.sh && ./deploy/scripts/deploy.sh

It will tell you how to get the logs of metrics.

Then when you've let it run for a bit run::

   $ ./deploy/scripts/change_redis.sh

And watch the metrics show a few minutes outage.

To restart just the workers without deploying redis do::

   $ ./deloy/scripts/restart_workers.sh

Example run
-----------

The output from a run of this test can be found at
https://gist.github.com/delfick/574a37bedc922cef27563f9a6a9b1c7d
