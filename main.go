package main

import (
	"fmt"
	"sync"

	"github.com/lifx/redis-latency-tester/worker"
)

const (
	datasetSize int    = 1000
	nWorkers    int    = 10
	redisHost   string = "redis.redisoutagetest:6379"
)

func main() {
	reporter := &worker.Reporter{}

	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		defer wg.Done()
		reporter.Run()
	}()

	for i := 0; i < nWorkers; i++ {
		dataset := worker.MakeDataset(datasetSize)
		name := fmt.Sprintf("worker_%0.4d", i)

		wg.Add(1)
		go func() {
			defer wg.Done()
			worker.StartWorker(redisHost, reporter, dataset, name)
		}()
	}

	wg.Wait()
}
