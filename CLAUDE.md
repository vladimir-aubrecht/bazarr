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

- Everything committed or pushed to this repository must be written in
  English — commit messages, source code, scripts, comments and
  documentation alike (data such as translation files are the exception).
  This includes the contents of the `claude-meta` branch.
- Work branches must never carry the Claude artifacts as commits; the
  artifacts exist only on the `claude-meta` branch. Keep work branches
  containing exactly the changes meant for master/upstream.
- Delivery: `.github/workflows/build-docker.yml` builds a multi-arch
  (amd64+arm64) Docker image on every push to `master` and on `v*` tags,
  publishing to `ghcr.io/vladimir-aubrecht/bazarr` (tags: `master`,
  `sha-<short-sha>`, git-describe version; `latest` only on releases).
  Docker Hub is skipped in this fork (no secrets). Manual/branch builds:
  dispatch `build-docker.yml` (any ref) or `build-docker-manual.yml`.
  The GHCR package is public; deploy hosts pull without login.
