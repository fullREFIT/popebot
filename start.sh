#!/bin/bash
# PopeBot Startup Script
# Usage: ./start.sh
# Starts Cloudflare Tunnel + Next.js dev server
# Permanent URL: https://bot.fullrefit.net

set -e
cd "$(dirname "$0")"

echo "Starting PopeBot..."

# Override any shell-level TELEGRAM_BOT_TOKEN (e.g. from mcp.env)
# to ensure PopeBot uses its own token from .env
export TELEGRAM_BOT_TOKEN=8434863540:AAE-EtgROLzN5To6HF6eA-AVXdNjwt6_eII

# Kill existing processes
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 2

# Start the Next.js dev server
echo "Starting dev server..."
npm run dev > /tmp/popebot-dev.log 2>&1 &

# Wait for dev server to be ready
echo "Waiting for dev server..."
for i in {1..30}; do
  if curl -s http://localhost:3000/api/ping > /dev/null 2>&1; then
    echo "Dev server ready."
    break
  fi
  sleep 1
done

# Start Cloudflare Tunnel
echo "Starting Cloudflare Tunnel..."
cloudflared tunnel run popebot > /tmp/cloudflared.log 2>&1 &
sleep 4

# Verify tunnel is working
if curl -s https://bot.fullrefit.net/api/ping > /dev/null 2>&1; then
  echo "Tunnel connected."
else
  echo "WARNING: Tunnel may still be connecting. Check /tmp/cloudflared.log"
fi

echo ""
echo "=================================="
echo "PopeBot is running!"
echo "=================================="
echo "Web UI:    https://bot.fullrefit.net/login"
echo "API:       https://bot.fullrefit.net/api/ping"
echo "Telegram:  Connected"
echo ""
echo "Logs:      tail -f /tmp/popebot-dev.log"
echo "Tunnel:    tail -f /tmp/cloudflared.log"
echo "Stop:      ./stop.sh"
echo "=================================="
