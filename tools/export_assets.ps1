
# export_assets.ps1
# Unpacks retail UE2 binary packages into raw source asset files under content/.
#
# !! IMPORTANT - UCC LIMITATIONS !!
# The retail UCC.exe cannot properly export most of this game's asset formats:
#
#   Textures:     DXT1/3/5 compressed textures export as 0-byte files silently.
#                 Only a handful of uncompressed (paletted/RGB) textures work.
#
#   Sounds:       .uax packages are tiny wrappers; actual audio is stored in the
#                 proprietary DARE audio format (.SB0 files). UCC exports 0-byte
#                 placeholder .wav files with no audio data.
#
#   StaticMeshes: DXT-compressed geometry silently exports as 0-byte T3D files.
#
# THE CORRECT TOOL for full extraction is UModel by Gildor:
#   https://www.gildor.org/en/projects/umodel
# UModel handles DXT decompression, DARE audio, and skeletal meshes (PSK/PSA).
#
# What this script CAN reliably do:
#   maps/   *.rsm -> content/maps/*.rsm   (verbatim copy, these are valid)
#
# The broken export sections (textures/sounds/staticmeshes) are left here
# for reference / future use once a better extraction tool is integrated.
#
# NOT supported by this UCC build (requires ActorX UnrealEd plugin):
#   animations/ *.ukx -> PSK + PSA -- skipped, originals in retail/animations/
#
# Usage: .\tools\export_assets.ps1 [[-Force]]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$root    = Split-Path $PSScriptRoot -Parent
$ucc     = Join-Path $root "retail\system\UCC.exe"
$content = Join-Path $root "content"

function Export-Package {
    param(
        [string]$PackagePath,
        [string]$ClassName,
        [string]$Extension,
        [string]$OutDir
    )
    $pkgName = [System.IO.Path]::GetFileNameWithoutExtension($PackagePath)
    $dest = Join-Path $OutDir $pkgName

    if (-not $Force -and (Test-Path $dest) -and (Get-ChildItem $dest -File).Count -gt 0) {
        Write-Host "  [SKIP] $pkgName (already exported)"
        return
    }

    New-Item -ItemType Directory -Force $dest | Out-Null
    $result = & $ucc batchexport $PackagePath $ClassName $Extension $dest 2>&1
    $errors = ($result | Select-String "error" | Measure-Object).Count
    $exported = ($result | Select-String "^Exported").Count
    if ($LASTEXITCODE -ne 0 -and $exported -eq 0) {
        Write-Warning "  [FAIL] $pkgName -- $($result | Select-String 'History|Exiting' | Select-Object -First 1)"
    } else {
        Write-Host "  [OK]   $pkgName ($exported objects, $errors errors)"
    }
}

# --- Textures ---
Write-Host "`n=== Textures ==="
$texOut = Join-Path $content "textures"
Get-ChildItem (Join-Path $root "retail\textures") -Filter "*.utx" | ForEach-Object {
    Export-Package -PackagePath $_.FullName -ClassName Texture -Extension bmp -OutDir $texOut
}

# --- Sounds ---
Write-Host "`n=== Sounds ==="
$sndOut = Join-Path $content "sounds"
Get-ChildItem (Join-Path $root "retail\sounds") -Filter "*.uax" | ForEach-Object {
    Export-Package -PackagePath $_.FullName -ClassName Sound -Extension wav -OutDir $sndOut
}

# --- Static Meshes ---
Write-Host "`n=== Static Meshes ==="
$smOut = Join-Path $content "staticmeshes"
Get-ChildItem (Join-Path $root "retail\staticmeshes") -Filter "*.usx" | ForEach-Object {
    Export-Package -PackagePath $_.FullName -ClassName StaticMesh -Extension t3d -OutDir $smOut
}

# --- Maps (copy as-is) ---
Write-Host "`n=== Maps ==="
$mapOut = Join-Path $content "maps"
New-Item -ItemType Directory -Force $mapOut | Out-Null
Get-ChildItem (Join-Path $root "retail\maps") -Filter "*.rsm" | ForEach-Object {
    $dest = Join-Path $mapOut $_.Name
    if (-not $Force -and (Test-Path $dest)) {
        Write-Host "  [SKIP] $($_.Name) (already copied)"
    } else {
        Copy-Item $_.FullName $dest
        Write-Host "  [OK]   $($_.Name)"
    }
}

# --- Animations (not exportable via UCC) ---
Write-Host "`n=== Animations ==="
Write-Host "  [NOTE] .ukx packages cannot be exported to PSK/PSA by this UCC build."
Write-Host "         The ActorX UnrealEd plugin is required for skeletal mesh/animation export."
Write-Host "         Source files remain in retail/animations/. Third-party tools (e.g. UModel)"
Write-Host "         can extract PSK+PSA from these packages if needed."

Write-Host "`nDone. Content tree written to: $content"
