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

RUN mkdir -p dnsredir && git clone --depth 1 -b ${DNSREDIR_VERSION} https://github.com/leiless/dnsredir.git dnsredir
RUN cd dnsredir && rm -f go.mod go.sum && go mod init github.com/leiless/dnsredir

RUN mkdir -p ads && git clone --depth 1 -b ${ADS_VERSION} https://github.com/c-mueller/ads.git ads
RUN cd ads && rm -f go.mod go.sum && go mod init github.com/c-mueller/ads

# for local build
# ENV GOPROXY=https://goproxy.cn,direct

RUN cd coredns \
  && echo "replace github.com/leiless/dnsredir => ../dnsredir" >> go.mod \
  && echo "replace github.com/c-mueller/ads => ../ads" >> go.mod \
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
