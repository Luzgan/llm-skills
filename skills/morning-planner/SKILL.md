---
name: morning-planner
description: Generate today's daily plan by gathering context from LifeManager (projects, todos, calendar, yesterday's plan) and creating a focused schedule. Designed to run via /loop for daily planning.
user-invocable: true
allowed-tools: mcp__claude_ai_LifeManager__get_daily_plan, mcp__claude_ai_LifeManager__update_daily_plan, mcp__claude_ai_LifeManager__add_plan_item, mcp__claude_ai_LifeManager__add_schedule_slot, mcp__claude_ai_LifeManager__remove_plan_item, mcp__claude_ai_LifeManager__remove_schedule_slot, mcp__claude_ai_LifeManager__sync_calendar_events, mcp__claude_ai_LifeManager__list_projects, mcp__claude_ai_LifeManager__get_project, mcp__claude_ai_LifeManager__list_tasks, mcp__claude_ai_LifeManager__list_todos
---

# Morning Planner

Generate today's daily plan using context from LifeManager.

## Step 0: Time check

This skill is designed to run in the morning. Check the current UTC time — only proceed if it's between **05:00 and 09:00 UTC**. If outside this window, respond with "Skipping — not morning yet" and stop immediately. Do not call any MCP tools.

## Step 1: Check if plan already exists

1. Call `get_daily_plan` for today's date
2. If the plan already has auto-generated schedule slots (source = "auto"), skip — plan was already generated today
3. If the plan is empty or only has manual/calendar items, proceed

## Step 2: Sync calendar

1. Call `sync_calendar_events` for today's date to pull in Google Calendar events
2. Then call `get_daily_plan` again to see the updated calendar slots

## Step 3: Gather context

Collect context from these sources:

1. **Active projects** — call `list_projects` (state: in_progress), then `list_tasks` for each to see active tasks
2. **Pending todos** — call `list_todos` (status: todo or in_progress) to see what's due
3. **Yesterday's plan** — call `get_daily_plan` for yesterday's date to see what was completed, what wasn't, and any end-of-day comments

## Step 4: Generate the plan

Based on the gathered context, create a focused, achievable daily plan:

### Plan items (checklist)
- 5-10 items max
- Prioritize high-priority and overdue todos
- Carry over incomplete items from yesterday if still relevant
- Include project tasks that are in progress
- Each item should be actionable and specific

### Schedule slots
- Add time-blocked slots for focused work using `add_schedule_slot` with source "auto"
- Don't overlap with existing calendar events
- Use 24-hour time format (e.g., "09:00", "14:30")
- Include breaks and buffer time
- Be realistic about how long things take

### Notes
- Update the plan notes via `update_daily_plan` with a 1-2 sentence overview of today's focus

## Step 5: Write the plan

1. Remove any existing auto-generated items (items from a previous auto-generation)
2. Remove any existing auto-generated schedule slots (source = "auto")
3. Add the new plan items via `add_plan_item` with sequential positions
4. Add the new schedule slots via `add_schedule_slot` with source "auto"
5. Update the plan notes via `update_daily_plan`

## Guidelines

- Keep the plan realistic — it's better to plan less and complete everything than overcommit
- Respect calendar events — they're fixed commitments
- If yesterday's comments mention being overwhelmed or behind, plan a lighter day
- If yesterday had many incomplete items, prioritize the most important ones rather than carrying everything over
- Be concise in item descriptions — these show up in a checklist UI
