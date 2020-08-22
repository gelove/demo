# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
BINARY_NAME=demo
BINARY_UNIX=$(BINARY_NAME)_unix

all: test build

build:
        $(GOBUILD) -v -ldflags "-s -w" -o $(BINARY_NAME)
test:
        $(GOTEST) -v ./...
clean:
        $(GOCLEAN)
        rm -f $(BINARY_NAME)
        rm -f $(BINARY_UNIX)
run:
        $(GOBUILD) -o $(BINARY_NAME) -v ./...
        ./$(BINARY_NAME)
deps:
        $(GOGET) github.com/GeertJohan/go.rice
        $(GOGET) github.com/GeertJohan/go.rice/rice

# Cross compilation
build-linux:
        CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -a -ldflags "-s -w" -o $(BINARY_UNIX) -v
docker-build:
        docker run --rm -it -v "$(GOPATH)":/go -w /go/src/bitbucket.org/rsohlich/makepost golang:latest go build -a -ldflags "-s -w" -o "$(BINARY_UNIX)" -v
