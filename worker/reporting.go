package worker

import (
	"log"
	"sync/atomic"
	"time"
)

// Reporter epresents a reporter instance
type Reporter struct {
	readFail     int64
	readSuccess  int64
	writeFail    int64
	writeSuccess int64
}

// Run starts a goroutine that prints stats
func (r *Reporter) Run() {
	for {
		select {
		case <-time.After(30 * time.Second):
			rf := atomic.SwapInt64(&r.readFail, 0)
			rs := atomic.SwapInt64(&r.readSuccess, 0)
			wf := atomic.SwapInt64(&r.writeFail, 0)
			ws := atomic.SwapInt64(&r.writeSuccess, 0)
			log.Printf("Metrics: ReadFail: %7d || ReadSuccess: %7d || WriteFail: %7d || WriteSuccess: %7d", rf, rs, wf, ws)
		}
	}
}

// Increment increments a key
func (r *Reporter) Increment(key string) {
	switch key {
	case "read.fail":
		atomic.AddInt64(&r.readFail, 1)
	case "read.success":
		atomic.AddInt64(&r.readSuccess, 1)
	case "write.fail":
		atomic.AddInt64(&r.writeFail, 1)
	case "write.success":
		atomic.AddInt64(&r.writeSuccess, 1)
	}
}
