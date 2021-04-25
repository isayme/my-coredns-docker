FROM golang:1.16.3-alpine as builder
WORKDIR /app

RUN apk update && apk add git make

ARG COREDNS_VERSION=v1.8.3
ENV COREDNS_VERSION=${COREDNS_VERSION}

ARG DNSREDIR_VERSION=v0.0.8
ENV DNSREDIR_VERSION=${DNSREDIR_VERSION}

RUN mkdir -p coredns && git clone --depth 1 -b ${COREDNS_VERSION} https://github.com/coredns/coredns.git coredns
RUN mkdir -p coredns/plugin/dnsredir && git clone --depth 1 -b ${DNSREDIR_VERSION} https://github.com/leiless/dnsredir.git coredns/plugin/dnsredir

RUN cd coredns && make

FROM alpine
WORKDIR /app

ARG COREDNS_VERSION=v1.8.3
ENV COREDNS_VERSION=${COREDNS_VERSION}

ARG DNSREDIR_VERSION=v0.0.8
ENV DNSREDIR_VERSION=${DNSREDIR_VERSION}

COPY --from=builder /app/coredns/coredns ./

EXPOSE 53 53/udp
ENTRYPOINT ["/app/coredns"]
