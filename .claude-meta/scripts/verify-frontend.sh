#!/usr/bin/env bash
# Canonical frontend verification for this repository. Mirrors the CI
# frontend job. Run from anywhere inside the repo; extra arguments are
# passed to `vitest run` (e.g. specific test files), no arguments runs
# the full test suite.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)/frontend"

if [ ! -d node_modules ]; then
    echo "== npm ci (node_modules missing) =="
    npm ci
fi

echo "== TypeScript check =="
npm run check:ts

echo "== ESLint =="
npm run check

echo "== Prettier =="
npm run check:fmt

echo "== Build =="
npm run build

echo "== Tests =="
npx vitest run "$@"

echo "== verify-frontend: all checks passed =="
