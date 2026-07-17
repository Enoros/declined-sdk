#!/usr/bin/env bash
# Create all SDK GitHub repos, then run the full test suite against the uploaded code.
#
# Usage:
#   ./scripts/create-and-test-sdks.sh
#   GITHUB_ORG=my-org ./scripts/create-and-test-sdks.sh
#   DRY_RUN=1 ./scripts/create-and-test-sdks.sh   # preview create step only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Step 1/2 — Create and push GitHub repositories"
echo ""
"$SCRIPT_DIR/create-github-repos.sh"

echo ""
echo "Step 2/2 — Clone from GitHub and run all SDK tests"
echo ""
TEST_FROM_GITHUB=1 VERIFY_GITHUB=1 "$SCRIPT_DIR/test-all-sdks.sh"
