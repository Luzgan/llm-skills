#!/usr/bin/env bash
set -euo pipefail

# Run nightly project sync via Claude CLI in non-interactive mode.
# Scheduled via systemd timer to run every 3h, self-gates to 20:00-23:59 UTC.
#
# Requires: claude, gh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_CONFIG="$SCRIPT_DIR/mcp-servers.json"
LOG_FILE="$HOME/logs/nightly-sync.log"
mkdir -p "$(dirname "$LOG_FILE")"

HOUR=$(date -u +%H)
if [ "$HOUR" -lt 20 ]; then
    echo "$(date -u '+%Y-%m-%d %H:%M:%S') Skipping — not evening yet (UTC hour: $HOUR)" >> "$LOG_FILE"
    exit 0
fi

ALLOWED_TOOLS=(
    "Bash(gh:*)"
    "Bash(python3:*)"
    "mcp__life-manager__list_projects"
    "mcp__life-manager__get_project"
    "mcp__life-manager__update_project"
    "mcp__life-manager__list_tasks"
    "mcp__life-manager__get_task"
    "mcp__life-manager__update_task"
    "mcp__life-manager__get_daily_plan"
    "mcp__openbrain__save_thought"
    "mcp__openbrain__search_thoughts"
    "mcp__openbrain__list_tags"
    "mcp__openbrain__list_projects"
    "mcp__openbrain__link_thoughts"
)

PROMPT='You are a nightly automation that keeps project tracking systems up to date.

Fetch recent GitHub commits (last 3 days) and update LifeManager projects and OpenBrain.

## Step 1: Gather Recent Commits

Run this command to find repos with recent pushes:

```bash
gh repo list Luzgan --limit 100 --json name,pushedAt,description,url | python3 -c "
import json, sys
from datetime import datetime, timedelta, timezone
cutoff = datetime.now(timezone.utc) - timedelta(days=3)
repos = json.loads(sys.stdin.read())
recent = [r for r in repos if datetime.fromisoformat(r['"'"'pushedAt'"'"'].replace('"'"'Z'"'"','"'"'+00:00'"'"')) >= cutoff]
print(json.dumps(recent))
"
```

For each repo, fetch commits:

```bash
gh api repos/Luzgan/{REPO_NAME}/commits --jq '"'"'[.[] | select(.commit.author.date >= "{SINCE_DATE}") | {"sha": .sha[0:7], "message": .commit.message, "date": .commit.author.date}]'"'"'
```

Where {SINCE_DATE} is 3 days ago in ISO format.

## Step 2: Read today'"'"'s daily plan

Call get_daily_plan for today to understand what was planned.

## Step 3: Update LifeManager Projects

1. Call list_projects to get all current projects
2. For each repo with recent commits, match to a LifeManager project by name
3. Update descriptions if commits represent meaningful progress
4. List tasks for matched projects and update task status if commits clearly complete them
5. Preserve core descriptions — just update the recent state

## Step 4: Save Development Log to OpenBrain

1. Save a single thought summarizing development activity
2. Tag with "development-log" and project names
3. Include what was worked on, key decisions, planned vs actual work
4. Keep it concise

Be brief in output. If no recent commits, just say so and stop.'

echo "$(date -u '+%Y-%m-%d %H:%M:%S') Starting nightly sync..." >> "$LOG_FILE"

claude -p "$PROMPT" \
    --mcp-config "$MCP_CONFIG" \
    --allowed-tools "${ALLOWED_TOOLS[*]}" \
    --model sonnet \
    --output-format text \
    >> "$LOG_FILE" 2>&1

echo "$(date -u '+%Y-%m-%d %H:%M:%S') Nightly sync completed." >> "$LOG_FILE"
