# Run the full unit test suite for every Declined.io SDK (all 9 API methods per language).
#
# Local (default — uses directories under declined-io/):
#   .\scripts\test-all-sdks.ps1
#
# After uploading to GitHub — clone fresh copies and test:
#   $env:TEST_FROM_GITHUB = "1"
#   $env:GITHUB_ORG = "declined-io"
#   .\scripts\test-all-sdks.ps1
#
# Verify repos exist on GitHub before testing:
#   $env:TEST_FROM_GITHUB = "1"
#   $env:VERIFY_GITHUB = "1"
#   .\scripts\test-all-sdks.ps1
#
# Fail if a language runtime is missing (default: skip):
#   .\scripts\test-all-sdks.ps1 -FailOnMissing

param(
  [string]$GithubOrg = $(if ($env:GITHUB_ORG) { $env:GITHUB_ORG } else { "Enoros" }),
  [string]$GithubRepo = $(if ($env:GITHUB_REPO) { $env:GITHUB_REPO } else { "declined-sdk" }),
  [switch]$FromGithub,
  [switch]$VerifyGithub,
  [switch]$FailOnMissing
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$Manifest = Join-Path $ScriptDir "test-manifest.json"
$CloneDir = if ($env:CLONE_DIR) { $env:CLONE_DIR } else { Join-Path $RootDir ".sdk-test-clones" }

$useGithub = $FromGithub -or ($env:TEST_FROM_GITHUB -eq "1")
$verifyGithub = $VerifyGithub -or ($env:VERIFY_GITHUB -eq "1")

if (-not (Test-Path $Manifest)) {
  Write-Error "Manifest not found: $Manifest"
}

$config = Get-Content $Manifest -Raw | ConvertFrom-Json
$expected = ($config.expectedMethods -join ", ")

Write-Host "Declined.io SDK test runner"
Write-Host "Expected methods per SDK: $expected"
if ($useGithub) {
  Write-Host "Source: GitHub ($GithubOrg/$GithubRepo)"
} else {
  Write-Host "Source: local directories"
}
Write-Host ""

$passed = @()
$failed = @()
$skipped = @()
$script:MonorepoRoot = $null

function Initialize-SdkToolPath {
  $extra = @()

  $gh = "C:\Program Files\GitHub CLI"
  $go = "C:\Program Files\Go\bin"
  $ruby = Get-ChildItem "C:\Ruby*-x64\bin" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
  $maven = Get-ChildItem "$env:LOCALAPPDATA\Programs\Apache\apache-maven-*\bin" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
  $composer = "$env:LOCALAPPDATA\Programs\Composer"
  $php = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Filter "php.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

  if (Test-Path $gh) { $extra += $gh }
  if (Test-Path $go) { $extra += $go }
  if ($ruby) { $extra += $ruby }
  if ($maven) { $extra += $maven }
  if (Test-Path $composer) { $extra += $composer }
  if ($php) { $extra += (Split-Path $php.FullName -Parent) }

  $configurePhp = Join-Path $ScriptDir "configure-php.ps1"
  if ((Test-Path $configurePhp) -and $php) {
    try { & $configurePhp | Out-Null } catch { }
  }

  if ($extra.Count -gt 0) {
    $env:Path = ($extra -join ";") + ";" + $env:Path
  }

  if (-not $env:JAVA_HOME) {
    $jdk = Get-ChildItem "C:\Program Files\Microsoft\jdk-*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    if ($jdk) { $env:JAVA_HOME = $jdk.FullName }
  }
}

Initialize-SdkToolPath

function Test-CommandExists($name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Get-MissingTools($sdk) {
  $missing = @()
  foreach ($cmd in $sdk.requires) {
    if (-not (Test-CommandExists $cmd)) { $missing += $cmd }
  }
  return $missing
}

function Resolve-MonorepoRoot {
  if ($script:MonorepoRoot) { return $script:MonorepoRoot }

  $target = Join-Path $CloneDir $GithubRepo
  $repoUrl = "https://github.com/$GithubOrg/$GithubRepo.git"

  if ($verifyGithub) {
    if (-not (Test-CommandExists "gh")) {
      throw "gh CLI required when -VerifyGithub is set"
    }
    gh repo view "$GithubOrg/$GithubRepo" 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw "GitHub repo not found: $GithubOrg/$GithubRepo"
    }
  }

  New-Item -ItemType Directory -Force -Path $CloneDir | Out-Null
  if (Test-Path (Join-Path $target ".git")) {
    Write-Host "  Pulling latest from $repoUrl"
    Push-Location $target
    git fetch origin 2>&1 | Out-Null
    git reset --hard origin/main 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { git reset --hard origin/master 2>&1 | Out-Null }
    Pop-Location
  } else {
    Write-Host "  Cloning $repoUrl"
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    git clone --depth 1 $repoUrl $target 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git clone failed for $repoUrl" }
  }

  $script:MonorepoRoot = $target
  return $target
}

function Resolve-SdkDir($sdk) {
  if ($useGithub) {
    $root = Resolve-MonorepoRoot
    $target = Join-Path $root $sdk.directory
    if (-not (Test-Path $target)) {
      throw "SDK directory not found in monorepo: $($sdk.directory)"
    }
    return [string]$target
  }

  $local = Join-Path $RootDir $sdk.directory
  if (-not (Test-Path $local)) { throw "Local directory not found: $local" }
  return [string]$local
}

foreach ($sdk in $config.sdks) {
  Write-Host "=== $($sdk.language) ($($sdk.name)) ==="

  $missing = Get-MissingTools $sdk
  if ($missing.Count -gt 0) {
    $msg = "Missing tools: $($missing -join ', ')"
    if ($FailOnMissing) {
      Write-Host "  FAIL - $msg" -ForegroundColor Red
      $failed += "$($sdk.name) ($msg)"
      Write-Host ""
      continue
    }
    Write-Host "  SKIP - $msg" -ForegroundColor Yellow
    $skipped += "$($sdk.name) ($msg)"
    Write-Host ""
    continue
  }

  try {
    $sdkDir = Resolve-SdkDir $sdk
  }
  catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
    $failed += "$($sdk.name) ($($_.Exception.Message))"
    Write-Host ""
    continue
  }

  Write-Host "  Directory: $sdkDir"
  Push-Location $sdkDir
  try {
    if ($sdk.setupCommand) {
      Write-Host "  Setup: $($sdk.setupCommand)"
      Invoke-Expression $sdk.setupCommand
      if ($LASTEXITCODE -ne 0) { throw "Setup failed" }
    }

    Write-Host "  Test: $($sdk.testCommand)"
    Invoke-Expression $sdk.testCommand
    if ($LASTEXITCODE -ne 0) { throw "Tests failed" }

    Write-Host "  PASS" -ForegroundColor Green
    $passed += $sdk.name
  }
  catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
    $failed += $sdk.name
  }
  finally {
    Pop-Location
  }

  Write-Host ""
}

Write-Host "========================================"
Write-Host "Summary"
Write-Host "  Passed : $($passed.Count)"
Write-Host "  Failed : $($failed.Count)"
Write-Host "  Skipped: $($skipped.Count)"
Write-Host ""

if ($passed.Count -gt 0) {
  Write-Host "Passed:"
  foreach ($p in $passed) { Write-Host "  + $p" -ForegroundColor Green }
}
if ($skipped.Count -gt 0) {
  Write-Host "Skipped:"
  foreach ($s in $skipped) { Write-Host "  - $s" -ForegroundColor Yellow }
}
if ($failed.Count -gt 0) {
  Write-Host "Failed:"
  foreach ($f in $failed) { Write-Host "  x $f" -ForegroundColor Red }
  exit 1
}

if ($passed.Count -eq 0) {
  Write-Error "No SDKs were tested."
}

Write-Host "All tested SDKs passed." -ForegroundColor Green
