param(
  [string]$RepoName = "declined-go"
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
  Ensure-Command go "Install Go 1.22+"

  go test ./...
  if ($LASTEXITCODE -ne 0) { throw "Tests failed" }

  if ($env:GOPROXY_TOKEN) {
    Write-Host "Go modules publish via git tags to github.com/declined-io/declined-go"
    $version = (Select-String -Path go.mod -Pattern '^module').Line
    Write-Host "Would tag and push: v1.0.0"
  } else {
    Write-Host "[dry-run] git tag v1.0.0 && git push --tags (Go modules use VCS tags)"
  }
}
finally {
  Pop-Location
}
