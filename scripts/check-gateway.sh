#!/usr/bin/env bash
# 检查 gongsi gateway 是否在运行并输出可访问的 Control UI 地址
set -e
PROFILE="${OPENCLAW_PROFILE:-gongsi}"
PORT="${OPENCLAW_GATEWAY_PORT:-28790}"

try_url() {
  local url="$1"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "$url" 2>/dev/null || echo "000")
  echo "$code"
}

# 可能提供 Control UI 的地址（按文档：同端口 basePath 或派生端口）
CODE_OPENCLAW=$(try_url "http://127.0.0.1:${PORT}/openclaw/")
CODE_ROOT=$(try_url "http://127.0.0.1:${PORT}/")
PORT_PLUS_ONE=$((PORT + 1))
PORT_PLUS_TWO=$((PORT + 2))
CODE_P1=$(try_url "http://127.0.0.1:${PORT_PLUS_ONE}/")
CODE_P2=$(try_url "http://127.0.0.1:${PORT_PLUS_TWO}/")

if [ "$CODE_OPENCLAW" = "200" ] || [ "$CODE_OPENCLAW" = "302" ]; then
  echo "Control UI (basePath): http://127.0.0.1:${PORT}/openclaw/"
  exit 0
fi
if [ "$CODE_ROOT" = "200" ] || [ "$CODE_ROOT" = "302" ]; then
  echo "Control UI (root):     http://127.0.0.1:${PORT}/"
  exit 0
fi
if [ "$CODE_P1" = "200" ] || [ "$CODE_P1" = "302" ]; then
  echo "Control UI (derived):  http://127.0.0.1:${PORT_PLUS_ONE}/"
  exit 0
fi
if [ "$CODE_P2" = "200" ] || [ "$CODE_P2" = "302" ]; then
  echo "Browser control:       http://127.0.0.1:${PORT_PLUS_TWO}/"
  exit 0
fi

echo "未检测到 gateway 在端口 ${PORT} 响应 (curl 返回 000 表示未连接)。"
echo "请先在一个终端运行："
echo "  openclaw --profile ${PROFILE} gateway"
echo ""
echo "然后再在浏览器访问上述地址之一。"
exit 1
