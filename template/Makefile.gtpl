VERSION=$(shell cat VERSION)
BUILD_TIME=$(shell date "+%F %T")
GO_VERSION=$(shell go version)
REGISTRY=
PROGNAME=$(shell head -n1 go.mod|awk '{print $$2}' | awk -F '/' '{print $$NF}' )
LD_FLAGS="-X 'main.Version=${VERSION}' -X 'main.BuildTime=${BUILD_TIME}'"

.PHONY: $(PROGNAME) test

$(PROGNAME):
	go build -ldflags $(LD_FLAGS) -tags "netgo jsoniter" .

build: $(PROGNAME)
	bash build.sh $(PROGNAME) $(REGISTRY)

push:
	podman push $(REGISTRY)/$(PROGNAME):$(VERSION)
	
test:
	go test `go list ./...`
