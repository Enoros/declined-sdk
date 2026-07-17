# Installs tools not available via winget: Apache Maven and Composer.
# Maven is NOT in the winget catalog on most Windows installs (Apache.Maven returns "No package found").
# Composer often isn't either — this script uses official direct downloads.
#
# Usage:
#   .\scripts\install-missing-tools.ps1
#   .\scripts\install-missing-tools.ps1 -AddToUserPath

param([switch]$AddToUserPath)

$ErrorActionPreference = "Stop"

$mavenVersion = "3.9.9"
$mavenInstallRoot = "$env:LOCALAPPDATA\Programs\Apache"
$mavenHome = Join-Path $mavenInstallRoot "apache-maven-$mavenVersion"
$mavenZipUrl = "https://archive.apache.org/dist/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"

$composerDir = "$env:LOCALAPPDATA\Programs\Composer"
$composerPhar = Join-Path $composerDir "composer.phar"
$composerBat = Join-Path $composerDir "composer.bat"

function Find-PhpExe {
  $cmd = Get-Command php -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $wingetPhp = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Filter "php.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($wingetPhp) { return $wingetPhp.FullName }
  throw "PHP not found. Install first: winget install PHP.PHP.8.4"
}

function Find-JavaHome {
  if ($env:JAVA_HOME -and (Test-Path $env:JAVA_HOME)) { return $env:JAVA_HOME }
  $candidates = Get-ChildItem "C:\Program Files\Microsoft\jdk-*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending
  if ($candidates) { return $candidates[0].FullName }
  throw "JAVA_HOME not set and no Microsoft JDK found. Install: winget install Microsoft.OpenJDK.17"
}

Write-Host "=== Installing Apache Maven $mavenVersion ==="
if (Test-Path (Join-Path $mavenHome "bin\mvn.cmd")) {
  Write-Host "Already installed at $mavenHome"
} else {
  New-Item -ItemType Directory -Force -Path $mavenInstallRoot | Out-Null
  $zipPath = Join-Path $env:TEMP "apache-maven-$mavenVersion-bin.zip"
  Write-Host "Downloading from archive.apache.org..."
  Invoke-WebRequest -Uri $mavenZipUrl -OutFile $zipPath -UseBasicParsing
  Expand-Archive -Path $zipPath -DestinationPath $mavenInstallRoot -Force
  Remove-Item $zipPath -Force
  Write-Host "Installed to $mavenHome"
}

Write-Host ""
Write-Host "=== Configuring PHP (OpenSSL for Composer) ==="
& (Join-Path $ScriptDir "configure-php.ps1")

Write-Host ""
Write-Host "=== Installing Composer ==="
$phpExe = Find-PhpExe
Write-Host "Using PHP: $phpExe"

if (-not (Test-Path $composerPhar)) {
  New-Item -ItemType Directory -Force -Path $composerDir | Out-Null
  Write-Host "Downloading composer.phar..."
  Invoke-WebRequest -Uri "https://getcomposer.org/download/latest-stable/composer.phar" -OutFile $composerPhar -UseBasicParsing
  @"
@echo off
php "%~dp0composer.phar" %*
"@ | Set-Content -Path $composerBat -Encoding ASCII
  Write-Host "Installed to $composerDir"
} else {
  Write-Host "Already installed at $composerDir"
}

if ($AddToUserPath) {
  $pathsToAdd = @(
    (Join-Path $mavenHome "bin"),
    $composerDir,
    (Split-Path $phpExe -Parent)
  )
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  foreach ($p in $pathsToAdd) {
    if ($userPath -notlike "*$p*") {
      $userPath = "$userPath;$p"
      Write-Host "Adding to user PATH: $p"
    }
  }
  [Environment]::SetEnvironmentVariable("Path", $userPath, "User")
  Write-Host "User PATH updated. Restart your terminal."
}

$env:JAVA_HOME = Find-JavaHome
Write-Host ""
Write-Host "=== Verification ==="
& (Join-Path $mavenHome "bin\mvn.cmd") --version
& $phpExe $composerPhar --version
Write-Host ""
Write-Host "Done. Run tests with: .\scripts\test-all-sdks.ps1"
