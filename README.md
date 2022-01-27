# My Custom CoreDNS
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/isayme/coredns?sort=semver&style=flat-square)](https://hub.docker.com/r/isayme/coredns)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/isayme/coredns?sort=semver&style=flat-square)
![Docker Pulls](https://img.shields.io/docker/pulls/isayme/coredns?style=flat-square)

- add plugin: dnsredir
- add plugin: ads

# Docker Compose
```
version: '3'

services:
  coredns:
    container_name: coredns
    image: isayme/coredns:latest
    restart: unless-stopped
    ports:
      # dns serve with 53 port
      - "53:53/udp"
    volumes:
      # coredns config file
      - ./config/coredns/Corefile:/app/Corefile
```
