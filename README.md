# Formance Ledger Kubernetes 部署

## 项目概述

本项目提供了在 Kubernetes 集群中部署 Formance Ledger 及其相关组件的配置。它利用 Kubernetes 的声明式配置来管理 Ledger 核心服务、数据库、API 代理和 Wallets 服务。

## 架构与组件

系统部署在 `formance` 命名空间下，主要包含以下组件：

*   **Ledger (`ledger`):** 核心账本服务，使用 `ghcr.io/formancehq/ledger:latest` 镜像，负责处理和记录金融交易。
*   **Ledger Worker (`ledger-worker`):** `ledger` 服务的辅助工作进程，使用相同镜像，用于执行后台任务。
*   **PostgreSQL (`postgres`):** 使用 `postgres:16-alpine` 镜像的数据库实例，为 `ledger` 服务提供持久化存储（数据库名：`ledger`）。数据通过 PersistentVolumeClaim 持久化。
*   **Nginx Proxy (`ledger-proxy`):** 作为 `ledger` 服务 API 的反向代理入口。监听 80 端口，将 `/api/ledger/` 路径的请求转发给 `ledger` 服务（端口 3068）。
*   **Wallets (`wallets`):** 使用 `ghcr.io/formancehq/wallets:latest` 镜像的独立服务，用于管理用户钱包。它通过 `ledger-proxy` 与 `ledger` 服务交互，并通过 NodePort 服务类型暴露在集群外部（监听 8080 端口）。

配置信息通过 Kubernetes Secrets 进行管理。

## 部署

确保您已连接到目标 Kubernetes 集群，并且拥有在 `formance` 命名空间下创建资源的权限。

1.  **创建命名空间 (如果不存在):**
    ```bash
    kubectl create namespace formance
    ```
2.  **应用配置:**
    在包含所有 `.yaml` 文件的目录下执行以下命令：
    ```bash
    kubectl apply -f . -n formance
    ```
    这将创建所有必要的 Deployment、Service、ConfigMap、Secret 和 PersistentVolumeClaim。
