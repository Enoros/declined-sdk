# Enables OpenSSL for winget PHP (required by Composer).
# Winget PHP ships without a loaded php.ini by default.
#
# Usage:
#   .\scripts\configure-php.ps1

$ErrorActionPreference = "Stop"

function Find-PhpDir {
  $cmd = Get-Command php -ErrorAction SilentlyContinue
  if ($cmd) { return Split-Path $cmd.Source -Parent }
  $wingetPhp = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Filter "php.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($wingetPhp) { return Split-Path $wingetPhp.FullName -Parent }
  throw "PHP not found. Install: winget install PHP.PHP.8.4"
}

$phpDir = Find-PhpDir
$iniPath = Join-Path $phpDir "php.ini"
$template = Join-Path $phpDir "php.ini-development"

if (-not (Test-Path $template)) {
  throw "php.ini-development not found in $phpDir"
}

if (-not (Test-Path $iniPath)) {
  Write-Host "Creating php.ini from php.ini-development..."
  Copy-Item $template $iniPath
}

$content = Get-Content $iniPath -Raw

if ($content -notmatch '(?m)^extension_dir\s*=\s*"ext"') {
  $content = $content -replace '(?m)^;extension_dir\s*=\s*"ext"', 'extension_dir = "ext"'
}

$extensions = @("openssl", "mbstring", "curl", "zip")

foreach ($ext in $extensions) {
  if ($content -notmatch "(?m)^extension=$ext") {
    $content = $content -replace "(?m)^;extension=$ext", "extension=$ext"
  }
}

Set-Content -Path $iniPath -Value $content -NoNewline

Write-Host "PHP configured: $iniPath"
& (Join-Path $phpDir "php.exe") -m | Select-String -Pattern "openssl|mbstring|curl|zip"
