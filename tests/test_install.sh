#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/install.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash -n "$SCRIPT"

cat > "$TMP/packages.txt" <<'PKGS'
# comment
curl

git
jq
PKGS

output="$("$SCRIPT" --package-file "$TMP/packages.txt" --dry-run)"
grep -q 'Dry run' <<<"$output"
grep -q '^  curl$' <<<"$output"
grep -q '^  git$' <<<"$output"
grep -q '^  jq$' <<<"$output"

if "$SCRIPT" --package-file "$TMP/missing.txt" --dry-run >/dev/null 2>&1; then
  echo "missing package file should fail" >&2
  exit 1
fi

if "$SCRIPT" --unknown >/dev/null 2>&1; then
  echo "unknown option should fail" >&2
  exit 1
fi

echo "Project 05 smoke tests passed."
