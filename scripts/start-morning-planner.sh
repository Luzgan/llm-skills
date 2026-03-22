#!/usr/bin/env bash
set -euo pipefail

# Start Claude Code in a screen session running /loop with morning-planner.
# Usage: ./scripts/start-morning-planner.sh
#
# Requires: claude (Claude Code CLI), screen

SESSION_NAME="morning-planner"
LOOP_INTERVAL="3h"

# Ensure required commands exist
for cmd in claude screen; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd not found in PATH" >&2
        exit 1
    fi
done

# Kill existing session if running
if screen -list 2>/dev/null | grep -q "$SESSION_NAME"; then
    echo "Stopping existing $SESSION_NAME session..."
    screen -S "$SESSION_NAME" -X quit 2>/dev/null || true
    sleep 2
fi

echo "Starting $SESSION_NAME screen session (loop every $LOOP_INTERVAL)..."

# Allowed tools — only what the morning-planner skill needs
ALLOWED_TOOLS=(
    "Skill"
    "mcp__claude_ai_LifeManager__get_daily_plan"
    "mcp__claude_ai_LifeManager__update_daily_plan"
    "mcp__claude_ai_LifeManager__add_plan_item"
    "mcp__claude_ai_LifeManager__add_schedule_slot"
    "mcp__claude_ai_LifeManager__remove_plan_item"
    "mcp__claude_ai_LifeManager__remove_schedule_slot"
    "mcp__claude_ai_LifeManager__sync_calendar_events"
    "mcp__claude_ai_LifeManager__list_projects"
    "mcp__claude_ai_LifeManager__get_project"
    "mcp__claude_ai_LifeManager__list_tasks"
    "mcp__claude_ai_LifeManager__list_todos"
)

# Start Claude Code interactively inside screen
# --dangerously-skip-permissions: skips the workspace trust dialog (required for unattended use)
# --allowed-tools: restricts which tools are actually available (independent of permission bypass)
screen -dmS "$SESSION_NAME" "$(command -v claude)" \
    --dangerously-skip-permissions \
    --allowed-tools "${ALLOWED_TOOLS[@]}"

# Wait for Claude to initialize
sleep 10

# Send the /loop command to the interactive session
screen -S "$SESSION_NAME" -X stuff "/loop ${LOOP_INTERVAL} /morning-planner\n"

echo "Screen session '$SESSION_NAME' started."
echo "  Attach: screen -r $SESSION_NAME"
echo "  Check:  screen -list | grep $SESSION_NAME"
