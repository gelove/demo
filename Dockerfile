FROM alpine:3.12.0
LABEL maintainer="Allen <61114099@qq.com>"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --verbose --no-cache ca-certificates tzdata && rm -rf /var/cache/apk/*
ENV TZ=Asia/Shanghai
# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
COPY demo .
ENTRYPOINT ["./demo"]
