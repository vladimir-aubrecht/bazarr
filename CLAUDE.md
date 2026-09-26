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

- Never implement anything unless the user explicitly asks for it — no
  code changes, commits, builds, deployments or branch operations on your
  own initiative. Questions and problem reports get analysis and
  proposals only; wait for an explicit go-ahead before acting. (Keeping
  these Claude artifacts persisted via save.sh remains expected.)
- Everything committed or pushed to this repository must be written in
  English — commit messages, source code, scripts, comments and
  documentation alike (data such as translation files are the exception).
  This includes the contents of the `claude-meta` branch.
- Work branches must never carry the Claude artifacts as commits; the
  artifacts exist only on the `claude-meta` branch. Keep work branches
  containing exactly the changes meant for master/upstream.
- Delegate hands-on coding work (features, fixes, refactors, tests) to
  the `coder` subagent (`.claude/agents/coder.md`) instead of doing it in
  the main session, to conserve expensive tokens. Launch it without a
  model override to get its default (Claude Opus 4.8); override with
  `sonnet` for routine mechanical changes, or `fable` for the hardest
  problems. Keep orchestration, review, decisions and user communication
  in the main session.
- Token routing for the other agents: `scout` (Haiku) for code
  exploration, code questions and summaries; `runner` (Sonnet) for
  builds, test suites and any long-output commands, so logs never enter
  the main context; `reviewer` (Opus 4.8) to review diffs before they
  are committed. In the main session avoid reading whole files when an
  excerpt suffices.
- Canonical verification: `.claude-meta/scripts/verify-frontend.sh` and
  `.claude-meta/scripts/verify-backend.sh` (run them via the `runner`
  agent). Image build & publish procedure lives in the `deliver` skill
  (`.claude/skills/deliver/SKILL.md`).
- Feature work in progress (user-approved plan): list filters + series
  scores; design mockup: https://claude.ai/artifact/RzPJbPzBWvrBRfDNosRkXx
  - Phase 1 (implemented on `feat/subtitle-status-filters`): "Subtitles:
    Any / Complete / Missing some" filter on the Movies and Series lists,
    client-side via the shared ItemView. User-decided semantics: items
    WITHOUT a language profile are "untracked" — excluded from both
    Complete and Missing some (nothing to complete); a series with no
    episode files is untracked too. Movies with a profile: empty
    `missing_subtitles` = complete; series with a profile and files:
    `episodeMissingCount === 0` = complete.
  - Phase 2: show the match score inside subtitle badges on the series
    detail — mirror the movie detail's historyMap pattern (episodes
    history with include_embedded); color scale green >= 90 %, yellow
    70-89 %, red < 70 %; tooltip with provider + matched/not_matched.
  - Phase 2 (done on `feat/episode-subtitle-scores`, reviewed "ship"):
    scores inside episode subtitle badges + tooltip; required an
    additive series_id/seriesid filter on the episodes history endpoint.
  - Phase 3 (done on `feat/score-filter`, reviewed "ship" + fixups
    b8861e56; STACKED on
    `feat/subtitle-status-filters` because both touch ItemView): score
    filter on both lists with three groups — Full (100 %), Not full
    (< 100 %), Below threshold — threshold read from settings
    (`general.minimum_score_movie`, default 70; `general.minimum_score`
    for episodes, default 80 per config.py — NOT 90); items with no
    scored current subtitles are excluded from all three groups; a
    "Lowest score" column shows only while a score filter is active;
    backend adds an opt-in `scores` param on the movies/series list
    endpoints returning `lowest_subtitle_score` (float % or null) per
    item.
- Feature workflow: branch each feature from FRESH `lavx/development`
  (`git remote add lavx https://github.com/LavX/bazarr.git; git fetch
  --depth 50 lavx development`) — never mirror development into the
  fork. Conventional commits; PRs target `LavX/bazarr:development` and
  the user opens them via a compare link (the GitHub App has no access
  to LavX). Frontend tests must run under Node 24.20.0 (per .nvmrc; the
  container's Node 22 breaks msw/undici in 6 pre-existing test files —
  install via `npm install --prefix <scratchpad>/node24 node@24.20.0`).
- Delivery: `.github/workflows/build-docker.yml` builds a multi-arch
  (amd64+arm64) Docker image on every push to `master` and on `v*` tags,
  publishing to `ghcr.io/vladimir-aubrecht/bazarr` (tags: `master`,
  `sha-<short-sha>`, git-describe version; `latest` only on releases).
  Docker Hub is skipped in this fork (no secrets). Manual/branch builds:
  dispatch `build-docker.yml` (any ref) or `build-docker-manual.yml`.
  The GHCR package is public; deploy hosts pull without login.
