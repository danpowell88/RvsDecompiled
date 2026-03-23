# =============================================================================
# run_headless.ps1 - Orchestrate Ghidra headless analysis for all binaries
# =============================================================================
# Imports all in-scope Ravenshield binaries into the Ghidra project and runs
# the full Phase 1 analysis pipeline:
#   1. Import + auto-analysis + type library application (batch_import.py)
#   2. Symbol recovery from MSVC mangled exports (symbol_recovery.py)
#   3. Inter-DLL cross-reference analysis (cross_reference.py)
#   4. UT99 source matching for Core/Engine (ut99_matcher.py)
#   5. Raw C++ decompilation export (export_cpp.py)
#   6. Raw assembly disassembly export (export_asm.py)
#
# Prerequisites:
#   - Ghidra 11.x installed, GHIDRA_HOME set or passed via -GhidraHome
#   - JDK 21+ on PATH
#   - Retail binaries in retail/system/
#
# Usage:
#   .\tools\run_headless.ps1
#   .\tools\run_headless.ps1 -GhidraHome "C:\Ghidra\ghidra_11.3"
#   .\tools\run_headless.ps1 -BinaryFilter "Core.dll"
#   .\tools\run_headless.ps1 -SkipImport   # re-run scripts on existing project
# =============================================================================

param(
    [string]$GhidraHome = $env:GHIDRA_HOME,
    [string]$BinaryFilter = "",
    [switch]$SkipImport,
    [switch]$SkipExport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Resolve paths ---
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path $ProjectRoot)) {
    $ProjectRoot = Split-Path -Parent $PSScriptRoot
}
# Handle case where script is run from tools/ directly
if (-not (Test-Path "$ProjectRoot\ghidra\scripts")) {
    $ProjectRoot = Split-Path -Parent $PSScriptRoot
}

$RetailSystem  = Join-Path $ProjectRoot "retail\system"
$GhidraProject = Join-Path $ProjectRoot "ghidra\project"
$GhidraScripts = Join-Path $ProjectRoot "ghidra\scripts"
$ReportsDir    = Join-Path $ProjectRoot "ghidra\exports\reports"

# --- Binaries to process (dependency order) ---
$TargetBinaries = @(
    "Core.dll",
    "Engine.dll",
    "Window.dll",
    "D3DDrv.dll",
    "WinDrv.dll",
    "IpDrv.dll",
    "Fire.dll",
    "R6Abstract.dll",
    "R6Engine.dll",
    "R6Game.dll",
    "R6Weapons.dll",
    "R6GameService.dll",
    "DareAudio.dll",
    "DareAudioRelease.dll",
    "DareAudioScript.dll",
    "RavenShield.exe"
)

# --- Validate environment ---
if (-not $GhidraHome -or -not (Test-Path $GhidraHome)) {
    Write-Error @"
Ghidra not found. Set GHIDRA_HOME or pass -GhidraHome:
  `$env:GHIDRA_HOME = 'C:\Ghidra\ghidra_11.3'
  .\tools\run_headless.ps1
"@
    exit 1
}

$AnalyzeHeadless = Join-Path $GhidraHome "support\analyzeHeadless.bat"
if (-not (Test-Path $AnalyzeHeadless)) {
    Write-Error "analyzeHeadless.bat not found at: $AnalyzeHeadless"
    exit 1
}

if (-not (Test-Path $RetailSystem)) {
    Write-Error "Retail binaries not found at: $RetailSystem"
    exit 1
}

# --- Create output directories ---
New-Item -ItemType Directory -Force -Path $GhidraProject | Out-Null
New-Item -ItemType Directory -Force -Path $ReportsDir | Out-Null

# --- Filter binaries ---
if ($BinaryFilter) {
    $TargetBinaries = $TargetBinaries | Where-Object { $_ -like $BinaryFilter }
    if ($TargetBinaries.Count -eq 0) {
        Write-Error "No binaries match filter: $BinaryFilter"
        exit 1
    }
}

# Validate binaries exist
$MissingBinaries = $TargetBinaries | Where-Object { -not (Test-Path (Join-Path $RetailSystem $_)) }
if ($MissingBinaries) {
    Write-Warning "Missing binaries (will be skipped): $($MissingBinaries -join ', ')"
    $TargetBinaries = $TargetBinaries | Where-Object { Test-Path (Join-Path $RetailSystem $_) }
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Ravenshield Phase 1: Ghidra Batch Analysis" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Ghidra:    $GhidraHome"
Write-Host "Project:   $GhidraProject"
Write-Host "Binaries:  $($TargetBinaries.Count)"
Write-Host ""

$StartTime = Get-Date
$Results = @()

foreach ($Binary in $TargetBinaries) {
    $BinaryPath = Join-Path $RetailSystem $Binary
    $BinaryName = [System.IO.Path]::GetFileNameWithoutExtension($Binary)

    Write-Host "--- [$($TargetBinaries.IndexOf($Binary) + 1)/$($TargetBinaries.Count)] $Binary ---" -ForegroundColor Yellow

    # Step 1: Import and analyze (with type libraries)
    if (-not $SkipImport) {
        Write-Host "  Importing and analyzing..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -import $BinaryPath `
            -overwrite `
            -postScript "$GhidraScripts\batch_import.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_import.log"

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "  Import failed for $Binary (exit code: $LASTEXITCODE)"
            $Results += [PSCustomObject]@{ Binary=$Binary; Status="IMPORT_FAILED" }
            continue
        }
    }

    # Step 2: Symbol recovery
    Write-Host "  Recovering symbols..."
    & $AnalyzeHeadless `
        $GhidraProject "RavenShield" `
        -process $Binary `
        -noanalysis `
        -postScript "$GhidraScripts\symbol_recovery.py" `
        -scriptPath $GhidraScripts `
        -log "$ReportsDir\${BinaryName}_symbols.log"

    # Step 3: Cross-reference analysis
    Write-Host "  Building cross-references..."
    & $AnalyzeHeadless `
        $GhidraProject "RavenShield" `
        -process $Binary `
        -noanalysis `
        -postScript "$GhidraScripts\cross_reference.py" `
        -scriptPath $GhidraScripts `
        -log "$ReportsDir\${BinaryName}_xrefs.log"

    # Step 4: UT99 matching (Core and Engine only)
    if ($BinaryName -in @("Core", "Engine")) {
        Write-Host "  Matching against UT99 source..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -process $Binary `
            -noanalysis `
            -postScript "$GhidraScripts\ut99_matcher.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_ut99.log"
    }

    # Step 5: Export raw decompilation
    if (-not $SkipExport) {
        Write-Host "  Exporting decompilation..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -process $Binary `
            -noanalysis `
            -postScript "$GhidraScripts\export_cpp.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_export.log"
    }

    # Step 6: Export raw disassembly
    if (-not $SkipExport) {
        Write-Host "  Exporting disassembly..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -process $Binary `
            -noanalysis `
            -postScript "$GhidraScripts\export_asm.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_asm.log"
    }

    # Step 7: Export vtable layouts
    if (-not $SkipExport) {
        Write-Host "  Exporting vtables..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -process $Binary `
            -noanalysis `
            -postScript "$GhidraScripts\export_vtables.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_vtables.log"
    }

    # Step 8: Export struct layouts
    if (-not $SkipExport) {
        Write-Host "  Exporting struct layouts..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -process $Binary `
            -noanalysis `
            -postScript "$GhidraScripts\export_structs.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_structs.log"
    }

    # Step 9: Export function index
    if (-not $SkipExport) {
        Write-Host "  Exporting function index..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -process $Binary `
            -noanalysis `
            -postScript "$GhidraScripts\export_function_index.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_funcindex.log"
    }

    # Step 10: Export call graph
    if (-not $SkipExport) {
        Write-Host "  Exporting call graph..."
        & $AnalyzeHeadless `
            $GhidraProject "RavenShield" `
            -process $Binary `
            -noanalysis `
            -postScript "$GhidraScripts\export_callgraph.py" `
            -scriptPath $GhidraScripts `
            -log "$ReportsDir\${BinaryName}_callgraph.log"
    }

    $Results += [PSCustomObject]@{ Binary=$Binary; Status="OK" }
    Write-Host "  Done." -ForegroundColor Green
}

# --- Step 7: Aggregate cross-references ---
Write-Host ""
Write-Host "--- Aggregating cross-reference matrix ---" -ForegroundColor Yellow
& $AnalyzeHeadless `
    $GhidraProject "RavenShield" `
    -process ($TargetBinaries[0]) `
    -noanalysis `
    -postScript "$GhidraScripts\cross_reference.py" "aggregate" `
    -scriptPath $GhidraScripts `
    -log "$ReportsDir\cross_reference_aggregate.log"

# --- Step 12: Standalone analysis tools (no Ghidra needed) ---
Write-Host ""
Write-Host "--- Running standalone analysis tools ---" -ForegroundColor Yellow

Write-Host "  Generating FUN_ blocker map..."
& python "$ProjectRoot\tools\gen_blocker_map.py"

Write-Host "  Generating progress report..."
& python "$ProjectRoot\tools\gen_progress_report.py"

# --- Summary ---
$Elapsed = (Get-Date) - $StartTime
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Analysis Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Binaries processed: $($Results.Count)"
Write-Host "Succeeded: $(($Results | Where-Object Status -eq 'OK').Count)"
Write-Host "Failed:    $(($Results | Where-Object Status -ne 'OK').Count)"
Write-Host "Elapsed:   $($Elapsed.ToString('hh\:mm\:ss'))"
Write-Host "Reports:   $ReportsDir"
Write-Host ""

$Results | Format-Table -AutoSize
