FROM mcr.microsoft.com/devcontainers/java:1-17-bookworm

RUN find /etc/apt/sources.list.d -type f -name '*yarn*' -delete \
    && apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        default-mysql-client \
        iputils-ping \
        maven \
        netcat-openbsd \
        redis-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
