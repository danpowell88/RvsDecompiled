<#
.SYNOPSIS
    Downloads and installs Ghidra 11.x and JDK 21 for the Ravenshield decompilation project.

.DESCRIPTION
    This script:
    1. Downloads Eclipse Temurin JDK 21 (required by Ghidra 11.x)
    2. Downloads Ghidra 11.3 (latest stable)
    3. Extracts both to tools/ghidra/ and tools/jdk/
    4. Creates a launch script with JAVA_HOME pre-configured
    5. Creates a headless analysis launch script

.NOTES
    Run from the project root: .\tools\setup_ghidra.ps1
#>

param(
    [string]$InstallDir = (Join-Path $PSScriptRoot ".."),
    [string]$GhidraVersion = "11.3",
    [string]$GhidraDate = "20250205",
    [string]$JdkVersion = "21.0.6+7",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"  # Speed up Invoke-WebRequest

$ToolsDir = Join-Path $InstallDir "tools"
$GhidraDir = Join-Path $ToolsDir "ghidra"
$JdkDir = Join-Path $ToolsDir "jdk"
$TempDir = Join-Path $ToolsDir "_downloads"

# --- URLs ---
$JdkTag = $JdkVersion -replace '\+', '%2B'
$JdkFilename = "OpenJDK21U-jdk_x64_windows_hotspot_$($JdkVersion -replace '\+','_').zip"
$JdkUrl = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-$JdkTag/$JdkFilename"

$GhidraFilename = "ghidra_${GhidraVersion}_PUBLIC_${GhidraDate}.zip"
$GhidraUrl = "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GhidraVersion}_build/$GhidraFilename"

function Write-Step($msg) { Write-Host "`n>>> $msg" -ForegroundColor Cyan }

# --- Pre-flight checks ---
if ((Test-Path (Join-Path $GhidraDir "ghidraRun.bat")) -and -not $Force) {
    Write-Host "Ghidra already installed at $GhidraDir. Use -Force to reinstall." -ForegroundColor Yellow
    exit 0
}

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# --- JDK 21 ---
Write-Step "Downloading Eclipse Temurin JDK 21..."
$jdkZip = Join-Path $TempDir "jdk21.zip"
if (-not (Test-Path $jdkZip)) {
    Write-Host "  URL: $JdkUrl"
    try {
        Invoke-WebRequest -Uri $JdkUrl -OutFile $jdkZip -UseBasicParsing
    } catch {
        Write-Warning "Auto-download failed. Please download JDK 21 manually:"
        Write-Host "  https://adoptium.net/temurin/releases/?version=21&os=windows&arch=x64&package=jdk"
        Write-Host "  Extract to: $JdkDir"
        Write-Host ""
    }
}

if (Test-Path $jdkZip) {
    Write-Step "Extracting JDK 21..."
    if (Test-Path $JdkDir) { Remove-Item -Recurse -Force $JdkDir }
    Expand-Archive -Path $jdkZip -DestinationPath $TempDir -Force
    $extracted = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "jdk-*" } | Select-Object -First 1
    if ($extracted) {
        Move-Item -Path $extracted.FullName -Destination $JdkDir -Force
        Write-Host "  JDK installed to $JdkDir" -ForegroundColor Green
    }
}

# --- Ghidra ---
Write-Step "Downloading Ghidra $GhidraVersion..."
$ghidraZip = Join-Path $TempDir "ghidra.zip"
if (-not (Test-Path $ghidraZip)) {
    Write-Host "  URL: $GhidraUrl"
    try {
        Invoke-WebRequest -Uri $GhidraUrl -OutFile $ghidraZip -UseBasicParsing
    } catch {
        Write-Warning "Auto-download failed. Please download Ghidra manually:"
        Write-Host "  https://github.com/NationalSecurityAgency/ghidra/releases"
        Write-Host "  Extract to: $GhidraDir"
        Write-Host ""
    }
}

if (Test-Path $ghidraZip) {
    Write-Step "Extracting Ghidra..."
    if (Test-Path $GhidraDir) { Remove-Item -Recurse -Force $GhidraDir }
    Expand-Archive -Path $ghidraZip -DestinationPath $TempDir -Force
    $extracted = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "ghidra_*" } | Select-Object -First 1
    if ($extracted) {
        Move-Item -Path $extracted.FullName -Destination $GhidraDir -Force
        Write-Host "  Ghidra installed to $GhidraDir" -ForegroundColor Green
    }
}

# --- Cleanup temp downloads ---
Write-Step "Cleaning up temporary files..."
Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue

# --- Create launch scripts ---
Write-Step "Creating launch scripts..."

$javaHome = $JdkDir
if (-not (Test-Path (Join-Path $javaHome "bin\java.exe"))) {
    # Try to find java on PATH as fallback
    $javaExe = Get-Command java -ErrorAction SilentlyContinue
    if ($javaExe) {
        $javaHome = Split-Path (Split-Path $javaExe.Source)
        Write-Host "  Using system Java: $javaHome" -ForegroundColor Yellow
    } else {
        Write-Warning "JDK not found. Ghidra scripts will need JAVA_HOME set manually."
        $javaHome = "%JAVA_HOME%"
    }
}

# GUI launch script
$guiScript = @"
@echo off
set JAVA_HOME=$javaHome
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d "%~dp0..\tools\ghidra"
start ghidraRun.bat %*
"@
Set-Content -Path (Join-Path $ToolsDir "launch_ghidra.bat") -Value $guiScript

# Headless analysis script
$headlessScript = @"
@echo off
REM Headless Ghidra analysis for Ravenshield decompilation project
REM Usage: run_headless.bat <command> [args...]
REM Example: run_headless.bat -import ..\retail\system\Core.dll -postScript ..\ghidra\scripts\batch_import.py

set JAVA_HOME=$javaHome
set PATH=%JAVA_HOME%\bin;%PATH%
set PROJECT_DIR=%~dp0..\ghidra\project
set PROJECT_NAME=RavenShield

cd /d "%~dp0..\tools\ghidra"
call support\analyzeHeadless.bat "%PROJECT_DIR%" "%PROJECT_NAME%" %*
"@
Set-Content -Path (Join-Path $ToolsDir "run_headless.bat") -Value $headlessScript

Write-Step "Setup complete!"
Write-Host ""
Write-Host "  Launch Ghidra GUI:  tools\launch_ghidra.bat" -ForegroundColor Green
Write-Host "  Run headless:       tools\run_headless.bat -import <binary> -postScript <script>" -ForegroundColor Green
Write-Host ""

if (-not (Test-Path (Join-Path $GhidraDir "ghidraRun.bat"))) {
    Write-Host "NOTE: Ghidra was not downloaded automatically." -ForegroundColor Yellow
    Write-Host "Please download from https://github.com/NationalSecurityAgency/ghidra/releases" -ForegroundColor Yellow
    Write-Host "and extract to: $GhidraDir" -ForegroundColor Yellow
}
