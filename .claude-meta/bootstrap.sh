#!/usr/bin/env bash
# Copy Claude artifacts (CLAUDE.md, .claude/, ...) from the claude-meta
# branch into the working tree, without touching the git index, and hide
# them from git via .git/info/exclude so they cannot reach a work branch.
#
# Safe to re-run at any time. Run it from anywhere inside the repo, even
# before .claude-meta/ exists locally:
#
#   git fetch --depth 1 origin +refs/heads/claude-meta:refs/remotes/origin/claude-meta
#   git show origin/claude-meta:.claude-meta/bootstrap.sh | bash
#
# Override the branch with CLAUDE_META_BRANCH=<name>.
set -euo pipefail

META_BRANCH="${CLAUDE_META_BRANCH:-claude-meta}"
cd "$(git rev-parse --show-toplevel)"

git fetch --depth 1 origin "+refs/heads/${META_BRANCH}:refs/remotes/origin/${META_BRANCH}"
ref="refs/remotes/origin/${META_BRANCH}"

paths=()
while IFS= read -r p; do
    case "$p" in ''|'#'*|/*|*..*) continue ;; esac
    paths+=("$p")
done < <(git show "${ref}:.claude-meta/manifest")

git archive "$ref" .claude-meta "${paths[@]}" | tar -x

# Keep the artifacts invisible to git on work branches (idempotent block).
exclude=.git/info/exclude
touch "$exclude"
sed -i '/^# >>> claude-meta >>>$/,/^# <<< claude-meta <<<$/d' "$exclude"
{
    echo '# >>> claude-meta >>>'
    echo '/.claude-meta/'
    for p in "${paths[@]}"; do printf '/%s\n' "$p"; done
    echo '# <<< claude-meta <<<'
} >>"$exclude"

echo "claude-meta: restored .claude-meta ${paths[*]} from origin/${META_BRANCH}" >&2
