param(
  [string]$RepoName = "declined-node"
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
    if (-not (Test-Path $work)) {
      git clone $url $work
    }
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
  Ensure-Command node "Install Node.js 18+"
  Ensure-Command npm "Install npm"

  if (-not (Test-Path node_modules)) { npm install }

  npm test
  if ($LASTEXITCODE -ne 0) { throw "Tests failed" }

  npm run build

  if ($env:NPM_TOKEN) {
    npm publish --access public
  } else {
    Write-Host "[dry-run] npm publish --access public (set NPM_TOKEN to publish)"
    npm publish --dry-run --access public
  }
}
finally {
  Pop-Location
}
