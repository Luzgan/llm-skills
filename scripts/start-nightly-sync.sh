#!/usr/bin/env bash
set -euo pipefail

# Start Claude Code in a screen session running /loop with nightly-sync.
# Usage: ./scripts/start-nightly-sync.sh
#
# Requires: claude (Claude Code CLI), screen, gh (GitHub CLI)

SESSION_NAME="nightly-sync"
LOOP_INTERVAL="24h"

# Ensure required commands exist
for cmd in claude screen gh; do
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

# Allowed tools — only what the nightly-sync skill needs
ALLOWED_TOOLS=(
    "Bash(gh:*)"
    "Bash(python3:*)"
    "Skill"
    "mcp__claude_ai_LifeManager__list_projects"
    "mcp__claude_ai_LifeManager__get_project"
    "mcp__claude_ai_LifeManager__update_project"
    "mcp__claude_ai_LifeManager__list_tasks"
    "mcp__claude_ai_LifeManager__get_task"
    "mcp__claude_ai_LifeManager__update_task"
    "mcp__claude_ai_LifeManager__get_daily_plan"
    "mcp__claude_ai_OpenBrain__save_thought"
    "mcp__claude_ai_OpenBrain__search_thoughts"
    "mcp__claude_ai_OpenBrain__list_tags"
)

# Start Claude Code interactively inside screen with only allowed tools
screen -dmS "$SESSION_NAME" "$(command -v claude)" \
    --allowed-tools "${ALLOWED_TOOLS[@]}"

# Wait for Claude to initialize
sleep 10

# Send the /loop command to the interactive session
screen -S "$SESSION_NAME" -X stuff "/loop ${LOOP_INTERVAL} /nightly-sync\n"

echo "Screen session '$SESSION_NAME' started."
echo "  Attach: screen -r $SESSION_NAME"
echo "  Check:  screen -list | grep $SESSION_NAME"
