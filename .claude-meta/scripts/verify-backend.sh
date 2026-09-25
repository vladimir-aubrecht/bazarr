#!/usr/bin/env bash
# Canonical backend verification for this repository. Mirrors the fast
# part of the CI backend job (ruff + the bazarr test guards). Run from
# anywhere inside the repo; extra arguments are passed to `pytest`
# (default target: tests/bazarr).
#
# Note: some suites outside the default (e.g. embedded-subtitles tests
# under tests/subliminal_patch) additionally need ffmpeg and unar
# installed on the system, as in CI.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if ! python3 -c "import pytest" 2>/dev/null; then
    echo "== Installing Python dependencies (pytest missing) =="
    pip install -q -r requirements.txt
    # signalrcore over-pins msgpack; install it with --no-deps so the
    # msgpack from requirements.txt wins (same workaround as CI).
    pip install -q --no-deps signalrcore==1.0.2
    pip install -q -r dev-requirements.txt pyjwt
fi

echo "== Ruff =="
ruff check .

echo "== Pytest =="
if [ "$#" -gt 0 ]; then
    pytest --tb=short -q "$@"
else
    pytest --tb=short -q tests/bazarr
fi

echo "== verify-backend: all checks passed =="
