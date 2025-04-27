#!/bin/bash

# 定义变量
SERVICE_NAME="wallets"
NAMESPACE="formance"
LOCAL_PORT=8180
REMOTE_PORT=8080
LOG_FILE="/tmp/wallet_port_forward.log"
PID_FILE="/tmp/wallet_port_forward.pid"

# 帮助函数
show_help() {
  echo "用法: $0 [命令]"
  echo "命令:"
  echo "  start   - 启动端口转发"
  echo "  stop    - 停止端口转发"
  echo "  restart - 重启端口转发"
  echo "  status  - 检查端口转发状态"
  echo "  logs    - 显示端口转发日志"
  echo "  help    - 显示此帮助信息"
}

# 检查是否正在运行
is_running() {
  if [ -f ${PID_FILE} ]; then
    PID=$(cat ${PID_FILE})
    if ps -p ${PID} > /dev/null; then
      return 0
    fi
  fi
  return 1
}

# 启动端口转发
start() {
  if is_running; then
    echo "端口转发已经在运行中 (PID: $(cat ${PID_FILE}))"
    return 0
  fi
  
  echo "启动端口转发: 本地 ${LOCAL_PORT} -> ${SERVICE_NAME}:${REMOTE_PORT}"
  nohup kubectl -n ${NAMESPACE} port-forward svc/${SERVICE_NAME} ${LOCAL_PORT}:${REMOTE_PORT} --address 0.0.0.0 > ${LOG_FILE} 2>&1 &
  
  PID=$!
  echo ${PID} > ${PID_FILE}
  echo "端口转发已在后台启动 (PID: ${PID})"
  echo "日志文件: ${LOG_FILE}"
  echo "可以通过 http://<主机IP>:${LOCAL_PORT} 访问服务"
  echo "注意：需要确保防火墙允许 ${LOCAL_PORT} 端口访问"
}

# 停止端口转发
stop() {
  if is_running; then
    PID=$(cat ${PID_FILE})
    echo "停止端口转发 (PID: ${PID})..."
    kill ${PID}
    rm -f ${PID_FILE}
    echo "端口转发已停止"
  else
    echo "端口转发未在运行"
  fi
}

# 查看日志
logs() {
  if [ -f ${LOG_FILE} ]; then
    echo "显示端口转发日志:"
    cat ${LOG_FILE}
  else
    echo "日志文件不存在: ${LOG_FILE}"
  fi
}

# 检查端口转发状态
status() {
  if is_running; then
    PID=$(cat ${PID_FILE})
    echo "端口转发正在运行 (PID: ${PID})"
    echo "从本地端口 ${LOCAL_PORT} 转发到 ${SERVICE_NAME}:${REMOTE_PORT}"
  else
    echo "端口转发未在运行"
  fi
}

# 主逻辑
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    sleep 1
    start
    ;;
  status)
    status
    ;;
  logs)
    logs
    ;;
  help|*)
    show_help
    ;;
esac

exit 0
