FROM golang:1.16.3-alpine as builder
WORKDIR /app

RUN apk update && apk add git make

ARG COREDNS_VERSION=v1.8.3
ENV COREDNS_VERSION=${COREDNS_VERSION}

ARG DNSREDIR_VERSION=v0.0.8
ENV DNSREDIR_VERSION=${DNSREDIR_VERSION}

ARG ADS_VERSION=v0.2.5
ENV ADS_VERSION=${ADS_VERSION}

RUN mkdir -p coredns && git clone --depth 1 -b ${COREDNS_VERSION} https://github.com/coredns/coredns.git coredns
RUN cd coredns && go mod download
RUN cd coredns \
  && go get github.com/leiless/dnsredir@${DNSREDIR_VERSION} \
  && go get github.com/c-mueller/ads@${ADS_VERSION} \
  && sed -i "s|forward:forward|dnsredir:github.com/leiless/dnsredir\nforward:forward|g" plugin.cfg \
  && sed -i 's|hosts:hosts|ads:github.com/c-mueller/ads\nhosts:hosts|g' plugin.cfg \
  && make

FROM alpine
WORKDIR /app

ARG COREDNS_VERSION
ENV COREDNS_VERSION=${COREDNS_VERSION}

ARG DNSREDIR_VERSION
ENV DNSREDIR_VERSION=${DNSREDIR_VERSION}

ARG ADS_VERSION
ENV ADS_VERSION=${ADS_VERSION}

COPY --from=builder /app/coredns/coredns ./

EXPOSE 53 53/udp
ENTRYPOINT ["/app/coredns"]
