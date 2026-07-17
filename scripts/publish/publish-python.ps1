param(
  [string]$RepoName = "declined-python"
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
  Ensure-Command python "Install Python 3.9+"
  Ensure-Command pip "Install pip"

  pip install -e ".[dev]"
  python -m pytest
  if ($LASTEXITCODE -ne 0) { throw "Tests failed" }

  pip install build twine
  python -m build

  if ($env:TWINE_USERNAME -and $env:TWINE_PASSWORD) {
    twine upload dist/*
  } else {
    Write-Host "[dry-run] twine upload dist/* (set TWINE_USERNAME and TWINE_PASSWORD to publish)"
    twine upload --repository testpypi dist/* --skip-existing 2>$null
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Would run: twine upload dist/*"
    }
  }
}
finally {
  Pop-Location
}
