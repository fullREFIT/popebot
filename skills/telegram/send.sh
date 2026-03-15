#!/usr/bin/env bash
set -euo pipefail

# Send a message to a Telegram chat via Bot API
#
# Usage: send.sh "message text" [chat_id]
#
# Environment:
#   TELEGRAM_BOT_TOKEN  - Required. Bot API token from @BotFather
#   TELEGRAM_CHAT_ID    - Default chat ID (used when chat_id arg is omitted)

MESSAGE="${1:-}"
CHAT_ID="${2:-${TELEGRAM_CHAT_ID:-}}"

if [[ -z "$MESSAGE" ]]; then
  echo "Usage: send.sh \"message text\" [chat_id]" >&2
  exit 1
fi

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  cat >&2 <<'EOF'
Error: TELEGRAM_BOT_TOKEN is not set.

To set up Telegram messaging:
  1. Message @BotFather on Telegram and create a bot with /newbot
  2. Copy the token and set it as an environment variable:
       export TELEGRAM_BOT_TOKEN="your-bot-token"
  3. For the agent, add it as a GitHub secret:
       AGENT_LLM_TELEGRAM_BOT_TOKEN=your-bot-token
EOF
  exit 1
fi

if [[ -z "$CHAT_ID" ]]; then
  cat >&2 <<'EOF'
Error: No chat ID provided.

Pass a chat_id as the second argument or set TELEGRAM_CHAT_ID:
  send.sh "hello" "123456789"
  export TELEGRAM_CHAT_ID="123456789"

To find a chat ID, send a message to your bot then run:
  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates" | jq '.result[0].message.chat.id'
EOF
  exit 1
fi

API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg chat_id "$CHAT_ID" --arg text "$MESSAGE" \
    '{chat_id: $chat_id, text: $text, parse_mode: "Markdown"}')")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]]; then
  echo "Message sent successfully to chat $CHAT_ID"
else
  echo "Failed to send message (HTTP $HTTP_CODE):" >&2
  echo "$BODY" >&2
  exit 1
fi
