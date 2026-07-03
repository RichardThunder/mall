FROM mcr.microsoft.com/devcontainers/java:1-17-bookworm

RUN find /etc/apt/sources.list.d -type f -name '*yarn*' -delete \
    && apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        default-mysql-client \
        iputils-ping \
        maven \
        netcat-openbsd \
        redis-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/vscode/.codex \
        /home/vscode/.cursor-server \
        /home/vscode/.local/bin \
        /home/vscode/.vscode-server \
    && chown -R vscode:vscode /home/vscode/.codex \
        /home/vscode/.cursor-server \
        /home/vscode/.local \
        /home/vscode/.vscode-server

ENV PATH="/home/vscode/.local/bin:${PATH}"
