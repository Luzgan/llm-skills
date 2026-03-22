#!/usr/bin/env bash
set -euo pipefail

# Run morning planner via Claude CLI in non-interactive mode.
# Scheduled via systemd timer to run every 3h, self-gates to 05:00-09:00 UTC.
#
# Requires: claude

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_CONFIG="$SCRIPT_DIR/mcp-servers.json"
LOG_FILE="$HOME/logs/morning-planner.log"
mkdir -p "$(dirname "$LOG_FILE")"

HOUR=$(date -u +%H)
if [ "$HOUR" -lt 5 ] || [ "$HOUR" -ge 9 ]; then
    echo "$(date -u '+%Y-%m-%d %H:%M:%S') Skipping — not morning yet (UTC hour: $HOUR)" >> "$LOG_FILE"
    exit 0
fi

ALLOWED_TOOLS=(
    "mcp__life-manager__get_daily_plan"
    "mcp__life-manager__update_daily_plan"
    "mcp__life-manager__add_plan_item"
    "mcp__life-manager__add_schedule_slot"
    "mcp__life-manager__remove_plan_item"
    "mcp__life-manager__remove_schedule_slot"
    "mcp__life-manager__sync_calendar_events"
    "mcp__life-manager__list_projects"
    "mcp__life-manager__get_project"
    "mcp__life-manager__list_tasks"
    "mcp__life-manager__list_todos"
)

TODAY=$(date -u +%Y-%m-%d)
YESTERDAY=$(date -u -d "yesterday" +%Y-%m-%d 2>/dev/null || date -u -v-1d +%Y-%m-%d)

PROMPT="You are a morning planner automation. Generate today's daily plan ($TODAY).

## Step 1: Check if plan already exists

Call get_daily_plan for $TODAY. If it already has auto-generated schedule slots (source = \"auto\"), skip — plan was already generated today. Just say \"Plan already exists\" and stop.

## Step 2: Sync calendar

Call sync_calendar_events for $TODAY to pull in Google Calendar events.
Then call get_daily_plan again to see the updated calendar slots.

## Step 3: Gather context

1. Call list_projects (state: in_progress), then list_tasks for each
2. Call list_todos (status: todo or in_progress)
3. Call get_daily_plan for $YESTERDAY to see what was completed and any comments

## Step 4: Generate and write the plan

Based on context, create a focused daily plan:

- Remove any existing auto-generated items and schedule slots (source = \"auto\")
- Add 5-10 checklist items via add_plan_item with sequential positions
- Add time-blocked schedule slots via add_schedule_slot with source \"auto\"
- Update notes via update_daily_plan with a 1-2 sentence focus overview
- Don't overlap with calendar events
- Use 24-hour time format
- Prioritize high-priority and overdue items
- Carry over incomplete items from yesterday if still relevant
- Be realistic — better to complete everything than overcommit

Be brief in output. Just report what you created."

echo "$(date -u '+%Y-%m-%d %H:%M:%S') Starting morning planner..." >> "$LOG_FILE"

claude -p "$PROMPT" \
    --mcp-config "$MCP_CONFIG" \
    --allowed-tools "${ALLOWED_TOOLS[*]}" \
    --model sonnet \
    --output-format text \
    >> "$LOG_FILE" 2>&1

echo "$(date -u '+%Y-%m-%d %H:%M:%S') Morning planner completed." >> "$LOG_FILE"
