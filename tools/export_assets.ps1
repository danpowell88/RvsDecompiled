
# export_assets.ps1
# Unpacks all retail binary packages into raw source asset files under content/.
#
# Requires (auto-downloaded to tools/ if missing):
#   tools/umodel/umodel_64.exe  - UE Viewer by Gildor (textures/meshes/animations)
#   tools/vgmstream/vgmstream-cli.exe - vgmstream (sounds from .SB0 Ubisoft banks)
#
# Output layout:
#   content/textures/<PkgName>/<Group>/  *.tga  (DXT decompressed)
#   content/animations/<PkgName>/        *.psk (mesh) + *.psa (anim sequences)
#   content/staticmeshes/<PkgName>/      *.psk
#   content/sounds/<PkgName>/            *.wav  (decoded from Ubisoft ADPCM .SB0)
#   content/maps/                        *.rsm  (copied verbatim)
#
# NOTE: .uax packages are tiny metadata stubs; actual audio is in .SB0 banks.
#       Each .SB0 may contain multiple streams which are all exported.
#
# Usage: .\tools\export_assets.ps1 [[-Force]]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$root      = Split-Path $PSScriptRoot -Parent
$content   = Join-Path $root "content"
$umodel    = Join-Path $root "tools\umodel\umodel_64.exe"
$vgmstream = Join-Path $root "tools\vgmstream\vgmstream-cli.exe"

# --- Tool bootstrap ---
function Ensure-Tools {
    if (-not (Test-Path $umodel)) {
        Write-Host "Downloading UModel..."
        New-Item -ItemType Directory -Force (Join-Path $root "tools\umodel") | Out-Null
        $zip = Join-Path $root "tools\umodel_win32.zip"
        Invoke-WebRequest -Uri "https://www.gildor.org/down/47/umodel/umodel_win32.zip" `
            -Headers @{ Referer = "https://www.gildor.org/downloads" } -OutFile $zip
        Expand-Archive $zip (Join-Path $root "tools\umodel") -Force
        Remove-Item $zip
    }
    if (-not (Test-Path $vgmstream)) {
        Write-Host "Downloading vgmstream..."
        New-Item -ItemType Directory -Force (Join-Path $root "tools\vgmstream") | Out-Null
        $zip = Join-Path $root "tools\vgmstream.zip"
        Invoke-WebRequest -Uri "https://github.com/vgmstream/vgmstream/releases/latest/download/vgmstream-win64.zip" -OutFile $zip
        Expand-Archive $zip (Join-Path $root "tools\vgmstream") -Force
        Remove-Item $zip
    }
}

function Export-UModel {
    param([string]$PackagePath, [string]$OutDir, [string]$Label)
    $pkgName = [System.IO.Path]::GetFileNameWithoutExtension($PackagePath)
    $sentinel = Join-Path $OutDir "$pkgName\.exported"
    if (-not $Force -and (Test-Path $sentinel)) {
        Write-Host "  [SKIP] $pkgName"
        return
    }
    New-Item -ItemType Directory -Force (Join-Path $OutDir $pkgName) | Out-Null
    $result = & $umodel -export -game=ue2 `
        -path="$($root)\retail" `
        -out="$OutDir" `
        $PackagePath 2>&1
    $exported = ($result | Select-String "^Exported \d+").Count
    $line = $result | Select-String "^Exported \d+" | Select-Object -Last 1
    if ($LASTEXITCODE -ne 0 -and -not ($result -match "Exported \d+/\d+")) {
        Write-Warning "  [FAIL] $pkgName"
    } else {
        $summary = if ($line) { $line.Line.Trim() } else { "ok" }
        Write-Host "  [OK]   $pkgName -- $summary"
        Set-Content $sentinel "exported"
    }
}

function Export-Sounds {
    param([string]$SB0Path, [string]$OutDir)
    $pkgName = [System.IO.Path]::GetFileNameWithoutExtension($SB0Path)
    $dest = Join-Path $OutDir $pkgName
    $sentinel = Join-Path $dest ".exported"
    if (-not $Force -and (Test-Path $sentinel)) {
        Write-Host "  [SKIP] $pkgName"
        return
    }
    New-Item -ItemType Directory -Force $dest | Out-Null
    # -S 0 exports all streams; ?n = stream name, ?02s = zero-padded stream index
    $result = & $vgmstream -o "$dest\?n_?02s.wav" -S 0 $SB0Path 2>&1
    $wavs = (Get-ChildItem $dest -Filter "*.wav" -ErrorAction SilentlyContinue).Count
    if ($wavs -eq 0) {
        Write-Warning "  [FAIL] $pkgName (no WAVs exported)"
    } else {
        Write-Host "  [OK]   $pkgName ($wavs streams)"
        Set-Content $sentinel "exported"
    }
}

Ensure-Tools

# --- Textures ---
Write-Host "`n=== Textures (.utx -> TGA) ==="
$texOut = Join-Path $content "textures"
Get-ChildItem (Join-Path $root "retail\textures") -Filter "*.utx" | ForEach-Object {
    Export-UModel -PackagePath $_.FullName -OutDir $texOut -Label "Texture"
}

# --- Animations (.ukx -> PSK + PSA) ---
Write-Host "`n=== Animations (.ukx -> PSK/PSA) ==="
$animOut = Join-Path $content "animations"
Get-ChildItem (Join-Path $root "retail\animations") -Filter "*.ukx" | ForEach-Object {
    Export-UModel -PackagePath $_.FullName -OutDir $animOut -Label "Animation"
}

# --- Static Meshes (.usx -> PSK) ---
Write-Host "`n=== Static Meshes (.usx -> PSK) ==="
$smOut = Join-Path $content "staticmeshes"
Get-ChildItem (Join-Path $root "retail\staticmeshes") -Filter "*.usx" | ForEach-Object {
    Export-UModel -PackagePath $_.FullName -OutDir $smOut -Label "StaticMesh"
}

# --- Sounds (.SB0 -> WAV via vgmstream) ---
Write-Host "`n=== Sounds (.SB0 -> WAV) ==="
$sndOut = Join-Path $content "sounds"
Get-ChildItem (Join-Path $root "retail\sounds") -Filter "*.SB0" | ForEach-Object {
    Export-Sounds -SB0Path $_.FullName -OutDir $sndOut
}

# --- Maps (copy as-is) ---
Write-Host "`n=== Maps (.rsm copied) ==="
$mapOut = Join-Path $content "maps"
New-Item -ItemType Directory -Force $mapOut | Out-Null
Get-ChildItem (Join-Path $root "retail\maps") -Filter "*.rsm" | ForEach-Object {
    $dest = Join-Path $mapOut $_.Name
    if (-not $Force -and (Test-Path $dest)) {
        Write-Host "  [SKIP] $($_.Name)"
    } else {
        Copy-Item $_.FullName $dest
        Write-Host "  [OK]   $($_.Name)"
    }
}

Write-Host "`nDone. Content tree written to: $content"
