# Creates the Enoros/declined-sdk monorepo and pushes the entire declined-io/ directory.
# Requires: gh CLI authenticated with repo scope.
#
# Usage:
#   .\scripts\create-github-repos.ps1
#   $env:GITHUB_ORG = "Enoros"; $env:GITHUB_REPO = "declined-sdk"; .\scripts\create-github-repos.ps1
#   $env:DRY_RUN = "1"; .\scripts\create-github-repos.ps1

param(
  [string]$GithubOrg = $(if ($env:GITHUB_ORG) { $env:GITHUB_ORG } else { "Enoros" }),
  [string]$GithubRepo = $(if ($env:GITHUB_REPO) { $env:GITHUB_REPO } else { "declined-sdk" }),
  [string]$Visibility = $(if ($env:VISIBILITY) { $env:VISIBILITY } else { "public" }),
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$ReposJson = Join-Path $ScriptDir "repos.json"

function Test-GhRepoExists([string]$Repo) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "SilentlyContinue"
  gh repo view $Repo 2>&1 | Out-Null
  $exists = ($LASTEXITCODE -eq 0)
  $ErrorActionPreference = $prev
  return $exists
}

function Get-GitRemoteUrl([string]$Name) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "SilentlyContinue"
  $url = git remote get-url $Name 2>$null
  $ok = ($LASTEXITCODE -eq 0)
  $ErrorActionPreference = $prev
  if (-not $ok) { return $null }
  return $url
}

function Invoke-Gh([string[]]$GhArgs) {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  & gh @GhArgs
  $code = $LASTEXITCODE
  $ErrorActionPreference = $prev
  if ($code -ne 0) {
    throw "gh $($GhArgs -join ' ') failed with exit code $code"
  }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "gh CLI is required. Install from https://cli.github.com/"
}

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Error "gh is not authenticated. Run: gh auth login"
}

$description = "Official Declined.io SDKs for Node.js, Python, Ruby, PHP, Go, and Java"
if (Test-Path $ReposJson) {
  $manifest = Get-Content $ReposJson -Raw | ConvertFrom-Json
  if ($manifest.org) { $GithubOrg = $manifest.org }
  if ($manifest.name) { $GithubRepo = $manifest.name }
  if ($manifest.description) { $description = $manifest.description }
}

$fullRepo = "$GithubOrg/$GithubRepo"

Write-Host "Declined.io SDK monorepo upload"
Write-Host "  Repository: $fullRepo"
Write-Host "  Source:     $RootDir"
Write-Host "  Description: $description"
Write-Host ""

if ($DryRun -or $env:DRY_RUN -eq "1") {
  Write-Host "[dry-run] would create or push $fullRepo from $RootDir"
  exit 0
}

Push-Location $RootDir
try {
  if (-not (Test-Path ".git")) {
    git init -b main
    git add -A
    git commit -m "Initial commit: Declined.io SDK monorepo"
  }
  elseif (git status --porcelain) {
    git add -A
    git commit -m "Update Declined.io SDK monorepo"
  }

  if (Test-GhRepoExists $fullRepo) {
    Write-Host "Repository exists - pushing updates"
    $remote = Get-GitRemoteUrl "origin"
    if (-not $remote) {
      Write-Host "  Adding remote origin"
      git remote add origin "https://github.com/$fullRepo.git"
      if ($LASTEXITCODE -ne 0) { throw "git remote add failed" }
    }
    git push -u origin main
    if ($LASTEXITCODE -ne 0) { throw "git push failed" }
  }
  else {
    Write-Host "Creating repository and pushing"
    Invoke-Gh @(
      "repo", "create", $fullRepo,
      "--$Visibility",
      "--description", $description,
      "--source=.",
      "--remote=origin",
      "--push"
    )
  }
}
finally {
  Pop-Location
}

Write-Host ""
Write-Host ('Done: https://github.com/' + $fullRepo)
