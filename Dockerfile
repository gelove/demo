FROM hub.finthe.com/library/golang:1.15.0-alpine3.12 as builder
LABEL maintainer="Allen <61114099@qq.com>"
ENV GOPROXY=https://mirrors.aliyun.com/goproxy/ CGO_ENABLED=0 GO111MODULE=on GOOS=linux GOARCH=amd64 
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
FROM hub.finthe.com/library/alpine:3.12.0 as production
LABEL maintainer="Allen <61114099@qq.com>"
WORKDIR /usr/bin/
# 修改alpine源为中科大源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
  apk update && \
  apk upgrade && \
  apk add ca-certificates && update-ca-certificates && \
  apk add --update tzdata && \
  rm -rf /var/cache/apk/*
# RUN apk add --no-cache --repository https://mirrors.ustc.edu.cn/alpine/v3.12/main/ ca-certificates tzdata && \
#     rm -rf /var/cache/apk/*
# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ENV TZ=Asia/Shanghai
# /go/bin/demo  =>  /usr/bin/demo
COPY --from=builder /go/bin/demo .
# ENTRYPOINT ["/usr/bin/demo"]
ENTRYPOINT ["./demo"]
