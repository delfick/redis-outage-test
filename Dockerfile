FROM golang:1.12 as builder
ADD . /app
WORKDIR /app
RUN GOOS=linux CGO_ENABLED=0 go build -a -installsuffix cgo -o /redis-latency-tester -mod=vendor

FROM scratch
COPY --from=builder /redis-latency-tester /redis-latency-tester
CMD [""]
ENTRYPOINT [ "/redis-latency-tester" ]
