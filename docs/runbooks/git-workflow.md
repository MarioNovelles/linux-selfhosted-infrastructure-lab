# Git Workflow

This runbook documents the Git workflow I use when updating this repository.

I use this process to keep changes small, check what I am committing, and avoid pushing sensitive information by accident.

## Normal Workflow

The usual flow is:

```bash
git status
git diff
git add <file>
git diff --staged
git commit -m "Clear commit message"
git push
git status
git log --oneline -5
```

## How I Use These Commands

| Command                   | Why I use it                                             |
| ------------------------- | -------------------------------------------------------- |
| `git status`              | Check which files changed and whether anything is staged |
| `git diff`                | Review unstaged changes before adding them               |
| `git add <file>`          | Stage only the file or files I want in the next commit   |
| `git diff --staged`       | Review exactly what will be committed                    |
| `git commit -m "message"` | Save the change locally with a clear message             |
| `git push`                | Upload the local commit to GitHub                        |
| `git log --oneline -5`    | Confirm the latest commits and check the commit history  |

## Important Note About `git diff`

`git diff` only shows changes that are not staged yet.

If I already used `git add`, then `git diff` may show no output even though there are staged changes ready to commit.

To review staged changes, I use:

```bash
git diff --staged
```

This helps avoid confusion when checking a file before committing it.

## Commit Messages

I try to keep commit messages short, clear, and specific.

Good examples:

```text
Document DNS filtering approach
Add sanitized firewall policy notes
Document Docker Compose architecture plan
Fix script documentation links
```

I try to avoid vague messages like:

```text
update
fix
changes
stuff
```

Small, focused commits are easier to review later and make the project history more useful.

## Before Pushing

Before pushing to GitHub, I check that the staged diff does not include sensitive information.

I do not commit:

- passwords
- API keys
- tokens
- private keys
- real `.env` files
- private domains
- internal IP addresses
- public IP addresses
- production firewall exports
- production Docker Compose files with real secrets

## Final Check

After pushing, I usually run:

```bash
git status
git log --oneline -5
```

`git status` should show a clean working tree, and `git log --oneline -5` should show the newest commit at the top.

