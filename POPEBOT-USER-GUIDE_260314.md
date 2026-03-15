# PopeBot Complete User Guide

**Version:** 1.2.73 | **Installed:** 2026-03-14 | **Repo:** fullREFIT/popebot
**Permanent URL:** https://bot.fullrefit.net

---

## Table of Contents

1. [What Is PopeBot?](#1-what-is-popebot)
2. [Your Setup](#2-your-setup)
3. [Starting and Stopping](#3-starting-and-stopping)
4. [Web UI Guide](#4-web-ui-guide)
5. [Telegram Integration](#5-telegram-integration)
6. [Creating Jobs (Autonomous Agent Tasks)](#6-creating-jobs)
7. [Agent Clusters (Multi-Agent Teams)](#7-agent-clusters)
8. [Code Workspace (Interactive Claude Code)](#8-code-workspace)
9. [Cron Jobs (Scheduled Automation)](#9-cron-jobs)
10. [Webhook Triggers](#10-webhook-triggers)
11. [Skills (Agent Capabilities)](#11-skills)
12. [Project Examples and Prompt Cookbook](#12-project-examples-and-prompt-cookbook)
13. [Configuration Reference](#13-configuration-reference)
14. [PopeBot vs. VibeOS Claude Code Plugin](#14-popebot-vs-vibeos)
15. [Troubleshooting](#15-troubleshooting)

---

## 1. What Is PopeBot?

PopeBot is an **autonomous AI agent platform** that runs 24/7. Think of it as hiring a team of AI developers that work around the clock, commit their work to GitHub, and notify you when they're done.

### Two-Layer Architecture

```
You (Chat / Telegram / Cron / Webhook / API)
        │
        ▼
┌─────────────────────┐
│   Event Handler     │  ← Next.js server (your local machine or VPS)
│   - Web UI          │     Handles chat, scheduling, job dispatch
│   - Telegram bot    │
│   - Cron scheduler  │
│   - Webhook router  │
└────────┬────────────┘
         │ creates job/<uuid> branch
         ▼
┌─────────────────────┐
│   GitHub Actions    │  ← Free compute (2,000 min/month)
│   - Spins up Docker │
│   - Runs LLM agent  │
│   - Agent does work  │
│   - Commits results  │
│   - Opens PR         │
│   - Auto-merges      │
│   - Notifies you     │
└─────────────────────┘
```

**The core loop:** You describe a task -> PopeBot creates a git branch -> GitHub Actions spins up a Docker container -> the LLM agent does the work autonomously -> commits results -> opens a PR -> auto-merges -> notifies you via web UI and Telegram.

### What Makes It Different

- **The repository IS the agent.** Every action is a git commit. Full history, full auditability, full reversibility.
- **Free compute.** GitHub Actions doesn't charge for public repos. Private repos get 2,000 free minutes/month.
- **Self-evolving.** The agent can modify its own code, personality, skills, and cron jobs through PRs.
- **You only pay for LLM API calls** (your Anthropic key).

---

## 2. Your Setup

| Component | Value |
|-----------|-------|
| **Web UI** | https://bot.fullrefit.net |
| **GitHub Repo** | fullREFIT/popebot |
| **GitHub User** | fullREFIT |
| **Tunnel** | Cloudflare Tunnel (permanent) |
| **LLM Provider** | Anthropic (Claude) |
| **Telegram Bot** | Connected |
| **Project Directory** | `/Users/paul/dev-4/pope-bot/popebot-fresh/` |

---

## 3. Starting and Stopping

### Start Everything

```bash
cd /Users/paul/dev-4/pope-bot/popebot-fresh
./start.sh
```

This starts the Next.js dev server + Cloudflare Tunnel. Your bot is immediately available at https://bot.fullrefit.net.

### Stop Everything

```bash
./stop.sh
```

### Check If Running

```bash
curl -s https://bot.fullrefit.net/api/ping
# Should return: {"message":"Pong!"}
```

### View Logs

```bash
# Dev server logs
tail -f /tmp/popebot-dev.log

# Tunnel logs
tail -f /tmp/cloudflared.log
```

---

## 4. Web UI Guide

Access at **https://bot.fullrefit.net**

### Pages Overview

| Page | URL | Purpose |
|------|-----|---------|
| **Chat** | `/` | Main interface -- talk to the agent, plan and dispatch jobs |
| **Chat History** | `/chats` | View and resume past conversations |
| **Clusters** | `/clusters` | Create and manage multi-agent teams |
| **Code Workspace** | `/code/[id]` | Live Claude Code terminal in your browser |
| **Runners** | `/runners` | Monitor running and queued agent jobs |
| **Pull Requests** | `/pull-requests` | View job PRs on GitHub |
| **Notifications** | `/notifications` | Job completion and failure alerts |
| **Settings > Crons** | `/settings/crons` | Create/edit scheduled jobs |
| **Settings > Triggers** | `/settings/triggers` | Create/edit webhook triggers |
| **Settings > Secrets** | `/settings/secrets` | Manage API keys |

### Chat Interface

The chat is your primary way to interact with PopeBot. Through conversation you can:

- **Ask questions** -- the LLM responds using the personality defined in `config/SOUL.md`
- **Plan tasks** -- describe what you want, the LLM helps you scope it into a concrete job description
- **Dispatch jobs** -- once you approve a plan, the LLM calls `create_job` to launch a Docker agent
- **Check status** -- ask "what's running?" or "any updates?"
- **Web search** -- if Brave Search is activated, the LLM can search the web during conversation

### Typical Chat Flow

```
You: "I want to add a dark mode toggle to the settings page"

PopeBot: "I can help with that. Here's what I'd have the agent do:
1. Add a dark mode toggle component to the settings page
2. Store the preference in localStorage
3. Apply the theme using CSS variables
4. Test that it works across all pages

Shall I create a job for this?"

You: "Yes, go ahead"

PopeBot: "Job created! ID: abc-123. The agent is starting up now.
I'll notify you when it's done."

[5-15 minutes later]

PopeBot: "Job abc-123 completed! The agent added dark mode support.
PR #4 has been auto-merged. Here's what changed: ..."
```

---

## 5. Telegram Integration

Your Telegram bot mirrors the web chat. Everything you can do in the web UI, you can do from Telegram.

### What You Can Do

- Send any message to chat with the agent
- Receive job completion/failure notifications
- Plan and dispatch jobs from your phone
- Check job status on the go

### Verifying the Connection

```bash
curl -s "https://api.telegram.org/bot8434863540:AAE-EtgROLzN5To6HF6eA-AVXdNjwt6_eII/getWebhookInfo" | python3 -m json.tool
```

The `url` field should show `https://bot.fullrefit.net/api/telegram/webhook`.

---

## 6. Creating Jobs (Autonomous Agent Tasks)

Jobs are the fundamental unit of work. Each job gets:
- Its own git branch (`job/<uuid>`)
- Its own Docker container
- Its own pull request
- Automatic notification when done

### Four Ways to Create Jobs

#### 1. Via Chat (Web or Telegram)

Just describe what you want in natural language. The LLM helps you refine it and dispatches the job when you approve.

#### 2. Via API

```bash
curl -X POST https://bot.fullrefit.net/api/create-job \
  -H "x-api-key: tpb_YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"title": "Update README", "job": "Update README.md to document all API endpoints"}'
```

Create API keys in **Settings > Secrets** in the web UI.

#### 3. Via Cron (Scheduled)

Jobs run automatically on a schedule. See [Section 9](#9-cron-jobs).

#### 4. Via Webhook Trigger

Jobs fire in response to external events (GitHub pushes, Stripe payments, etc.). See [Section 10](#10-webhook-triggers).

### What the Agent Can Do Inside a Job

The Docker agent runs with **full capabilities** inside an isolated container:

| Capability | Details |
|-----------|---------|
| **File operations** | Read, write, edit, delete any file in the repo |
| **Bash execution** | Run any command: npm, python, curl, git, etc. |
| **Web browsing** | Headless Chrome for navigation, screenshots, scraping, JS evaluation |
| **Web search** | Brave Search API for real-time information (if activated) |
| **Image generation** | Kie AI for images (1K-4K) and videos (if activated) |
| **YouTube transcripts** | Fetch and parse video transcripts (if activated) |
| **Google Docs/Drive** | Create documents, upload/download files (if activated) |
| **Self-modification** | Edit its own config, personality, cron jobs, triggers, and skills |
| **Skill creation** | Build entirely new skills from scratch during a job |
| **Git operations** | Commit, push, create branches, open PRs |
| **Package management** | Install npm/pip/apt packages as needed |

### Job Lifecycle (Detailed)

```
1. JOB CREATED
   Event handler pushes job/<uuid> branch to GitHub
   Branch contains logs/<uuid>/job.config.json with the task prompt

2. GITHUB ACTIONS TRIGGERED
   run-job.yml workflow fires on job/* branch creation
   Pulls the Docker agent image

3. CONTAINER STARTS
   Exports SECRETS (hidden from LLM) and LLM_SECRETS (visible to LLM)
   Clones the job branch to /job
   Installs skill dependencies
   Starts headless Chrome (if browser-tools active)

4. AGENT RUNS
   System prompt built from config/SOUL.md + config/JOB_AGENT.md
   Agent receives the job description as its task
   Agent works autonomously: reading files, writing code, running commands
   Session logged to logs/<uuid>/

5. RESULTS COMMITTED
   On success: all changes + logs committed
   On failure: only logs committed
   Pushed to the job branch

6. PR CREATED
   Agent opens a pull request against main

7. AUTO-MERGE
   auto-merge.yml checks ALLOWED_PATHS (default: /logs)
   If all changes are within allowed paths: squash-merge
   If not: PR stays open for manual review

8. NOTIFICATION
   notify-pr-complete.yml sends results to event handler
   Event handler creates web notification + Telegram message
   You see the summary of what was done
```

### Auto-Merge Configuration

By default, only changes to `/logs` are auto-merged. To let the agent modify any file:

```bash
gh variable set ALLOWED_PATHS --body "/" --repo fullREFIT/popebot
```

To disable auto-merge entirely:
```bash
gh variable set AUTO_MERGE --body "false" --repo fullREFIT/popebot
```

---

## 7. Agent Clusters (Multi-Agent Teams)

Clusters let you run **multiple AI agents simultaneously**, each with a specialized role, collaborating on a project.

> **Requires:** `CLAUDE_CODE_OAUTH_TOKEN` in your `.env`. This uses your Claude Max subscription instead of API keys.

### How Clusters Work

1. **Create a cluster** in the web UI with a name and system prompt (shared mission/vision/goals)
2. **Define roles** -- each role has its own system prompt, user prompt, and concurrency limit
3. **Configure triggers** -- roles can be triggered manually, by webhook, by cron, or by file watch
4. **Launch workers** from the console
5. **Monitor** real-time progress in the console view

### Role Configuration Options

Each role can have:
- **System prompt** -- defines the role's expertise and behavior
- **User prompt** -- the specific task to execute
- **Concurrency** -- how many workers of this role can run simultaneously
- **Private folders** -- directories created for this role's exclusive use
- **Triggers** -- how the role gets activated (manual, webhook, cron, file watch)
- **Cleanup** -- whether to clean up directories when done

### Communication Between Workers

Workers in a cluster can coordinate through:
- **Shared folders** (inbox, outbox, reports) -- defined at the cluster level
- **GitHub issues and labels** -- one worker adds a label, which triggers another worker
- **Markdown files** -- workers write structured reports that other workers read
- **File watch triggers** -- a worker writes a file, which triggers another worker to start

### Console View

The cluster console (`/cluster/[id]/console`) shows:
- All active workers with real-time status
- Tool calls being made (file reads, bash commands, etc.)
- LLM responses streaming in real-time
- System and user prompts for each worker
- Completed worker logs

---

## 8. Code Workspace (Interactive Claude Code)

The code workspace gives you a **live Claude Code session** in your browser. Unlike jobs (fire-and-forget), this is real-time pair programming.

> **Requires:** `CLAUDE_CODE_OAUTH_TOKEN` in your `.env`.

### How It Works

1. Start a new chat and toggle into **Code Mode**
2. Select the GitHub repository you want to work on
3. Chat with the planning LLM about your task
4. When ready, say "let's start coding" or "go ahead"
5. A Docker container launches with Claude Code accessible in a web terminal
6. Your planning conversation context is automatically injected
7. You interact with Claude Code through the browser -- type commands, approve changes
8. When done, changes are committed to a feature branch and merged back

### Two Modes

| Mode | How It Works | Best For |
|------|-------------|----------|
| **Interactive** | Live web terminal -- you see and interact with Claude Code | Complex tasks, pair programming, tasks needing human judgment |
| **Headless** | Claude Code runs autonomously, you get the result | Simple tasks where you trust the agent to handle it alone |

### Mobile Support

Everything works on mobile. You can:
- Start a coding session on your laptop
- Switch to your phone without any configuration
- Continue interacting from anywhere
- Monitor progress on the go

---

## 9. Cron Jobs (Scheduled Automation)

Cron jobs run tasks on a schedule. Configure in **Settings > Crons** or by editing `config/CRONS.json`.

### Three Action Types

| Type | What It Does | Uses LLM? | Cost |
|------|-------------|-----------|------|
| `agent` | Spins up a Docker container with full LLM agent | Yes | LLM API + GitHub Actions minutes |
| `command` | Runs a shell command on the event handler server | No | Free |
| `webhook` | Makes an HTTP request to an external URL | No | Free |

### Cron Expression Cheat Sheet

| Expression | Meaning |
|-----------|---------|
| `*/5 * * * *` | Every 5 minutes |
| `0 * * * *` | Every hour on the hour |
| `0 9 * * *` | Daily at 9:00 AM |
| `0 9 * * 1-5` | Weekdays at 9:00 AM |
| `0 0 * * 0` | Weekly on Sunday at midnight |
| `0 0 1 * *` | Monthly on the 1st at midnight |
| `30 14 * * *` | Daily at 2:30 PM |

### Pre-Built Cron Jobs (Currently Disabled)

Your install includes several example crons you can enable:

| Name | Schedule | Type | What It Does |
|------|----------|------|-------------|
| heartbeat | Every 30 min | agent | Runs tasks defined in HEARTBEAT.md |
| daily-check | 9am daily | agent | Checks for dependency updates |
| ping | Every 1 min | command | Simple echo "pong!" health check (currently enabled) |
| cleanup-logs | Weekly Sunday | command | Lists log directory |
| ping-status | Every 5 min | webhook | POSTs to a status endpoint |
| health-check | Every 10 min | webhook | GETs a health endpoint |

### Per-Cron LLM Override

You can use a different (cheaper/faster) LLM for specific crons:

```json
{
  "name": "quick-check",
  "schedule": "0 * * * *",
  "type": "agent",
  "job": "Quick status check",
  "llm_provider": "google",
  "llm_model": "gemini-2.5-flash",
  "enabled": true
}
```

---

## 10. Webhook Triggers

Triggers fire actions when external services POST to your endpoints. Configure in **Settings > Triggers** or `config/TRIGGERS.json`.

### How It Works

1. An external service (GitHub, Stripe, Slack, etc.) sends a POST request to a watched path on your PopeBot
2. The trigger fires one or more actions (agent, command, or webhook)
3. Actions can access the incoming request data via template tokens

### Template Tokens

Use these in `job` or `command` strings to inject incoming data:

| Token | Resolves To | Example Value |
|-------|-------------|---------------|
| `{{body}}` | Entire request body as JSON | `{"ref":"refs/heads/main",...}` |
| `{{body.ref}}` | Specific field from body | `refs/heads/main` |
| `{{body.sender.login}}` | Nested field | `octocat` |
| `{{query.param}}` | URL query parameter | `?param=value` -> `value` |
| `{{headers.x-github-event}}` | Request header | `push` |

### Setting Up External Webhooks

For example, to connect a GitHub repo to PopeBot:
1. Create a trigger in PopeBot watching `/webhook/github-push`
2. In your GitHub repo, go to **Settings > Webhooks > Add webhook**
3. Set the Payload URL to `https://bot.fullrefit.net/webhook/github-push`
4. Set Content type to `application/json`
5. Choose which events to send

---

## 11. Skills (Agent Capabilities)

Skills extend what the agent can do inside jobs. They're modular, self-contained tool packages.

### Currently Installed Skills

| Skill | Status | What It Does | API Key Required |
|-------|--------|-------------|-----------------|
| **browser-tools** | **Active** | Navigate web pages, take screenshots, evaluate JavaScript, extract page content, read cookies, pick DOM elements -- all via headless Chrome | None (built-in) |
| **llm-secrets** | **Active** | Lists available API key names (not values) so the agent knows what credentials it has access to | None |
| **modify-self** | **Active** | Meta-skill: instructs the agent to read CLAUDE.md before modifying its own config, personality, crons, or skills | None |
| **brave-search** | Inactive | Web search with result count, freshness, and country filters. Content extraction that converts pages to clean markdown | `BRAVE_API_KEY` |
| **youtube-transcript** | Inactive | Fetch timestamped transcripts from any YouTube video. Works with auto-generated and manual captions | None |
| **google-docs** | Inactive | Create Google Docs on a shared drive via service account | `GOOGLE_SERVICE_ACCOUNT_JSON` + `GOOGLE_SHARED_DRIVE_ID` |
| **google-drive** | Inactive | List, upload, download, and delete files on Google Drive | `GOOGLE_SERVICE_ACCOUNT_JSON` + `GOOGLE_SHARED_DRIVE_ID` |
| **kie-ai** | Inactive | AI image generation (1K/2K/4K, aspect ratios from 1:1 to 21:9, PNG/JPEG/WEBP) and AI video generation | `KIE_AI_API_KEY` |

### How to Activate a Skill

```bash
cd /Users/paul/dev-4/pope-bot/popebot-fresh

# Create symlink to activate
ln -s ../brave-search skills/active/brave-search

# If the skill needs an API key, set it as a GitHub secret
# (AGENT_LLM_ prefix = visible to the LLM agent)
gh secret set AGENT_LLM_BRAVE_API_KEY --body "your-api-key-here" --repo fullREFIT/popebot
```

### How to Deactivate a Skill

```bash
rm skills/active/brave-search
```

### Building Custom Skills

The agent can build its own skills via the `modify-self` meta-skill. Every skill needs:

```
skills/
  my-skill/
    SKILL.md          # Frontmatter with name, description, tools list
    my-tool.js        # Tool script (accepts args, writes to stdout)
    package.json      # If npm dependencies needed
```

**SKILL.md format:**
```yaml
---
name: my-skill
description: What this skill does (shown to the LLM)
tools:
  - name: my-tool
    description: What this specific tool does
    args:
      - name: query
        description: The input to process
        required: true
    script: my-tool.js
---

# Additional instructions for the LLM on how to use this skill
```

See `config/SKILL_BUILDING_GUIDE.md` for the complete specification.

---

## 12. Project Examples and Prompt Cookbook

These are real projects you can build with PopeBot, organized from simple to complex. Each includes the exact prompts to use.

---

### Simple Jobs (Single Agent, 5-15 Minutes)

#### Documentation Generator

Send this in chat or Telegram:

> "Scan the entire codebase and generate comprehensive API documentation. For each endpoint, document the HTTP method, URL, request body schema, response format, authentication requirements, and include curl examples. Write the output to docs/API.md"

#### README Overhaul

> "Read every file in the project. Then rewrite README.md to be comprehensive and professional. Include: project overview, architecture diagram (ASCII art), prerequisites, installation steps, configuration reference, usage examples, troubleshooting section, and contributing guidelines."

#### Dependency Audit

> "Run npm audit, check all dependencies for known vulnerabilities, check if any packages are deprecated or unmaintained (no commits in 12+ months). Write a report to docs/dependency-audit.md with findings and recommended actions."

#### Code Quality Sweep

> "Analyze the entire codebase for: unused imports, dead code, console.log statements left in production code, TODO comments, inconsistent naming conventions, and functions longer than 50 lines. Write a detailed report with file paths and line numbers to docs/code-quality-report.md"

#### License Compliance Check

> "Check every dependency in package.json and package-lock.json for their license types. Flag any GPL, AGPL, or unknown licenses that could create legal issues for a commercial project. Write findings to docs/license-audit.md"

---

### Content and Research Jobs (Single Agent, 10-30 Minutes)

#### Competitive Analysis (requires brave-search skill)

> "Research the top 5 competitors to [YOUR PRODUCT]. For each one, find: pricing, key features, target audience, recent funding/news, and their tech stack (check job postings and GitHub). Write a structured competitive analysis to docs/competitive-analysis.md with a comparison matrix."

#### YouTube Video Summarizer (requires youtube-transcript skill)

> "Fetch the transcript from this YouTube video: [VIDEO_URL]. Create a comprehensive summary with: key points, timestamps for important moments, action items, and any tools/resources mentioned. Write to docs/video-summary.md"

#### Blog Post Generator (requires brave-search skill)

> "Research the topic '[YOUR TOPIC]' using web search. Find the latest statistics, expert opinions, and real-world examples. Then write a 2,000-word blog post that's informative, well-structured, and includes citations. Write to content/blog-post-[topic].md"

#### Market Research Report (requires brave-search skill)

> "Research the [INDUSTRY] market. Find: market size, growth rate, key players, emerging trends, regulatory landscape, and technology adoption patterns. Focus on data from 2025-2026. Write a professional market research report to docs/market-research.md"

---

### Development Jobs (Single Agent, 15-60 Minutes)

#### Add a New Feature

> "Add a dark mode feature to the web UI. Requirements:
> 1. Add a toggle switch in the top navigation bar
> 2. Use CSS custom properties for all colors
> 3. Store the user's preference in localStorage
> 4. Default to the system preference (prefers-color-scheme)
> 5. Ensure all existing pages render correctly in both modes
> 6. Add a smooth transition animation when switching"

#### Build a REST API

> "Create a REST API for managing a todo list. Requirements:
> - Express.js server in api/todos/
> - SQLite database for persistence
> - Endpoints: GET /todos, POST /todos, PUT /todos/:id, DELETE /todos/:id
> - Input validation on all endpoints
> - Error handling with proper HTTP status codes
> - Include a Postman collection for testing
> - Add usage documentation to docs/TODOS_API.md"

#### Refactor Existing Code

> "Refactor the event handler server.js file:
> 1. Extract route handlers into separate files under routes/
> 2. Create a middleware/ directory for shared middleware
> 3. Add proper error handling middleware
> 4. Add request logging with timestamps
> 5. Ensure all existing functionality continues to work
> 6. Update any imports in other files that reference server.js exports"

#### Add Testing

> "Add a comprehensive test suite to the project:
> 1. Install Jest as the test framework
> 2. Write unit tests for every utility function
> 3. Write integration tests for API endpoints
> 4. Aim for >80% code coverage
> 5. Add a test script to package.json
> 6. Add a GitHub Actions workflow that runs tests on every PR"

#### Database Migration

> "Migrate the data storage from JSON files to SQLite:
> 1. Design the schema based on the current JSON structure
> 2. Create migration scripts that preserve existing data
> 3. Update all read/write operations to use the database
> 4. Add proper connection pooling and error handling
> 5. Write a rollback script in case we need to revert
> 6. Document the new schema in docs/DATABASE.md"

---

### Web Scraping and Automation (Single Agent, Browser Skills Required)

#### Price Monitor

> "Navigate to [URL] and extract all product prices. Compare them with the prices stored in data/previous-prices.json. If any prices changed by more than 10%, write a price alert report to data/price-alerts.md and include the old price, new price, and percentage change."

#### Screenshot Audit

> "Navigate to each of these pages and take a full-page screenshot:
> - https://bot.fullrefit.net/
> - https://bot.fullrefit.net/login
> - https://bot.fullrefit.net/settings/crons
> Save screenshots to docs/screenshots/ with descriptive names. Then write a brief UI review noting any visual issues, broken layouts, or accessibility concerns."

#### Form Submission Automation

> "Navigate to [URL], fill in the form with the following data:
> - Name: [value]
> - Email: [value]
> - Message: [value]
> Take a screenshot before and after submission. Write the results to logs/form-submission.md"

---

### Scheduled Automation (Cron Jobs)

#### Daily Changelog

Add to `config/CRONS.json`:

```json
{
  "name": "daily-changelog",
  "schedule": "0 18 * * 1-5",
  "type": "agent",
  "job": "Review all commits made today (since midnight). Write a human-readable changelog entry in docs/changelog.md. Include: what changed, why it matters, and any breaking changes. Append to the existing file, don't overwrite.",
  "enabled": true
}
```

#### Weekly Dependency Update

```json
{
  "name": "weekly-deps",
  "schedule": "0 9 * * 1",
  "type": "agent",
  "job": "Run npm outdated to check for package updates. For each outdated package, check the changelog for breaking changes. If updates are safe (patch or minor with no breaking changes), update them and test that the project still builds. Write a summary of what was updated to docs/dependency-updates.md",
  "enabled": true
}
```

#### Hourly Health Monitor

```json
{
  "name": "health-monitor",
  "schedule": "0 * * * *",
  "type": "webhook",
  "url": "https://bot.fullrefit.net/api/ping",
  "method": "GET",
  "enabled": true
}
```

#### Daily Backup Script

```json
{
  "name": "backup-data",
  "schedule": "0 2 * * *",
  "type": "command",
  "command": "node cron/backup-data.js",
  "enabled": true
}
```

---

### Webhook-Triggered Workflows

#### Auto-Review GitHub Pushes

Add to `config/TRIGGERS.json`:

```json
{
  "name": "review-push",
  "watch_path": "/webhook/github-push",
  "actions": [
    {
      "type": "agent",
      "job": "A push was made to {{body.ref}} by {{body.sender.login}}. Commit message: {{body.head_commit.message}}. Review the changes for: code quality issues, potential bugs, security vulnerabilities, and missing tests. Write your review as a comment on the commit."
    }
  ],
  "enabled": true
}
```

Then in your GitHub repo: Settings > Webhooks > Add > `https://bot.fullrefit.net/webhook/github-push`

#### Slack Notification Relay

```json
{
  "name": "slack-to-job",
  "watch_path": "/webhook/slack",
  "actions": [
    {
      "type": "agent",
      "job": "A message was posted in Slack: {{body.event.text}}. If it contains a task or request, execute it. If it's a question, research the answer and write the response to logs/slack-response.md"
    }
  ],
  "enabled": true
}
```

#### Stripe Payment Handler

```json
{
  "name": "on-payment",
  "watch_path": "/webhook/stripe",
  "actions": [
    {
      "type": "command",
      "command": "echo '{{body.type}}: {{body.data.object.amount}}' >> logs/payments.log"
    },
    {
      "type": "webhook",
      "url": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
      "vars": { "text": "New payment received!" }
    }
  ],
  "enabled": true
}
```

---

### Multi-Agent Cluster Projects (Requires CLAUDE_CODE_OAUTH_TOKEN)

#### Development Team Cluster

Create a cluster with these roles:

**CTO Role:**
- System prompt: "You are the CTO. You review requirements, create technical plans, identify risks, and assign work. You think about architecture, scalability, and maintainability."
- Trigger: Manual or webhook (from GitHub issues)
- User prompt: "Review this feature request and create a detailed technical plan: [FEATURE]. Break it into tasks, identify dependencies, note any security concerns, and assign each task to the appropriate role (security, uiux, or developer)."

**Security Expert Role:**
- System prompt: "You are a security expert. You review technical plans and code for vulnerabilities, data exposure risks, injection attacks, and authentication/authorization issues."
- Trigger: Webhook (triggered when CTO adds 'security' label)
- User prompt: "Review this technical plan for security concerns: {{body.plan}}. Provide a security assessment and list any required mitigations."

**UI/UX Designer Role:**
- System prompt: "You are a UI/UX designer. You review plans for usability, accessibility, responsive design, and user experience. You suggest improvements and create mockup descriptions."
- Trigger: Webhook (triggered when CTO adds 'uiux' label)
- User prompt: "Review this technical plan for UI/UX concerns: {{body.plan}}. Provide design recommendations and accessibility requirements."

**Developer Role:**
- System prompt: "You are a senior developer. You write clean, tested, well-documented code. You follow existing patterns in the codebase."
- Trigger: Webhook (triggered when CTO adds 'code' label)
- User prompt: "Implement the following technical plan: {{body.plan}}. Write the code, add tests, and create a PR."

#### Content Pipeline Cluster

**Researcher Role:**
- System prompt: "You research topics thoroughly using web search. You find statistics, expert quotes, case studies, and recent developments."
- User prompt: "Research [TOPIC] and write a structured research brief to workspace/research/[topic].md"

**Writer Role:**
- System prompt: "You write engaging, well-structured content. You turn research briefs into polished articles."
- Trigger: File watch on `workspace/research/`
- User prompt: "Read the research brief at {{file_path}} and write a polished 2,000-word article. Save to workspace/drafts/"

**Editor Role:**
- System prompt: "You edit content for clarity, grammar, tone consistency, factual accuracy, and SEO optimization."
- Trigger: File watch on `workspace/drafts/`
- User prompt: "Edit the draft at {{file_path}}. Fix errors, improve flow, add SEO-friendly headings. Save the final version to workspace/published/"

---

### Full Application Projects (Complex, Multi-Step)

#### Build a Personal Dashboard

Break this into sequential jobs:

**Job 1 -- Backend:**
> "Create a personal dashboard backend:
> - Express.js API at api/dashboard/
> - SQLite database with tables for: widgets, bookmarks, notes, weather_cache
> - CRUD endpoints for each table
> - A /api/dashboard/weather endpoint that fetches and caches weather data
> - Authentication middleware using JWT
> - Seed data with sample widgets"

**Job 2 -- Frontend:**
> "Create a frontend for the personal dashboard:
> - React components in web/dashboard/
> - Draggable widget grid layout
> - Widget types: clock, weather, bookmarks, notes, recent commits
> - Responsive design (works on mobile)
> - Dark/light mode toggle
> - Connect to the API endpoints created in the previous job"

**Job 3 -- Polish:**
> "Review and polish the personal dashboard:
> - Add loading states and error handling to all components
> - Add animations for widget drag and drop
> - Write a user guide in docs/DASHBOARD.md
> - Add 5 useful default bookmarks
> - Ensure WCAG AA accessibility compliance"

#### Build a CLI Tool

> "Create a command-line tool called 'projstat' that analyzes a git repository and outputs:
> - Total lines of code by language
> - Commit frequency over the last 30 days (ASCII chart)
> - Top 5 contributors by commit count
> - Average PR merge time
> - List of files changed most frequently (potential hotspots)
> - Code complexity score (cyclomatic complexity of top 10 largest files)
>
> Requirements:
> - Node.js with Commander.js for CLI parsing
> - Works on any git repo (pass path as argument)
> - Colorized terminal output with chalk
> - JSON output mode with --json flag
> - Install globally via npm link
> - Include README with usage examples and screenshots"

#### Self-Improving Agent

This is meta -- you tell PopeBot to improve itself:

> "Analyze your own codebase (this repository). Identify the top 3 areas where code quality, performance, or user experience could be improved. For each one, create a detailed plan. Then implement the easiest improvement and create a PR."

> "Create a new skill for yourself that lets you interact with the Airtable API. The skill should support: listing records, creating records, updating records, and deleting records. Follow the pattern established by existing skills like brave-search. Test it by creating a test record in a table."

> "Review your config/SOUL.md personality file. Based on our conversation history and the types of tasks I've given you, suggest improvements to your personality that would make you more helpful for my specific use case. Explain your reasoning for each change."

---

### Prompt Writing Tips

#### Be Specific About Output

Bad: "Write some docs"
Good: "Write API documentation to docs/API.md. For each endpoint, include: HTTP method, URL path, request body JSON schema, example curl command, response format, and error codes."

#### Reference Files By Path

Bad: "Update the config"
Good: "Update config/CRONS.json to add a new daily job that runs at 9am"

#### Specify the Standard

Bad: "Add tests"
Good: "Add Jest unit tests achieving >80% coverage. Mock external API calls. Test both success and error paths."

#### Chain Jobs for Complex Work

Instead of one massive prompt, break it into steps:
1. Job 1: "Create the database schema and migrations"
2. Job 2: "Build the API endpoints using the schema from Job 1"
3. Job 3: "Build the frontend that connects to the API from Job 2"
4. Job 4: "Add tests, error handling, and documentation"

#### Use Operating System Files for Recurring Tasks

Instead of writing long job descriptions inline, create a file in `config/`:

```markdown
# config/WEEKLY_REVIEW.md

## Weekly Code Review Instructions

1. Run `git log --oneline --since="7 days ago"` to see all commits this week
2. For each commit, review the diff for:
   - Code quality issues
   - Potential bugs
   - Missing error handling
   - Security concerns
3. Write a summary report including:
   - Number of commits reviewed
   - Issues found (with file paths and line numbers)
   - Positive patterns worth continuing
   - Recommendations for next week
4. Save the report to docs/weekly-reviews/review-YYYY-MM-DD.md
```

Then your cron job becomes:
```json
{
  "name": "weekly-review",
  "schedule": "0 17 * * 5",
  "type": "agent",
  "job": "Read config/WEEKLY_REVIEW.md and complete the tasks described there.",
  "enabled": true
}
```

---

## 13. Configuration Reference

### Environment Variables (.env)

| Variable | What It Does | Required |
|----------|-------------|----------|
| `APP_URL` | Public URL (https://bot.fullrefit.net) | Yes |
| `APP_HOSTNAME` | Hostname (bot.fullrefit.net) | Yes |
| `AUTH_SECRET` | Session encryption key (auto-generated) | Yes |
| `GH_TOKEN` | GitHub PAT (needs repo + workflow scopes) | Yes |
| `GH_OWNER` | GitHub username (fullREFIT) | Yes |
| `GH_REPO` | Repository name (popebot) | Yes |
| `GH_WEBHOOK_SECRET` | Auth secret for GitHub Actions -> event handler | Yes |
| `LLM_PROVIDER` | `anthropic`, `openai`, `google`, or `custom` | No (default: anthropic) |
| `LLM_MODEL` | Override model name | No (uses provider default) |
| `ANTHROPIC_API_KEY` | Claude API key | For anthropic provider |
| `OPENAI_API_KEY` | OpenAI key (also used for Whisper voice) | For openai provider |
| `GOOGLE_API_KEY` | Google AI key | For google provider |
| `TELEGRAM_BOT_TOKEN` | From @BotFather | For Telegram |
| `TELEGRAM_WEBHOOK_SECRET` | Webhook validation secret | For Telegram |
| `TELEGRAM_CHAT_ID` | Your Telegram chat ID | For notifications |
| `CLAUDE_CODE_OAUTH_TOKEN` | Claude subscription OAuth token | For clusters + code workspace |

### GitHub Repository Secrets

| Secret | Purpose | Visible to Agent? |
|--------|---------|-------------------|
| `AGENT_GH_TOKEN` | Git operations inside Docker | No (filtered) |
| `AGENT_ANTHROPIC_API_KEY` | LLM API calls inside Docker | No (filtered) |
| `GH_WEBHOOK_SECRET` | Auth for GitHub Actions notifications | N/A (workflow only) |
| `AGENT_LLM_BRAVE_API_KEY` | Brave Search skill | Yes (LLM can use) |
| `AGENT_LLM_*` | Any credential the agent needs | Yes (LLM can use) |

**Naming convention:**
- `AGENT_` prefix = hidden from LLM (infrastructure credentials)
- `AGENT_LLM_` prefix = visible to LLM (skill API keys, browser passwords)

### GitHub Repository Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `APP_URL` | (required) | https://bot.fullrefit.net |
| `AUTO_MERGE` | enabled | Set `"false"` to disable auto-merge |
| `ALLOWED_PATHS` | `/logs` | Comma-separated paths for auto-merge. Use `/` for all. |
| `LLM_PROVIDER` | `anthropic` | LLM provider for Docker agent |
| `LLM_MODEL` | (provider default) | Model for Docker agent |
| `RUNS_ON` | `ubuntu-latest` | GitHub Actions runner label |

### Personality and Behavior Files (config/)

| File | What It Controls | Edit When... |
|------|-----------------|-------------|
| `SOUL.md` | Agent personality, identity, values, tone | You want to change how the agent speaks and behaves |
| `JOB_PLANNING.md` | How the chat LLM plans and scopes tasks | You want to change the planning conversation style |
| `JOB_AGENT.md` | Runtime docs injected into Docker agent's system prompt | You want to give the agent different instructions for jobs |
| `JOB_SUMMARY.md` | How job completion notifications are formatted | You want different summary formats |
| `HEARTBEAT.md` | What the heartbeat cron does | You want to change periodic self-check behavior |
| `CODE_PLANNING.md` | System prompt for code workspace planning | You want to change interactive coding flow |
| `CLUSTER_SYSTEM_PROMPT.md` | Shared mission/vision for cluster workers | You're setting up clusters |
| `CLUSTER_ROLE_PROMPT.md` | Per-role template for cluster workers | You're customizing cluster roles |
| `SKILL_BUILDING_GUIDE.md` | Instructions for the agent when building new skills | You want to change how skills are structured |

### Managed Files (DO NOT EDIT)

These are auto-synced by `npx thepopebot upgrade` and will be overwritten:
- `.github/workflows/`
- `docker/event-handler/`
- `docker-compose.yml`
- `.dockerignore`
- `CLAUDE.md`
- `app/`

---

## 14. PopeBot vs. VibeOS Claude Code Plugin

These are fundamentally different tools that complement each other.

### Core Difference

| | PopeBot | VibeOS |
|---|---|---|
| **What it is** | Autonomous AI agent platform | AI-assisted development framework |
| **Runs where** | Docker containers on GitHub Actions (cloud) | Your local machine in Claude Code CLI |
| **Autonomy** | Fully autonomous -- fire and forget | Collaborative -- you approve each step |
| **Interface** | Web UI + Telegram + API | Terminal |
| **Cost** | GitHub Actions minutes + LLM API calls | Your Anthropic subscription |

### Capability Comparison

| Capability | PopeBot | VibeOS |
|-----------|---------|--------|
| Autonomous execution (no supervision) | Yes | No |
| Multi-agent clusters | Yes | No |
| Scheduled jobs (cron) | Yes | No |
| Webhook triggers | Yes | No |
| Web UI dashboard | Yes | No |
| Telegram bot | Yes | No |
| Mobile access | Yes | No |
| Browser automation | Yes (headless Chrome) | No |
| TDD / Test-first development | No | Yes (dedicated tester agent) |
| Architecture audits | No | Yes (6 specialized audit agents) |
| Security audits | No | Yes (OWASP Top 10 scanning) |
| Work order system | No | Yes (phased WO lifecycle) |
| Product discovery | No | Yes (structured discovery) |
| Quality gates | Basic (path-based auto-merge) | Multi-layer (gates + auditors) |
| Git integration | Automatic (branch/PR/merge) | Manual (you commit) |
| Self-modification | Yes (modifies own code via PRs) | No |
| 24/7 operation | Yes | No (runs when you run it) |

### When to Use Each

**Use PopeBot when:**
- You want to fire off a task and walk away
- You need 24/7 scheduled automation
- You want multiple agents working in parallel
- You're on mobile and want to kick off work
- The task is well-defined and doesn't need human judgment mid-stream
- You want the agent to react to external events (webhooks)

**Use VibeOS when:**
- You're actively building and want tight control over each step
- Quality is paramount (TDD, audits, security checks)
- The task requires complex architectural decisions
- You're refactoring and need to understand the codebase deeply
- You want structured project management (phases, work orders)

### Using Them Together (Most Powerful)

1. **VibeOS for design**: Use `/vibeos:discover` and `/vibeos:plan` to define requirements and architecture
2. **PopeBot for execution**: Send the planned work to PopeBot agents to implement
3. **VibeOS for review**: Use `/vibeos:audit` to review PopeBot's output
4. **PopeBot for maintenance**: Set up crons for ongoing monitoring, dependency updates, and health checks
5. **PopeBot clusters for complex features**: CTO plans, Security reviews, Developer implements
6. **VibeOS for critical fixes**: When something breaks and needs careful, audited repair

---

## 15. Troubleshooting

### PopeBot Won't Start

```bash
# Check if port 3000 is in use
lsof -i:3000

# Kill whatever's using it
lsof -ti:3000 | xargs kill -9

# Check dev server logs
cat /tmp/popebot-dev.log
```

### Tunnel Not Working

```bash
# Check tunnel status
pgrep -f cloudflared && echo "Running" || echo "Not running"

# Restart tunnel
pkill -f cloudflared
cloudflared tunnel run popebot > /tmp/cloudflared.log 2>&1 &

# Check tunnel logs
cat /tmp/cloudflared.log

# Test connectivity
curl -s https://bot.fullrefit.net/api/ping
```

### Telegram Bot Not Responding

```bash
# Check webhook status
curl -s "https://api.telegram.org/bot8434863540:AAE-EtgROLzN5To6HF6eA-AVXdNjwt6_eII/getWebhookInfo" | python3 -m json.tool

# Re-register webhook
curl "https://api.telegram.org/bot8434863540:AAE-EtgROLzN5To6HF6eA-AVXdNjwt6_eII/setWebhook" \
  -d "url=https://bot.fullrefit.net/api/telegram/webhook" \
  -d "secret_token=PaulsPopeBot_webhook_9f83hd"
```

### Jobs Not Running

```bash
# Check GitHub Actions
gh run list --repo fullREFIT/popebot --limit 5

# Check if workflows are enabled
gh workflow list --repo fullREFIT/popebot

# Check if secrets are set
gh secret list --repo fullREFIT/popebot
```

### Jobs Fail in GitHub Actions

```bash
# View the failed run logs
gh run list --repo fullREFIT/popebot --status failure --limit 5
gh run view [RUN_ID] --log --repo fullREFIT/popebot
```

Common causes:
- Missing `AGENT_GH_TOKEN` or `AGENT_ANTHROPIC_API_KEY` secrets
- API key expired or rate limited
- Job task too vague for the agent to execute

### Reset Everything

```bash
cd /Users/paul/dev-4/pope-bot/popebot-fresh
./stop.sh
rm -rf data/  # Resets database (will need to create admin account again)
./start.sh
```
