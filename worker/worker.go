package worker

import (
	"log"

	"github.com/go-redis/redis"
)

type reporter interface {
	Increment(string)
}

// StartWorker starts a new worker with the provided dataset
func StartWorker(redisHost string, reporter reporter, dataset Dataset, name string) {
	log.Printf("Starting worker: %s", name)

	opts := &redis.ClusterOptions{}
	opts.Addrs = []string{redisHost}
	client := redis.NewClusterClient(opts)

	err := client.ReloadState()
	if err != nil {
		log.Fatal(err)
	}

	for {
		errs := make(map[string]int)

		for i, dv := range dataset {
			if i%100 == 0 {
				for e, count := range errs {
					log.Printf("\tError (%d times): %s", count, e)
				}
				errs = make(map[string]int)
			}

			err := client.MSet(*dv.ToPairs()...).Err()

			if err != nil {
				errs["write: "+err.Error()]++
				reporter.Increment("write.fail")
			} else {
				reporter.Increment("write.success")
			}

			err = client.MGet(*dv.ToKeys()...).Err()

			if err != nil {
				errs["read: "+err.Error()]++
				reporter.Increment("read.fail")
			} else {
				reporter.Increment("read.success")
			}
		}
	}
}
