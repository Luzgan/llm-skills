---
name: lifemanager-projects
description: Proactively keep LifeManager project descriptions up to date as development progresses. Triggers when working on a project that is tracked in LifeManager — updates descriptions with recent changes, new features, and current state.
user-invocable: false
allowed-tools: mcp__claude_ai_LifeManager__list_projects, mcp__claude_ai_LifeManager__get_project, mcp__claude_ai_LifeManager__search_projects, mcp__claude_ai_LifeManager__update_project, mcp__claude_ai_LifeManager__create_project, mcp__claude_ai_OpenBrain__search_thoughts, mcp__claude_ai_OpenBrain__list_thoughts
---

# LifeManager Projects Integration

You have access to LifeManager — a project tracker. Use it proactively to keep project information current without being asked.

## When to LOOK UP a project

- At the start of a coding session, search for the current project by name or GitHub URL to load context
- When the user references a project by name, check if it's tracked

Use `search_projects` with the repo name or project name. Use `list_projects` to see all tracked projects.

## When to UPDATE a project

Update the project description when meaningful work is completed:

- **New features** added or shipped
- **Architecture changes** — new modules, major refactors, tech stack changes
- **State changes** — project moved from idea to in_progress, or vice versa
- **Deployment changes** — new hosting, CI/CD, domain changes

Do NOT update for:
- Minor bug fixes or typos
- Work-in-progress that hasn't landed yet
- Changes that don't affect the project's high-level description

## How to write descriptions

- Use markdown for structure
- Lead with a one-line summary of what the project is
- Follow with key features, tech stack highlights, and current status
- Keep it concise — this is a living overview, not a changelog
- Append or revise existing content rather than replacing everything

## When to CREATE a project

If the user is working on a project that isn't tracked yet, create it with:
- A clear `name`
- A `description` summarizing what it does
- The `github_url` if available
- `state`: `in_progress` if actively being developed, `idea` if just exploring

## Behavior

- Be lightweight — briefly mention when you update ("Updated the LifeManager project description")
- Don't update on every small change — batch updates at natural milestones (end of a feature, after a merge)
- When you look up a project at the start, weave relevant context into your work naturally
