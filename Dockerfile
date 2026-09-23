# Pi 编码代理的官方镜像构建文件
# 上游：@earendil-works/pi-coding-agent（npm）
#
# 构建：docker build --build-arg PI_VERSION=0.87.1 -t pi-docker:0.87.1 .
# 版本参数：PI_VERSION 支持任意 npm 版本号或 dist-tag（默认 latest）
FROM node:24-bookworm-slim

ARG PI_VERSION=latest

LABEL org.opencontainers.image.title="pi-coding-agent" \
      org.opencontainers.image.description="Pi coding agent CLI (Node 24 / Debian bookworm-slim)" \
      org.opencontainers.image.source="https://github.com/skiyer/pi-docker" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${PI_VERSION}"

# 只装 Pi 运行时真正需要的：bash、证书、git、ripgrep（搜索结果）、fd（文件查找，Pi 会调用）
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash ca-certificates git ripgrep fd-find \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@${PI_VERSION}" \
    && npm cache clean --force

WORKDIR /workspace

ENTRYPOINT ["pi"]
