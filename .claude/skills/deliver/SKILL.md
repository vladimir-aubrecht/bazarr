---
name: deliver
description: Build and publish a Bazarr+ Docker image to GHCR and verify it landed. Use when the user asks to build, ship, or test-deploy an image from a branch or master, or asks for a release image.
---

# Deliver a Docker image

Delivery = GitHub Actions builds a multi-arch (amd64+arm64) image and
pushes it to `ghcr.io/vladimir-aubrecht/bazarr` (public package). Docker
Hub is always skipped in this fork (no secrets configured).

## Standing rules

- Never start a RELEASE build (anything that moves `latest`) unless the
  user explicitly asked for a release. Test/branch builds are the
  default.
- Builds take ~15-20 minutes. Never poll in a loop; schedule a check-in
  (send_later, ~18 min) and end the turn.

## Procedure

1. Make sure the commit to build is pushed to the branch.
2. Dispatch: `mcp__github__actions_run_trigger` with
   `method: run_workflow`, `workflow_id: build-docker.yml`,
   `ref: <branch>`, and inputs:
   - test/branch build: no inputs (non-release; no `latest`);
   - release build (explicit user request only): `{"version_tag": "vX.Y.Z"}`
     — also tags `latest` and `X.Y.Z`. A push of a git tag `v*` does the
     same automatically.
3. Schedule a check-in ~18 minutes out; on wake, check the run via
   `actions_list`/`actions_get` (owner `vladimir-aubrecht`, repo
   `bazarr`). On failure, fetch the failing job logs and report; do not
   fix or re-dispatch without the user's go-ahead.
4. Verify the image exists (anonymous, no login needed):

   ```sh
   TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:vladimir-aubrecht/bazarr:pull" \
     | python3 -c "import sys,json;print(json.load(sys.stdin)['token'])")
   curl -s -H "Authorization: Bearer $TOKEN" \
     "https://ghcr.io/v2/vladimir-aubrecht/bazarr/tags/list"
   ```

5. Report the pull command with the exact tag.

## Tag scheme

| Tag | Moves when |
|---|---|
| `sha-<short-sha>` | never (immutable per commit) |
| `<branch-name>` (slashes → dashes) | every build of that branch |
| `master` | every build of master |
| `latest`, `X.Y.Z` | release builds only |

Package settings (visibility etc.):
https://github.com/users/vladimir-aubrecht/packages/container/bazarr/settings
