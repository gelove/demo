FROM golang:1.15.0-alpine3.12 as builder
LABEL maintainer="Allen <61114099@qq.com>"
ENV GOPROXY=https://goproxy.io CGO_ENABLED=0 GO111MODULE=on GOOS=linux GOARCH=amd64 
RUN apk add --verbose --no-cache --repository https://mirrors.ustc.edu.cn/alpine/v3.12/main/ upx && \
    rm -rf /var/cache/apk/*
VOLUME demo_vendor:${GOPATH}
WORKDIR /go/cache
COPY go.mod .
COPY go.sum .
# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download

WORKDIR /go/bin/
# Copy the source code
COPY . .
# Build the binary and compress ==> /go/bin/demo
RUN go install github.com/GeertJohan/go.rice/rice && rice embed-go && \
    go build -a -ldflags "-s -w" -o demo . && upx demo

# FROM plugins/base:multiarch as production
FROM alpine:3.12.0 as production
LABEL maintainer="Allen <61114099@qq.com>"
RUN apk add --no-cache --repository https://mirrors.ustc.edu.cn/alpine/v3.12/main/ ca-certificates tzdata && \
    rm -rf /var/cache/apk/*
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
WORKDIR /usr/bin/
# /go/bin/demo  =>  /usr/bin/demo
COPY --from=builder /go/bin/demo .
# ENTRYPOINT ["/usr/bin/demo"]
ENTRYPOINT ["./demo"]
