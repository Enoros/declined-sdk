param(
  [string]$RepoName = "declined-ruby"
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
  Ensure-Command ruby "Install Ruby 3+"
  Ensure-Command gem "Install RubyGems"

  if (-not (Get-Command bundle -ErrorAction SilentlyContinue)) {
    gem install bundler
  }

  bundle install
  bundle exec rspec
  if ($LASTEXITCODE -ne 0) { throw "Tests failed" }

  gem build declined-io.gemspec

  if ($env:RUBYGEMS_API_KEY) {
    gem push (Get-ChildItem *.gem | Select-Object -First 1).Name
  } else {
    Write-Host "[dry-run] gem push <artifact> (set RUBYGEMS_API_KEY to publish)"
    Write-Host "Would run: gem push $(Get-ChildItem *.gem | Select-Object -First 1 -ExpandProperty Name)"
  }
}
finally {
  Pop-Location
}
