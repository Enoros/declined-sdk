#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-declined-go}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DECLINED_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOCAL_REPO="$DECLINED_ROOT/$REPO_NAME"

resolve_repo_dir() {
  if [[ -n "${NEXT_PUBLIC_SDK_GITHUB_BASE:-}" ]]; then
    local url="${NEXT_PUBLIC_SDK_GITHUB_BASE%/}/$REPO_NAME.git"
    local work="${TMPDIR:-/tmp}/declined-publish-$REPO_NAME"
    [[ -d "$work" ]] || git clone "$url" "$work"
    echo "$work"
  elif [[ -d "$LOCAL_REPO" ]]; then
    echo "$LOCAL_REPO"
  else
    echo "Local repo not found: $LOCAL_REPO" >&2
    exit 1
  fi
}

ensure_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1. $2" >&2; exit 1; }; }

REPO_DIR="$(resolve_repo_dir)"
cd "$REPO_DIR"

ensure_cmd go "Install Go 1.22+"
go test ./...

if [[ -n "${GOPROXY_TOKEN:-}" ]]; then
  echo "Go modules publish via git tags to github.com/declined-io/declined-go"
  echo "Would run: git tag v1.0.0 && git push --tags"
else
  echo "[dry-run] git tag v1.0.0 && git push --tags"
fi
