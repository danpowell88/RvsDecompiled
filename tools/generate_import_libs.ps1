<#
.SYNOPSIS
    Generate import libraries (.lib) for external dependency DLLs.

.DESCRIPTION
    Uses dumpbin to extract exports from each external DLL, generates .def files,
    then uses lib.exe to create import libraries for linking. Also validates
    against existing .lib files in the Raven_Shield_C_SDK.

.NOTES
    Requires MSVC toolchain (cl.exe, lib.exe, dumpbin.exe) on PATH or via
    tools/toolchain/msvc71/bin/.
    
    Run from project root: powershell -File tools/generate_import_libs.ps1
#>

param(
    [string]$RetailDir = (Join-Path $PSScriptRoot "..\retail\system"),
    [string]$OutputDir = (Join-Path $PSScriptRoot "extlibs"),
    [string]$MsvcBin = (Join-Path $PSScriptRoot "toolchain\msvc71\bin")
)

$ErrorActionPreference = "Stop"

# External DLLs to generate import libs for
$ExternalDlls = @(
    "binkw32.dll",
    "OpenAL32.dll",
    "ogg.dll",
    "vorbis.dll",
    "vorbisfile.dll",
    "eax.dll"
)

# In-scope DLLs that also need import libs (from SDK or generated)
$InScopeDlls = @(
    "Core.dll",
    "Engine.dll",
    "Window.dll",
    "R6Abstract.dll",
    "R6Engine.dll",
    "R6Game.dll",
    "R6Weapons.dll",
    "R6GameService.dll",
    "D3DDrv.dll",
    "WinDrv.dll",
    "IpDrv.dll",
    "Fire.dll",
    "DareAudio.dll",
    "DareAudioRelease.dll",
    "DareAudioScript.dll"
)

function Write-Step($msg) { Write-Host "`n>>> $msg" -ForegroundColor Cyan }

# --- Find tools ---
$dumpbin = $null
$libexe = $null

# Try MSVC 7.1 toolchain first
if (Test-Path (Join-Path $MsvcBin "dumpbin.exe")) {
    $dumpbin = Join-Path $MsvcBin "dumpbin.exe"
    $libexe = Join-Path $MsvcBin "lib.exe"
}

# Fall back to system PATH
if (-not $dumpbin) {
    $dumpbin = (Get-Command dumpbin.exe -ErrorAction SilentlyContinue).Source
    $libexe = (Get-Command lib.exe -ErrorAction SilentlyContinue).Source
}

# Fall back to VS Developer Command Prompt tools
if (-not $dumpbin) {
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vsWhere) {
        $vsPath = & $vsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($vsPath) {
            $vcToolsDir = Get-ChildItem "$vsPath\VC\Tools\MSVC" -Directory | Sort-Object Name -Descending | Select-Object -First 1
            if ($vcToolsDir) {
                $hostBin = Join-Path $vcToolsDir.FullName "bin\Hostx86\x86"
                if (Test-Path (Join-Path $hostBin "dumpbin.exe")) {
                    $dumpbin = Join-Path $hostBin "dumpbin.exe"
                    $libexe = Join-Path $hostBin "lib.exe"
                }
            }
        }
    }
}

if (-not $dumpbin -or -not $libexe) {
    Write-Error "Could not find dumpbin.exe and lib.exe. Ensure MSVC tools are available."
    exit 1
}

Write-Host "Using dumpbin: $dumpbin"
Write-Host "Using lib:     $libexe"

# --- Setup ---
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

function Generate-ImportLib {
    param(
        [string]$DllPath,
        [string]$OutputDir
    )
    
    $dllName = [System.IO.Path]::GetFileNameWithoutExtension($DllPath)
    $defFile = Join-Path $OutputDir "$dllName.def"
    $libFile = Join-Path $OutputDir "$dllName.lib"
    
    if (-not (Test-Path $DllPath)) {
        Write-Warning "  DLL not found: $DllPath"
        return $false
    }
    
    # Extract exports using dumpbin
    $exports = & $dumpbin /EXPORTS $DllPath 2>$null
    
    # Parse export lines
    $exportNames = @()
    $inExports = $false
    foreach ($line in $exports) {
        if ($line -match "^\s+ordinal\s+hint\s+RVA\s+name") {
            $inExports = $true
            continue
        }
        if ($inExports -and $line -match "^\s+Summary") {
            break
        }
        if ($inExports -and $line -match "^\s+\d+\s+[0-9A-Fa-f]+\s+[0-9A-Fa-f]+\s+(.+)$") {
            $exportNames += $Matches[1].Trim()
        }
    }
    
    if ($exportNames.Count -eq 0) {
        Write-Warning "  No exports found in: $DllPath"
        return $false
    }
    
    # Generate .def file
    $defContent = "LIBRARY `"$([System.IO.Path]::GetFileName($DllPath))`"`r`nEXPORTS`r`n"
    foreach ($name in $exportNames) {
        $defContent += "    $name`r`n"
    }
    Set-Content -Path $defFile -Value $defContent -Encoding ASCII
    
    # Generate .lib from .def
    $libArgs = "/DEF:$defFile /OUT:$libFile /MACHINE:X86"
    $result = Start-Process -FilePath $libexe -ArgumentList $libArgs -Wait -NoNewWindow -PassThru -RedirectStandardOutput "$OutputDir\_lib_stdout.txt" -RedirectStandardError "$OutputDir\_lib_stderr.txt"
    
    Remove-Item "$OutputDir\_lib_stdout.txt", "$OutputDir\_lib_stderr.txt" -ErrorAction SilentlyContinue
    
    if (Test-Path $libFile) {
        $size = (Get-Item $libFile).Length
        Write-Host "  Generated: $dllName.lib ($($exportNames.Count) exports, $size bytes)" -ForegroundColor Green
        return $true
    } else {
        Write-Warning "  Failed to generate: $dllName.lib"
        return $false
    }
}

# --- Generate import libs for external dependencies ---
Write-Step "Generating import libraries for external dependencies..."
$extSuccess = 0
foreach ($dll in $ExternalDlls) {
    $dllPath = Join-Path $RetailDir $dll
    Write-Host "  Processing: $dll"
    if (Generate-ImportLib -DllPath $dllPath -OutputDir $OutputDir) {
        $extSuccess++
    }
}

# --- Generate import libs for in-scope DLLs (for cross-linking during build) ---
Write-Step "Generating import libraries for in-scope DLLs..."
$scopeSuccess = 0
foreach ($dll in $InScopeDlls) {
    $dllPath = Join-Path $RetailDir $dll
    Write-Host "  Processing: $dll"
    if (Generate-ImportLib -DllPath $dllPath -OutputDir $OutputDir) {
        $scopeSuccess++
    }
}

# --- Validate against existing SDK libs ---
Write-Step "Validating against Raven_Shield_C_SDK libraries..."
$sdkLibDir = Join-Path $PSScriptRoot "..\sdk\Raven_Shield_C_SDK\lib"
if (Test-Path $sdkLibDir) {
    $sdkLibs = Get-ChildItem $sdkLibDir -Filter "*.lib"
    foreach ($sdkLib in $sdkLibs) {
        $ourLib = Join-Path $OutputDir $sdkLib.Name
        if (Test-Path $ourLib) {
            $sdkSize = $sdkLib.Length
            $ourSize = (Get-Item $ourLib).Length
            $status = if ($sdkSize -eq $ourSize) { "MATCH" } else { "DIFFER (SDK: $sdkSize, Ours: $ourSize)" }
            Write-Host "  $($sdkLib.Name): $status"
        } else {
            Write-Host "  $($sdkLib.Name): SDK-only (no generated equivalent)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Warning "SDK lib directory not found: $sdkLibDir"
}

Write-Step "Summary"
Write-Host "  External deps: $extSuccess / $($ExternalDlls.Count) generated"
Write-Host "  In-scope DLLs: $scopeSuccess / $($InScopeDlls.Count) generated"
Write-Host "  Output:        $OutputDir"
