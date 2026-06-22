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

| Command | Why I use it |
|---|---|
| `git status` | See changed files and staged files |
| `git diff` | Review changes before staging |
| `git diff --stat` | Show a summary of changed files and line counts |
| `git add <file>` | Stage only the file I want in the next commit |
| `git mv <old> <new>` | Rename or move a tracked file and stage the change |
| `git rm <file>` | Remove a tracked file and stage the deletion |
| `git diff --staged` | Review exactly what will be committed |
| `git diff --staged --stat` | Show a summary of staged changes before committing |
| `git commit -m "message"` | Save one focused change locally |
| `git show --stat` | Show the file and line summary for the last commit |
| `git push` | Upload commits to GitHub |
| `git log --oneline -5` | Check recent commit history |

`git diff` only shows changes that are not staged yet.

If I already used `git add`, then `git diff` may show no output even though there are staged changes ready to commit.

To review staged changes, I use:

```bash
# Show changes that are already staged
git diff --staged
```

This helps me avoid committing something I did not review.

## Checking change size with `--stat`

Sometimes I want a quick overview of how large a change is before reading the full diff.

For that I use:

```bash
# Show a summary of unstaged changes
git diff --stat
```

For staged changes:

```bash
# Show a summary of what is staged for commit
git diff --staged --stat
```

This shows which files changed and roughly how many lines were added or removed.

Example output:

```text
docs/runbooks/git-workflow.md | 24 +++++++++++++++++++-----
1 file changed, 19 insertions(+), 5 deletions(-)
```

This is useful before committing because it helps me notice if a change is larger than expected.

For example, if I only meant to update one runbook but `git diff --stat` shows many unrelated files, I know I should stop and review before staging or committing.

To check the summary of the last commit, I use:

```bash
# Show file and line summary for the last commit
git show --stat
```

## Renaming and moving tracked files

When I rename or move a file that is already tracked by Git, I use `git mv`.

Example:

```bash
# Rename a tracked file
git mv old-name.md new-name.md
```

Example from this repository:

```bash
# Move the Pi-hole + Unbound runbook into a numbered DNS folder
git mv dns-filtering/pihole-unbound-recursive-dns.md dns-filtering/pihole-unbound/01-install-pihole-unbound.md
```

Another example:

```bash
# Move an allowlist note into the allowlists folder
git mv dns-filtering/allowlists.md dns-filtering/allowlists/allowlists.md
```

Why:

`git mv` stages the rename or move immediately and makes the change easier to review.

It is similar to doing this:

```bash
mv old-name.md new-name.md
git add new-name.md
git rm old-name.md
```

but shorter and clearer.

After using `git mv`, I check the result:

```bash
# Show renamed, modified, deleted, and untracked files
git status --short

# Review staged file renames
git diff --staged --name-status
```

Important:

`git mv` only works for files Git is already tracking.

If a file is untracked and shown with `??`, I use normal `mv` or `rm` instead.

Example:

```bash
# Move an untracked file
mv draft.md notes/draft.md

# Remove an untracked duplicate file
rm duplicate-note.md
```

If I accidentally try `git rm` on an untracked file, Git may say the path does not match any known file. That usually means Git is not tracking that file yet.

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

## Opening a pull request

When one improvement phase is ready, I push the `dev` branch to GitHub and open a pull request.

```bash
# Make sure I am on the dev branch
git checkout dev

# Push the latest dev commits to GitHub
git push origin dev
```

On GitHub, I open a pull request with:

```text
base: main
compare: dev
```

Meaning:

```text
Take the changes from dev and propose merging them into main.
```

I use a pull request instead of pushing directly to `main` because it gives me one more chance to review the change as a complete unit.

This is useful for documentation work because I can check:

* changed files
* renamed files
* deleted files
* broken links
* commit history
* whether unrelated work was accidentally included

## After the pull request is merged

After the pull request is merged on GitHub, the remote `main` branch has changed.

My local `main` branch does not update automatically, so I sync it:

```bash
# Switch to the stable branch
git checkout main

# Download the latest main branch from GitHub
git pull origin main
```

Then I bring `dev` back in sync with `main`:

```bash
# Switch back to the working branch
git checkout dev

# Bring the latest main changes into dev
git merge main

# Push the updated dev branch to GitHub
git push origin dev
```

Final check:

```bash
# Check the working tree
git status --short
```

A clean result means the branches are synced and I can start the next improvement from a clean state.

## Why I sync main back into dev

I use `main` as the stable public branch and `dev` as the working branch.

After a pull request is merged, `main` becomes the source of truth.

Even if the pull request came from `dev`, the merge on GitHub can still change history through a merge commit, squash commit, conflict resolution, or final edits.

Bringing `main` back into `dev` keeps both branches aligned.

The goal is:

```text
main = stable merged version
dev  = ready for the next task
```

Without this sync step, `dev` can slowly drift away from `main`.

That can cause problems later, such as:

* confusing pull request diffs
* old files appearing again
* duplicate changes
* avoidable merge conflicts
* GitHub showing that the branch is behind `main`

## Simple mental model

I think of the branches like this:

```text
dev  = workshop
main = display room
```

I build and fix things in `dev`.

When the work is ready, I open a pull request and merge it into `main`.

After that, I sync `dev` with `main` so the workshop matches the display room before I start the next task.

## When I use this workflow

I use this workflow when I make a complete improvement phase, for example:

```text
Phase: DNS documentation cleanup
- split Pi-hole and Unbound docs
- update DNS README links
- remove old DNS redirect document
- organize allowlists and blocklists
```

I do not need a pull request for every tiny local edit.

I use a pull request when the change is large enough that I want a final review before it becomes part of `main`.

## Handling merge conflicts

Sometimes `main` and `dev` both changed the same file or renamed files differently.

When that happens, Git stops the merge and asks me to resolve the conflict.

Useful commands:

```bash
# Show conflict state
git status --short

# Show unresolved conflict files
git diff --name-only --diff-filter=U
```

After I decide which files to keep, I stage the resolved files:

```bash
# Stage resolved files
git add <file>
```

If a file should be removed:

```bash
# Remove a tracked file as part of the conflict resolution
git rm <file>
```

Then I finish the merge:

```bash
# Finish the merge commit
git commit
```

When merging `main` into `dev`, I remember:

```text
ours   = current branch, usually dev
theirs = branch being merged in, usually main
```

This helps me understand which version Git is referring to during conflict resolution.

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

I keep `main` stable and use `dev` as my working branch for larger updates.

I make small focused commits, review diffs before committing, check for secrets before pushing, and use pull requests to merge completed work into `main`.

After a pull request is merged, I pull the latest `main` locally and merge `main` back into `dev` so the next task starts from a clean and current branch state.

This keeps the repository history easier to understand and helps avoid confusing future pull requests.

