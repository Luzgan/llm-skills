---
name: nightly-sync
description: Fetch recent GitHub commits and update LifeManager project descriptions and OpenBrain with development activity. Designed to run via /loop for periodic syncing.
user-invocable: true
allowed-tools: Bash, mcp__claude_ai_LifeManager__list_projects, mcp__claude_ai_LifeManager__get_project, mcp__claude_ai_LifeManager__update_project, mcp__claude_ai_OpenBrain__save_thought, mcp__claude_ai_OpenBrain__search_thoughts, mcp__claude_ai_OpenBrain__list_tags
---

# Nightly Project Sync

Sync recent GitHub activity into LifeManager and OpenBrain.

## Step 1: Gather Recent Commits

Run this Bash command to get commits from the last 3 days across all GitHub repos:

```bash
gh repo list Luzgan --limit 100 --json name,pushedAt,description,url | \
  python3 -c "
import json, sys
from datetime import datetime, timedelta, timezone
cutoff = datetime.now(timezone.utc) - timedelta(days=3)
repos = json.loads(sys.stdin.read())
recent = [r for r in repos if datetime.fromisoformat(r['pushedAt'].replace('Z','+00:00')) >= cutoff]
print(json.dumps(recent))
"
```

For each repo returned, fetch its commits:

```bash
gh api repos/Luzgan/{REPO_NAME}/commits --jq '[.[] | select(.commit.author.date >= "{SINCE_DATE}") | {"sha": .sha[0:7], "message": .commit.message, "date": .commit.author.date}]'
```

Where `{SINCE_DATE}` is 3 days ago in ISO format (e.g., `2026-03-18T00:00:00Z`).

## Step 2: Update LifeManager Projects

1. Call `list_projects` to get all current projects
2. For each repo with recent commits, match it to a LifeManager project by name
3. If matched, read the current description and decide if it needs updating based on the commits
4. Update the description if the commits represent meaningful progress (new features, bug fixes, architecture changes)

### Update guidelines
- Preserve the project's core description — what it IS and what it DOES
- Append or revise the "current state" / "recent work" section
- Don't overwrite good existing descriptions with less information
- Don't update for trivial changes (typos, minor refactors)
- Keep descriptions concise — this is an overview, not a changelog

## Step 3: Save Development Log to OpenBrain

1. Save a **single thought** summarizing the development activity across all projects
2. Tag it with `development-log` and any other relevant tags
3. Add matching project names to the `projects` field
4. Include:
   - What was worked on
   - Key decisions or patterns (inferred from commit messages)
   - Anything notable or worth remembering
5. Keep it concise but useful for future reference

## Behavior

- Be brief in output — just report what you updated and what you saved
- If there are no recent commits, say so and stop
- Don't create new LifeManager projects — only update existing ones
- If a project has no matching LifeManager entry, skip it
