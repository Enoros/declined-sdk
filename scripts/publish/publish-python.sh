#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-declined-python}"
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

ensure_cmd python3 "Install Python 3.9+"
ensure_cmd pip3 "Install pip"

pip3 install -e ".[dev]"
python3 -m pytest
python3 -m pip install build twine
python3 -m build

if [[ -n "${TWINE_USERNAME:-}" && -n "${TWINE_PASSWORD:-}" ]]; then
  twine upload dist/*
else
  echo "[dry-run] twine upload dist/* (set TWINE_USERNAME and TWINE_PASSWORD to publish)"
  echo "Would run: twine upload dist/*"
fi
