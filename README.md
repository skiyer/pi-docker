# pi-docker

[Pi](https://www.npmjs.com/package/@earendil-works/pi-coding-agent)（终端编码代理）的 Docker 镜像，**上游一发布新版本就自动构建**。

## 镜像

```
ghcr.io/skiyer/pi-docker:<版本>     # 如 ghcr.io/skiyer/pi-docker:0.87.1
ghcr.io/skiyer/pi-docker:latest     # 跟随 npm 最新版
```

- 平台：`linux/amd64`、`linux/arm64`
- 基础镜像：`node:24-bookworm-slim`
- 含工具：bash、ca-certificates、git、ripgrep、curl、jq、procps

## 自动构建流程

`.github/workflows/build.yml` 每天 3 次（UTC 02:17 / 10:17 / 18:17）执行：

1. 查询 npm 上 `@earendil-works/pi-coding-agent` 的最新版本；
2. 检查 GHCR 里是否已有该版本镜像（`docker manifest inspect`）；
3. 只有**不存在**时才构建多架构镜像并推送 `:<版本>`（若该版本是 npm `latest`，同时更新 `:latest`）。

也支持：

- **手动触发**：Actions → Build Pi image → Run workflow，可填指定版本（例如回构建旧版本）。
- **推送到 main 且改动了 `Dockerfile`/工作流**：构建当前最新版。

## 使用

```bash
# 交互式使用（挂载代码目录与配置目录）
docker run --rm -it \
  -v "$PWD":/workspace \
  -v pi-config:/root/.pi \
  ghcr.io/skiyer/pi-docker:latest

# 直接跑一次性提示
docker run --rm -v "$PWD":/workspace ghcr.io/skiyer/pi-docker:latest -p "解释一下这个仓库"
```

以 **root** 运行、工作目录 `/workspace`、配置/凭据在 `/root/.pi`（建议用 named volume 或主机目录挂载持久化）。
API key 等可用环境变量传入，例如 `-e ANTHROPIC_API_KEY=...`（键名以 Pi 官方文档为准），或挂载已有配置文件：

```bash
docker run --rm -it \
  -v "$PWD":/workspace \
  -v "$HOME/.pi/agent:/root/.pi/agent" \
  ghcr.io/skiyer/pi-docker:latest
```

docker compose 示例见 [`examples/docker-compose.yml`](examples/docker-compose.yml)。

## 本地构建

```bash
docker build --build-arg PI_VERSION=0.87.1 -t pi-docker:0.87.1 .
docker run --rm pi-docker:0.87.1 --version
# PI_VERSION 支持任意 npm 版本号或 dist-tag（默认 latest）
```

## 验证

```bash
docker run --rm ghcr.io/skiyer/pi-docker:latest --version   # 应打印对应版本号
docker manifest inspect ghcr.io/skiyer/pi-docker:latest | jq '.manifests[].platform'
```

## 说明

- 镜像只包含 Pi 本体与运行依赖，**不含**任何凭据；凭据请通过挂载或环境变量提供。
- 升级 Pi 无需改本仓库：上游发版后等定时任务（或手动触发）即可。
- 想改检查频率：编辑工作流里的 `cron`。
