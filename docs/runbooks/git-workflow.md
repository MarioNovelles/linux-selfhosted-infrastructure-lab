# Git Workflow

This runbook documents how I use Git when updating this repository.

I use Git to keep my work organized, review changes before committing, and avoid pushing sensitive information by accident.

## Main idea

I keep `main` as the stable public branch.

For larger improvements, I use one working branch:

```text
dev
```

A branch is my workspace.
A commit is a checkpoint.

This helps me improve the repository step by step without making `main` messy.

## Branch workflow

```bash
# Go into the repository
cd ~/projects/linux-selfhosted-infrastructure-lab

# Switch to the stable branch
git checkout main

# Download the latest changes from GitHub
git pull

# Create the improvement branch
git checkout -b dev

# Check which branch I am using
git branch --show-current
```

If the branch already exists, I use:

```bash
# Switch to the existing improvement branch
git checkout dev

# Bring in the latest changes from main
git merge main
```

## Normal workflow

For each small improvement, I use this process:

```bash
# Show which files changed
git status

# Review unstaged changes
git diff

# Stage only the file I want to commit
git add <file>

# Review exactly what will be committed
git diff --staged

# Save the change locally with a clear message
git commit -m "Clear commit message"

# Upload the branch to GitHub
git push

# Check that the working tree is clean
git status

# Show the latest commits
git log --oneline -5
```

## How I use these commands

| Command                   | Why I use it                                  |
| ------------------------- | --------------------------------------------- |
| `git status`              | See changed files and staged files            |
| `git diff`                | Review changes before staging                 |
| `git add <file>`          | Stage only the file I want in the next commit |
| `git diff --staged`       | Review exactly what will be committed         |
| `git commit -m "message"` | Save one focused change locally               |
| `git push`                | Upload commits to GitHub                      |
| `git log --oneline -5`    | Check recent commit history                   |

## Important note about `git diff`

`git diff` only shows changes that are not staged yet.

If I already used `git add`, then `git diff` may show no output even though there are staged changes ready to commit.

To review staged changes, I use:

```bash
# Show changes that are already staged
git diff --staged
```

This helps me avoid committing something I did not review.

## Commit messages

I try to keep commit messages short, clear, and specific.

Good examples:

```text
Add practical security notes
Document backup and restore strategy
Improve Git workflow runbook
Add Docker Compose validation notes
Fix broken documentation links
```

I avoid vague messages like:

```text
update
fix
changes
stuff
```

Small commits are easier to review later and make the project history more useful.

## Before pushing

Before pushing to GitHub, I check that I did not include sensitive information.

I do not commit:

* passwords
* API keys
* tokens
* private keys
* real `.env` files
* private domains
* internal IP addresses
* public IP addresses
* production firewall exports
* production Docker Compose files with real secrets

Useful checks:

```bash
# Show changed files
git status

# Review unstaged changes
git diff

# Review staged changes
git diff --staged

# Search the repository for common sensitive words
git grep -nEi 'password|token|secret|private key|api key' || true
```

The `git grep` command is not perfect, but it helps me catch obvious mistakes before pushing.

## Pushing the improvement branch

The first time I push the branch, I use:

```bash
# Push the branch and connect it to GitHub
git push -u origin dev
```

After that, I can usually use:

```bash
# Push new commits to the same branch
git push
```

## Merging back to main

I do not merge every tiny edit into `main`.

I merge when one improvement phase is complete, for example:

```text
Phase: documentation cleanup
- security notes updated
- backup strategy added
- troubleshooting notes improved
- Git workflow documented
```

Then I merge:

```bash
# Switch to the stable branch
git checkout main

# Bring the latest version from GitHub
git pull

# Merge the improvement branch into main
git merge dev

# Push the updated main branch
git push
```

After the merge, I can continue using the same improvement branch:

```bash
# Go back to the improvement branch
git checkout dev

# Bring it up to date with main
git merge main
```

## Final check

After pushing, I usually run:

```bash
# Confirm there are no uncommitted changes
git status

# Show the latest commits
git log --oneline -5
```

`git status` should show a clean working tree.

## Short summary about branch workflow

I keep `main` stable and use a `dev` branch for larger updates. I make small focused commits, review diffs before committing, and check for secrets before pushing. This helps me work carefully and keeps the repository history useful.

