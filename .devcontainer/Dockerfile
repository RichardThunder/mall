FROM mcr.microsoft.com/devcontainers/java:1-17-bookworm

RUN find /etc/apt/sources.list.d -type f -name '*yarn*' -delete \
    && apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        default-mysql-client \
        bubblewrap \
        fzf \
        git \
        git-lfs \
        iputils-ping \
        jq \
        less \
        maven \
        netcat-openbsd \
        nodejs \
        npm \
        openssh-client \
        procps \
        redis-tools \
        ripgrep \
        vim \
        zsh \
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

RUN if [ ! -d /home/vscode/.oh-my-zsh/.git ]; then \
        rm -rf /home/vscode/.oh-my-zsh \
        && git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /home/vscode/.oh-my-zsh; \
    fi \
    && mkdir -p /home/vscode/.oh-my-zsh/custom/plugins \
    && if [ ! -d /home/vscode/.oh-my-zsh/custom/plugins/zsh-autosuggestions/.git ]; then \
        rm -rf /home/vscode/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
        && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /home/vscode/.oh-my-zsh/custom/plugins/zsh-autosuggestions; \
    fi \
    && if [ ! -d /home/vscode/.oh-my-zsh/custom/plugins/zsh-completions/.git ]; then \
        rm -rf /home/vscode/.oh-my-zsh/custom/plugins/zsh-completions \
        && git clone --depth=1 https://github.com/zsh-users/zsh-completions.git /home/vscode/.oh-my-zsh/custom/plugins/zsh-completions; \
    fi \
    && if [ ! -d /home/vscode/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.git ]; then \
        rm -rf /home/vscode/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
        && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vscode/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; \
    fi \
    && chown -R vscode:vscode /home/vscode/.oh-my-zsh \
    && chsh -s /usr/bin/zsh vscode

COPY --chown=vscode:vscode zsh/.zshrc /home/vscode/.zshrc
COPY --chown=vscode:vscode git/.gitconfig /home/vscode/.gitconfig

ENV PATH="/home/vscode/.local/bin:${PATH}"

RUN npm install -g @openai/codex \
    && codex --version
