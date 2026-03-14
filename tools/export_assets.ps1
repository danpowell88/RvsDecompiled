
# export_assets.ps1
# Unpacks all retail UE2 binary packages into raw source asset files
# under content/ mirroring the structure Red Storm would have had.
#
# Supported:
#   textures/   *.utx  -> content/textures/<Package>/*.bmp   (BMP; TGA/DXT fails in this UCC build)
#   sounds/     *.uax  -> content/sounds/<Package>/*.wav
#   staticmeshes/*.usx -> content/staticmeshes/<Package>/*.t3d
#   maps/       *.rsm  -> content/maps/*.rsm  (copied as-is; .rsm is R6-proprietary, not UCC-exportable)
#
# NOT supported by this UCC build (requires ActorX UnrealEd plugin):
#   animations/ *.ukx  -> PSK (mesh) + PSA (animation) -- skipped, originals left in retail/animations/
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
