# Create all SDK GitHub repos, then run the full test suite against the uploaded code.
#
# Usage:
#   .\scripts\create-and-test-sdks.ps1
#   $env:GITHUB_ORG = "my-org"; .\scripts\create-and-test-sdks.ps1
#   $env:DRY_RUN = "1"; .\scripts\create-and-test-sdks.ps1   # preview create step only

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Step 1/2 — Create and push GitHub repositories"
Write-Host ""
& (Join-Path $ScriptDir "create-github-repos.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Step 2/2 — Clone from GitHub and run all SDK tests"
Write-Host ""
$env:TEST_FROM_GITHUB = "1"
$env:VERIFY_GITHUB = "1"
& (Join-Path $ScriptDir "test-all-sdks.ps1") -FromGithub
exit $LASTEXITCODE
