#!/usr/bin/env bash
# Commit the working tree's Claude artifacts onto the claude-meta branch
# and push, without leaving the current branch.
#
# Usage: .claude-meta/save.sh ["commit message"]
# Override the branch with CLAUDE_META_BRANCH=<name>.
set -euo pipefail

META_BRANCH="${CLAUDE_META_BRANCH:-claude-meta}"
msg="${1:-chore: update Claude artifacts}"
cd "$(git rev-parse --show-toplevel)"
top=$(pwd)

git fetch --depth 1 origin "+refs/heads/${META_BRANCH}:refs/remotes/origin/${META_BRANCH}"

tmp=$(mktemp -d)
cleanup() { git worktree remove --force "$tmp" >/dev/null 2>&1 || rm -rf "$tmp"; }
trap cleanup EXIT
git worktree add --detach "$tmp" "refs/remotes/origin/${META_BRANCH}" >/dev/null

paths=(.claude-meta)
while IFS= read -r p; do
    case "$p" in ''|'#'*|/*|*..*) continue ;; esac
    paths+=("$p")
done <.claude-meta/manifest

for p in "${paths[@]}"; do
    if [ -e "$top/$p" ]; then
        rm -rf "${tmp:?}/$p"
        cp -a "$top/$p" "$tmp/$p"
    else
        echo "claude-meta: '$p' missing in working tree, keeping branch copy" >&2
    fi
done

addpaths=()
for p in "${paths[@]}"; do
    [ -e "$tmp/$p" ] && addpaths+=("$p")
done

# -f: the payload may be listed in the repo's .gitignore (e.g. .claude/).
git -C "$tmp" add -Af -- "${addpaths[@]}"
if git -C "$tmp" diff --cached --quiet; then
    echo "claude-meta: nothing to save" >&2
    exit 0
fi
git -C "$tmp" commit -q -m "$msg"
git -C "$tmp" push origin "HEAD:refs/heads/${META_BRANCH}"
echo "claude-meta: saved to origin/${META_BRANCH}" >&2
