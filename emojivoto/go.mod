module github.com/buoyantio/emojivoto

go 1.24

replace github.com/buoyantio/emojivoto/emojivoto-emoji-svc => ./emojivoto-emoji-svc

replace github.com/buoyantio/emojivoto/emojivoto-voting-svc => ./emojivoto-voting-svc

require (
	contrib.go.opencensus.io/exporter/ocagent v0.6.0
	github.com/grpc-ecosystem/go-grpc-prometheus v1.2.0
	github.com/prometheus/client_golang v1.6.0
	go.opencensus.io v0.22.3
	google.golang.org/grpc v1.70.0
	google.golang.org/protobuf v1.35.2
)

require (
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/census-instrumentation/opencensus-proto v0.4.1 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/golang/groupcache v0.0.0-20200121045136-8c9f03a8e57e // indirect
	github.com/golang/protobuf v1.5.4 // indirect
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.11.3 // indirect
	github.com/matttproud/golang_protobuf_extensions v1.0.1 // indirect
	github.com/prometheus/client_model v0.2.0 // indirect
	github.com/prometheus/common v0.9.1 // indirect
	github.com/prometheus/procfs v0.0.11 // indirect
	golang.org/x/net v0.32.0 // indirect
	golang.org/x/sync v0.10.0 // indirect
	golang.org/x/sys v0.28.0 // indirect
	golang.org/x/text v0.21.0 // indirect
	google.golang.org/api v0.22.0 // indirect
	google.golang.org/genproto v0.0.0-20220822174746-9e6da59bd2fc // indirect
)
