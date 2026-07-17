param(
  [string]$RepoName = "declined-php"
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
  Ensure-Command php "Install PHP 8.1+"
  Ensure-Command composer "Install Composer"

  if (-not (Test-Path vendor)) { composer install }

  composer test
  if ($LASTEXITCODE -ne 0) { throw "Tests failed" }

  if ($env:PACKAGIST_TOKEN) {
    Write-Host "Composer packages are published via Packagist webhook; push git tag and trigger sync."
    Write-Host "Would tag release and notify Packagist with PACKAGIST_TOKEN."
  } else {
    Write-Host "[dry-run] composer validate && git tag (set PACKAGIST_TOKEN / push to GitHub for Packagist)"
    composer validate
  }
}
finally {
  Pop-Location
}
