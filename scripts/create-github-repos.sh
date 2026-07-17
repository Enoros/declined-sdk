#!/usr/bin/env bash
# Creates the Enoros/declined-sdk monorepo and pushes the entire declined-io/ directory.
#
# Usage:
#   ./scripts/create-github-repos.sh
#   GITHUB_ORG=Enoros GITHUB_REPO=declined-sdk ./scripts/create-github-repos.sh
#   DRY_RUN=1 ./scripts/create-github-repos.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPOS_JSON="$SCRIPT_DIR/repos.json"
GITHUB_ORG="${GITHUB_ORG:-Enoros}"
GITHUB_REPO="${GITHUB_REPO:-declined-sdk}"
VISIBILITY="${VISIBILITY:-public}"
DRY_RUN="${DRY_RUN:-0}"

DESCRIPTION="Official Declined.io SDKs for Node.js, Python, Ruby, PHP, Go, and Java"

if [[ -f "$REPOS_JSON" ]] && command -v jq >/dev/null 2>&1; then
  GITHUB_ORG="$(jq -r '.org // empty' "$REPOS_JSON")" && GITHUB_ORG="${GITHUB_ORG:-Enoros}"
  GITHUB_REPO="$(jq -r '.name // empty' "$REPOS_JSON")" && GITHUB_REPO="${GITHUB_REPO:-declined-sdk}"
  DESCRIPTION="$(jq -r '.description // empty' "$REPOS_JSON")"
fi

FULL_REPO="$GITHUB_ORG/$GITHUB_REPO"

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI is required" >&2
  exit 1
fi

gh auth status >/dev/null 2>&1 || { echo "Error: run gh auth login" >&2; exit 1; }

echo "Declined.io SDK monorepo upload"
echo "  Repository: $FULL_REPO"
echo "  Source:     $ROOT_DIR"
echo ""

if [[ "$DRY_RUN" == "1" ]]; then
  echo "[dry-run] would create or push $FULL_REPO"
  exit 0
fi

pushd "$ROOT_DIR" >/dev/null

if [[ ! -d .git ]]; then
  git init -b main
  git add -A
  git commit -m "Initial commit: Declined.io SDK monorepo"
elif [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "Update Declined.io SDK monorepo"
fi

if gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  echo "Repository exists — pushing updates"
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$FULL_REPO.git"
  git push -u origin main
else
  echo "Creating repository and pushing"
  gh repo create "$FULL_REPO" \
    --"$VISIBILITY" \
    --description "$DESCRIPTION" \
    --source=. \
    --remote=origin \
    --push
fi

popd >/dev/null
echo ""
echo "Done: https://github.com/$FULL_REPO"
