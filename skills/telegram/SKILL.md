---
name: telegram
description: Send messages to Telegram chats via Bot API
---

# Telegram Messaging

Send messages to Telegram chats using the Telegram Bot API.

## Send a Message

```bash
skills/telegram/send.sh "Your message here"
```

With a specific chat ID:

```bash
skills/telegram/send.sh "Your message here" "CHAT_ID"
```

If no chat ID is provided, the script falls back to `$TELEGRAM_CHAT_ID`.

## Required Environment Variables

| Variable | Description |
|----------|-------------|
| `TELEGRAM_BOT_TOKEN` | Bot API token from [@BotFather](https://t.me/BotFather) |
| `TELEGRAM_CHAT_ID` | Default chat ID (optional if always passing chat_id argument) |

## Setup

1. Message [@BotFather](https://t.me/BotFather) on Telegram and create a bot with `/newbot`
2. Copy the bot token and set it as `TELEGRAM_BOT_TOKEN`
3. To find a chat ID, send a message to your bot, then run:
   ```bash
   curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates" | jq '.result[0].message.chat.id'
   ```
4. Set the chat ID as `TELEGRAM_CHAT_ID` or pass it as the second argument

### For the agent environment

Add secrets via GitHub repo settings:
- `AGENT_LLM_TELEGRAM_BOT_TOKEN` — makes `$TELEGRAM_BOT_TOKEN` available to the agent
- `AGENT_TELEGRAM_CHAT_ID` — or set `TELEGRAM_CHAT_ID` in the event handler `.env`

## When to Use

- When you need to send a notification or message to a Telegram user or group
- When reporting job results or alerts to Telegram
- When a task explicitly asks to message someone on Telegram
