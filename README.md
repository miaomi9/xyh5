# 梦幻西游H5 Docker部署

## 快速部署

### 1. 修改配置

编辑 `docker-compose.yml`，修改 `SERVER_IP` 为你的服务器IP：

```yaml
environment:
  - SERVER_IP=你的服务器IP
```

### 2. 一键启动

```bash
cd docker
docker-compose up -d --build
```

### 3. 验证

- 游戏: `http://你的IP:8085/cdn/`
- GM: `http://你的IP:8085/gm/` (admin/123456)

## GitHub Actions 自动部署

### 1. 上传GitHub

```bash
cd docker
git init
git add .
git commit -m "Initial commit"
gh repo create xyh5 --public --push
```

### 2. 配置Secrets

在GitHub仓库Settings > Secrets中添加：

| Name | Value |
|------|-------|
| SERVER_HOST | 服务器IP |
| SERVER_USER | 服务器用户名 |
| SERVER_SSH_KEY | 服务器SSH私钥 |

### 3. 自动部署

推送代码后会自动构建Docker镜像并部署到服务器。

## 端口

| 宿主机 | 容器 | 用途 |
|--------|------|------|
| 8085 | 80 | Web服务 |
| 3306 | 3306 | MySQL |
| 8001 | 8001 | 基础服务 |
| 8002 | 8002 | Web服务 |
| 8004 | 8004 | GM服务 |
| 10001 | 10001 | 游戏服务 |
| 11001 | 11001 | 数据分析 |
| 12001 | 12001 | 世界服务 |

## 命令

```bash
docker-compose up -d      # 启动
docker-compose down       # 停止
docker logs -f xyh5     # 查看日志
docker exec -it xyh5 sh  # 进入容器
```
