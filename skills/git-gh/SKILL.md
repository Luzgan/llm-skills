---
name: git-gh
description: Reference for Git and GitHub CLI (gh) usage — account context, common commands for version control, PRs, issues, checks, releases, and repo management. Complements the workflow skill.
user-invocable: true
allowed-tools: Bash
---

# Git & GitHub CLI Reference

Use `git` for version control and `gh` for all GitHub interactions. Never use the GitHub web UI on behalf of the user.

## Account & Identity

- GitHub account: **Luzgan**
- Always operate as this user — if `gh auth status` shows a different account, alert the user

## Git Commands

### History & Inspection

```bash
# View commit log (concise)
git log --oneline -20

# View log with graph
git log --oneline --graph --all

# Show a specific commit
git show <commit>

# See who changed each line
git blame <file>

# Search commit messages
git log --grep="keyword"

# Find commits that changed a string
git log -S "string" --oneline

# Show changes between branches
git diff main..HEAD
git diff main...HEAD  # changes since branch diverged
```

### Branching & Navigation

```bash
# List branches (local / remote / all)
git branch
git branch -r
git branch -a

# Switch branch
git switch <branch>

# Create and switch
git switch -c <branch>

# Delete a merged branch
git branch -d <branch>

# Rename current branch
git branch -m <new-name>
```

### Stashing

```bash
# Stash current changes
git stash

# Stash with a description
git stash push -m "description"

# List stashes
git stash list

# Apply most recent stash
git stash pop

# Apply a specific stash
git stash pop stash@{n}

# Drop a stash
git stash drop stash@{n}
```

### Rebase & Cherry-pick

```bash
# Rebase current branch onto main
git rebase main

# Continue after resolving conflicts
git rebase --continue

# Abort a rebase
git rebase --abort

# Cherry-pick a commit
git cherry-pick <commit>
```

### Undoing & Fixing

```bash
# Unstage a file
git restore --staged <file>

# Discard working directory changes (confirm with user first)
git restore <file>

# Revert a commit (creates a new commit)
git revert <commit>

# Amend the last commit message (only if not pushed)
git commit --amend
```

### Tags

```bash
# List tags
git tag

# Create annotated tag
git tag -a v1.0.0 -m "description"

# Push tags
git push origin --tags

# Delete a tag
git tag -d <tag>
```

## GitHub CLI Commands

### Pull Requests

```bash
# List open PRs
gh pr list

# View PR details (status, checks, reviews)
gh pr view <number>

# Check CI status on a PR
gh pr checks <number>

# View PR diff
gh pr diff <number>

# Review a PR
gh pr review <number> --approve
gh pr review <number> --request-changes --body "reason"
gh pr review <number> --comment --body "comment"

# Read PR comments and review threads
gh api repos/{owner}/{repo}/pulls/<number>/comments
gh api repos/{owner}/{repo}/pulls/<number>/reviews

# Create PR (see workflow skill for full process)
gh pr create --title "title" --body "body"

# Merge (only with user approval — see workflow skill)
gh pr merge <number> --squash --delete-branch
```

### Issues

```bash
# List issues
gh issue list
gh issue list --assignee @me
gh issue list --label "bug"

# View issue
gh issue view <number>

# Create issue
gh issue create --title "title" --body "body"

# Close issue
gh issue close <number>

# Link PR to issue (use "Closes #N" in PR body)
```

### Repository

```bash
# View repo info
gh repo view

# Clone a repo
gh repo clone Luzgan/<repo>

# Fork a repo
gh repo fork <owner>/<repo>

# Create a new repo
gh repo create Luzgan/<name> --private
gh repo create Luzgan/<name> --public
```

### Releases

```bash
# List releases
gh release list

# Create a release
gh release create <tag> --title "title" --notes "notes"
gh release create <tag> --generate-notes

# Download release assets
gh release download <tag>
```

### CI / Actions

```bash
# List workflow runs
gh run list

# View a specific run
gh run view <run-id>

# Watch a run in progress
gh run watch <run-id>

# Re-run a failed workflow
gh run rerun <run-id>

# View workflow files
gh workflow list
gh workflow view <workflow>
```

### API (for anything gh doesn't cover directly)

```bash
# Generic API call
gh api repos/{owner}/{repo}/endpoint

# With pagination
gh api repos/{owner}/{repo}/endpoint --paginate

# POST/PATCH
gh api repos/{owner}/{repo}/endpoint -f field=value
```

## Behavior

- When creating repos, default to **private** unless the user specifies otherwise
- When creating PRs, follow the **workflow** skill process — this skill is a command reference, workflow handles the process
- Before running destructive operations (deleting repos, closing issues, force-merging), confirm with the user
- If a `gh` command fails with auth errors, suggest the user run `! gh auth login`
