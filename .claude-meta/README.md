# claude-meta

Persistence for Claude artifacts (`CLAUDE.md`, `.claude/` — agents, skills,
settings, memories…) **outside master**, so changes can be upstreamed
without any Claude-specific files.

## How it works

- The artifacts live on the **orphan branch `claude-meta`** (it shares no
  history with master, so it cannot be merged silently by accident — git
  reports "unrelated histories"). It is never merged into master or into
  feature branches.
- `bootstrap.sh` copies the artifacts from `origin/claude-meta` into the
  working tree (files only, it never touches the index) and records them
  in `.git/info/exclude`. That file is purely local (never committed), so
  `git status` and `git add -A` permanently ignore the artifacts on work
  branches.
- `save.sh` commits artifact changes back onto `claude-meta` and pushes —
  through a temporary worktree, without switching the current branch.

Master therefore stays free of any Claude trace (`.claude/` is incidentally
already covered by the `.gitignore` inherited from upstream; `CLAUDE.md`
and `.claude-meta/` are covered by `.git/info/exclude`).

## Bootstrap in a new session / fresh clone

```sh
git fetch --depth 1 origin +refs/heads/claude-meta:refs/remotes/origin/claude-meta
git show origin/claude-meta:.claude-meta/bootstrap.sh | bash
```

For cloud sessions (claude.ai/code), put these two lines into the
environment's **Setup script** (environment menu in the session title bar
→ Edit → Setup script) so the artifacts are restored automatically at the
start of every session.

## Saving changes

After any change to agents, memories or `CLAUDE.md`:

```sh
.claude-meta/save.sh "chore: what changed"
```

(Claude does this on its own — the instruction lives in `CLAUDE.md`.)

## Adding another persisted path

Add a line to `.claude-meta/manifest` (path relative to the repo root, no
trailing slash), run `save.sh`, and next time `bootstrap.sh` picks it up.

## Notes

- A different branch can be selected via `CLAUDE_META_BRANCH=<name>` for
  both scripts.
- If the push in `save.sh` fails (someone pushed in the meantime), run it
  again — it fetches the fresh branch tip first.
- Deleted files: `bootstrap.sh` only adds/overwrites; when an artifact is
  deleted on the branch, older working copies may still carry it.
