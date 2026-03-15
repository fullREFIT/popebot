#!/bin/bash
# PopeBot Stop Script
echo "Stopping PopeBot..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
pkill -f "cloudflared tunnel" 2>/dev/null || true
echo "PopeBot stopped."
