param(
  [string]$RepoName = "declined-java"
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$DeclinedRoot = Resolve-Path (Join-Path $ScriptRoot "..\..")
$LocalRepo = Join-Path $DeclinedRoot $RepoName

function Resolve-RepoDir {
  $base = $env:NEXT_PUBLIC_SDK_GITHUB_BASE
  if ($base) {
    $url = "$($base.TrimEnd('/'))/$RepoName.git"
    $work = Join-Path $env:TEMP "declined-publish-$RepoName"
    if (-not (Test-Path $work)) { git clone $url $work }
    return $work
  }
  if (-not (Test-Path $LocalRepo)) { throw "Local repo not found: $LocalRepo" }
  return $LocalRepo
}

function Ensure-Command($name, $installHint) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Missing dependency '$name'. $installHint"
  }
}

$repoDir = Resolve-RepoDir
Push-Location $repoDir
try {
  Ensure-Command mvn "Install Apache Maven"

  mvn -q test
  if ($LASTEXITCODE -ne 0) { throw "Tests failed" }

  if ($env:OSSRH_USERNAME -and $env:OSSRH_PASSWORD) {
    mvn deploy
  } else {
    Write-Host "[dry-run] mvn deploy (set OSSRH_USERNAME and OSSRH_PASSWORD to publish)"
    mvn -q package
    Write-Host "Would run: mvn deploy"
  }
}
finally {
  Pop-Location
}
