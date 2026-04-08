FROM docker.io/library/debian:trixie-slim

ENV LANG=C.UTF-8

MAINTAINER Pedro A. Neves PedroANeves@users.noreply.github.com

USER root

RUN : \
  && apt-get update \
  && apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  gnupg \
  reprepro \
  ca-certificates \
  git \
  wget \
  && apt-get clean \
  && rm -fr /var/lib/apt/lists/*

WORKDIR /repo

