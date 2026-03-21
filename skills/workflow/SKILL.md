---
name: workflow
description: Enforces a feature-branch Git workflow — work on branches, commit meaningfully, create PRs, and only merge with user approval. Triggers on any code changes or when the user asks to implement something.
user-invocable: false
allowed-tools: Bash
---

# Git Workflow

Follow this workflow for ALL code changes. Never commit directly to main.

## 1. Feature Branch

Before making any changes, create a feature branch from main:

```
git checkout -b feat/short-description
```

Use prefixes: `feat/`, `fix/`, `refactor/`, `chore/` as appropriate.

## 2. Commit Meaningful Work

Commit as you go — don't wait until everything is done:

- Commit after completing a logical unit of work (new file, working feature, bug fix)
- Write clear commit messages that explain **what** and **why**
- Stage specific files, not `git add .`

## 3. Create a PR

When the feature is complete:

- Push the branch: `git push -u origin <branch>`
- Create a PR with `gh pr create` — include a summary and test plan
- Do NOT merge automatically

## 4. Merge Only With Permission

After creating the PR, ask the user if they want to merge. Only merge when explicitly approved:

```
gh pr merge <number> --squash --delete-branch
```

## Behavior

- If you realize mid-conversation you forgot to branch, stop, create the branch, and continue — don't keep committing to main
- If a project's CLAUDE.md has its own workflow instructions, defer to those for project-specific details but still follow the branch/PR pattern
- This workflow applies to every repository, not just specific projects
