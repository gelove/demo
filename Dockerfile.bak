FROM golang:1.15.0-alpine3.12 as builder
LABEL maintainer="Allen <61114099@qq.com>"
ENV GOPROXY=https://goproxy.cn GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64
# ENV GOPROXY=https://mirrors.aliyun.com/goproxy/ GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
# 修改alpine源为阿里源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --verbose --no-cache upx && rm -rf /var/cache/apk/*
WORKDIR /go/build
COPY go.mod .
COPY go.sum .
# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download
# Copy the source code
COPY . .
# Build the binary and compress
RUN go install github.com/GeertJohan/go.rice/rice && rice embed-go && \
    go build -a -ldflags "-s -w" -o demo . && upx demo

# FROM plugins/base:multiarch as production
FROM alpine:3.12.0 as production
LABEL maintainer="Allen <61114099@qq.com>"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --verbose --no-cache ca-certificates tzdata && rm -rf /var/cache/apk/*
ENV TZ=Asia/Shanghai
# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
WORKDIR /app
COPY --from=builder /go/build/demo .
ENTRYPOINT ["/app/demo"]
