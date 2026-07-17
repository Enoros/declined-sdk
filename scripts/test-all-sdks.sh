#!/usr/bin/env bash
# Run the full unit test suite for every Declined.io SDK (all 9 API methods per language).
#
# Local (default — uses directories under declined-io/):
#   ./scripts/test-all-sdks.sh
#
# After uploading to GitHub — clone fresh copies and test:
#   TEST_FROM_GITHUB=1 GITHUB_ORG=declined-io ./scripts/test-all-sdks.sh
#
# Verify repos exist on GitHub before testing:
#   TEST_FROM_GITHUB=1 VERIFY_GITHUB=1 GITHUB_ORG=declined-io ./scripts/test-all-sdks.sh
#
# Skip SDKs whose runtime is not installed (default). Fail instead:
#   FAIL_ON_MISSING=1 ./scripts/test-all-sdks.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$SCRIPT_DIR/test-manifest.json"
GITHUB_ORG="${GITHUB_ORG:-Enoros}"
GITHUB_REPO="${GITHUB_REPO:-declined-sdk}"
TEST_FROM_GITHUB="${TEST_FROM_GITHUB:-0}"
VERIFY_GITHUB="${VERIFY_GITHUB:-0}"
SKIP_MISSING="${SKIP_MISSING:-1}"
FAIL_ON_MISSING="${FAIL_ON_MISSING:-0}"
CLONE_DIR="${CLONE_DIR:-$ROOT_DIR/.sdk-test-clones}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest not found at $MANIFEST" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required for test-all-sdks.sh" >&2
  exit 1
fi

EXPECTED=$(jq -r '.expectedMethods | join(", ")' "$MANIFEST")
echo "Declined.io SDK test runner"
echo "Expected methods per SDK: $EXPECTED"
echo "Source: $([ "$TEST_FROM_GITHUB" = "1" ] && echo "GitHub ($GITHUB_ORG/*)" || echo "local directories")"
echo ""

declare -a PASSED=()
declare -a FAILED=()
declare -a SKIPPED=()

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

sdk_requires_available() {
  local sdk_json="$1"
  local missing=()
  while IFS= read -r cmd; do
    if ! command_exists "$cmd"; then
      missing+=("$cmd")
    fi
  done < <(echo "$sdk_json" | jq -r '.requires[]')
  if ((${#missing[@]} > 0)); then
    echo "${missing[*]}"
    return 1
  fi
  return 0
}

resolve_sdk_dir() {
  local name="$1"
  local directory="$2"
  if [[ "$TEST_FROM_GITHUB" = "1" ]]; then
    local target="$CLONE_DIR/$name"
    local repo_url="https://github.com/$GITHUB_ORG/$name.git"
    if [[ "$VERIFY_GITHUB" = "1" ]]; then
      if ! command -v gh >/dev/null 2>&1; then
        echo "Error: gh CLI required when VERIFY_GITHUB=1" >&2
        exit 1
      fi
      if ! gh repo view "$GITHUB_ORG/$name" >/dev/null 2>&1; then
        echo "Error: GitHub repo not found: $GITHUB_ORG/$name" >&2
        return 1
      fi
    fi
    mkdir -p "$CLONE_DIR"
    if [[ -d "$target/.git" ]]; then
      echo "  Pulling latest from $repo_url"
      git -C "$target" fetch origin main 2>/dev/null || git -C "$target" fetch origin master 2>/dev/null || true
      git -C "$target" reset --hard "origin/main" 2>/dev/null || git -C "$target" reset --hard "origin/master" 2>/dev/null || true
    else
      echo "  Cloning $repo_url"
      rm -rf "$target"
      git clone --depth 1 "$repo_url" "$target"
    fi
    echo "$target"
  else
    local local_dir="$ROOT_DIR/$directory"
    if [[ ! -d "$local_dir" ]]; then
      echo "Error: local directory not found: $local_dir" >&2
      return 1
    fi
    echo "$local_dir"
  fi
}

while IFS= read -r sdk; do
  name=$(echo "$sdk" | jq -r '.name')
  directory=$(echo "$sdk" | jq -r '.directory')
  language=$(echo "$sdk" | jq -r '.language')
  setup_cmd=$(echo "$sdk" | jq -r '.setupCommand // empty')
  test_cmd=$(echo "$sdk" | jq -r '.testCommand')

  echo "=== $language ($name) ==="

  missing=$(sdk_requires_available "$sdk" || true)
  if [[ -n "$missing" ]]; then
    msg="Missing tools: $missing"
    if [[ "$FAIL_ON_MISSING" = "1" ]]; then
      echo "  FAIL — $msg" >&2
      FAILED+=("$name ($msg)")
      echo ""
      continue
    fi
    echo "  SKIP — $msg"
    SKIPPED+=("$name ($msg)")
    echo ""
    continue
  fi

  if ! sdk_dir=$(resolve_sdk_dir "$name" "$directory"); then
    FAILED+=("$name (could not resolve directory)")
    echo ""
    continue
  fi

  echo "  Directory: $sdk_dir"
  pushd "$sdk_dir" >/dev/null

  if [[ -n "$setup_cmd" ]]; then
    echo "  Setup: $setup_cmd"
    bash -lc "$setup_cmd"
  fi

  echo "  Test: $test_cmd"
  if bash -lc "$test_cmd"; then
    echo "  PASS"
    PASSED+=("$name")
  else
    echo "  FAIL"
    FAILED+=("$name")
  fi

  popd >/dev/null
  echo ""
done < <(jq -c '.sdks[]' "$MANIFEST")

echo "========================================"
echo "Summary"
echo "  Passed : ${#PASSED[@]}"
echo "  Failed : ${#FAILED[@]}"
echo "  Skipped: ${#SKIPPED[@]}"
echo ""

if ((${#PASSED[@]} > 0)); then
  echo "Passed:"
  for p in "${PASSED[@]}"; do echo "  ✓ $p"; done
fi
if ((${#SKIPPED[@]} > 0)); then
  echo "Skipped:"
  for s in "${SKIPPED[@]}"; do echo "  - $s"; done
fi
if ((${#FAILED[@]} > 0)); then
  echo "Failed:"
  for f in "${FAILED[@]}"; do echo "  ✗ $f"; done
  exit 1
fi

if ((${#PASSED[@]} == 0)); then
  echo "No SDKs were tested." >&2
  exit 1
fi

echo "All tested SDKs passed."
