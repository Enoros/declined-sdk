#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-declined-node}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DECLINED_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOCAL_REPO="$DECLINED_ROOT/$REPO_NAME"

resolve_repo_dir() {
  if [[ -n "${NEXT_PUBLIC_SDK_GITHUB_BASE:-}" ]]; then
    local url="${NEXT_PUBLIC_SDK_GITHUB_BASE%/}/$REPO_NAME.git"
    local work="${TMPDIR:-/tmp}/declined-publish-$REPO_NAME"
    if [[ ! -d "$work" ]]; then
      git clone "$url" "$work"
    fi
    echo "$work"
  elif [[ -d "$LOCAL_REPO" ]]; then
    echo "$LOCAL_REPO"
  else
    echo "Local repo not found: $LOCAL_REPO" >&2
    exit 1
  fi
}

ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1. $2" >&2; exit 1; }
}

REPO_DIR="$(resolve_repo_dir)"
cd "$REPO_DIR"

ensure_cmd node "Install Node.js 18+"
ensure_cmd npm "Install npm"

[[ -d node_modules ]] || npm install
npm test
npm run build

if [[ -n "${NPM_TOKEN:-}" ]]; then
  npm publish --access public
else
  echo "[dry-run] npm publish --access public (set NPM_TOKEN to publish)"
  npm publish --dry-run --access public
fi
