# CLAUDE.md

## Claude artifacts persistence (read this first)

This file, `.claude/` and `.claude-meta/` are intentionally NOT tracked on
work branches. They live on the orphan branch `claude-meta` and are copied
into the working tree by `.claude-meta/bootstrap.sh` (normally run by the
cloud environment's setup script). Details: `.claude-meta/README.md`.

Rules for every Claude session:

- Never commit `CLAUDE.md`, `.claude/` or `.claude-meta/` to master or to
  feature branches — upstream PRs must stay free of them. They are hidden
  via `.git/info/exclude`; do not force-add them on a work branch.
- After changing anything under `.claude/` or this file (new agent, skill,
  memory, note), persist it immediately:

  ```sh
  .claude-meta/save.sh "chore: describe the change"
  ```

- If the artifacts are missing (no `.claude/` directory), bootstrap them:

  ```sh
  git fetch --depth 1 origin +refs/heads/claude-meta:refs/remotes/origin/claude-meta
  git show origin/claude-meta:.claude-meta/bootstrap.sh | bash
  ```

## Project notes

(Durable project knowledge goes below — remember to run save.sh after
editing.)
