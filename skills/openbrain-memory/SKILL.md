---
name: openbrain-memory
description: Proactively use OpenBrain to save and recall thoughts during conversations. Triggers when the user shares insights, makes decisions, learns something new, or works on topics that might have prior context in OpenBrain.
user-invocable: false
allowed-tools: mcp__claude_ai_OpenBrain__save_thought, mcp__claude_ai_OpenBrain__search_thoughts, mcp__claude_ai_OpenBrain__list_thoughts, mcp__claude_ai_OpenBrain__link_thoughts, mcp__claude_ai_OpenBrain__list_tags
---

# OpenBrain Integration

You have access to OpenBrain — a personal knowledge base for thoughts, ideas, and insights. Use it proactively without being asked.

## When to RECALL (search OpenBrain)

- At the start of a non-trivial task, search for prior thoughts on the topic
- When the user mentions a person, project, or concept that might have context stored
- When making architectural or design decisions — check if there are prior thoughts about trade-offs or preferences

Use `search_thoughts` with a natural language query for semantic search. Use `list_thoughts` with filters when looking for thoughts by tag, person, or project.

## When to SAVE (save to OpenBrain)

Save a thought when the conversation surfaces something worth remembering long-term:

- **Decisions & rationale** — why a particular approach was chosen over alternatives
- **Insights & learnings** — something the user figured out or discovered
- **Ideas & plans** — future intentions, feature ideas, project directions
- **Opinions & preferences** — strong views on tools, patterns, approaches
- **People context** — what someone is working on, their expertise, relationship context

Do NOT save:
- Ephemeral task details (use tasks/plans for that)
- Code patterns or conventions (those belong in CLAUDE.md)
- Things already captured in git history
- Trivial or obvious information

## How to structure thoughts

- Write the thought in the user's voice — capture their perspective, not yours
- Keep it concise but include enough context to be useful months later
- Add relevant `tags` for categorization (use existing tags when possible — check with `list_tags` if unsure)
- Add `people` when the thought involves or is about specific people
- Add `projects` when the thought relates to a known project
- Link related thoughts together with `link_thoughts` when you find connections

## Behavior

- Be lightweight about it — briefly mention when you save or recall ("Saved that to OpenBrain" / "Found some prior thoughts on this")
- Don't overwhelm the conversation with OpenBrain activity — one search at the start and saves at natural moments
- If a search returns relevant results, weave them into your response naturally
- When saving, don't ask for permission — just save and mention it. The user wants this to be automatic
