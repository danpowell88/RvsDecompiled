#Requires -Version 5.1
<#
.SYNOPSIS
    Extracts all UnrealScript class definitions from retail RavenShield 1.60 .u packages
    using Eliot.UELib, and merges documentation comments from the SDK 1.56 source.

.DESCRIPTION
    - Processes 21 .u packages from the retail game install
    - Writes one .uc file per exported class to src/{Module}/Classes/
    - Fixes concatenated class-modifier formatting produced by the decompiler
    - Annotates each class with comments found in the matching 1.56 SDK source
    - Marks symbols new in 1.60 and symbols removed since 1.56
#>

param(
    [string]$PackagesDir = "C:\Ravenshield\gamefiles\system",
    [string]$RepoRoot    = "C:\Users\danpo\Desktop\rvs",
    [string]$SdkDir      = "C:\Users\danpo\Desktop\rvs\sdk\1.56 Source Code",
    [string]$UELibPath   = "C:\Tools\UEExplorer\Eliot.UELib.dll"
)

Set-StrictMode -Off   # UELib .NET objects behave oddly with strict-mode property checks
$ErrorActionPreference = "Continue"

# -----------------------------------------------------------------------------
Write-Host "Loading Eliot.UELib from $UELibPath ..." -ForegroundColor Cyan
Add-Type -Path $UELibPath

# -----------------------------------------------------------------------------
# Package file name → relative output directory (inside $RepoRoot)
# Skip OpenRVS.u – community patch, not retail.
# -----------------------------------------------------------------------------
$packageMap = [ordered]@{
    "Core.u"            = "src\Core\Classes"
    "Engine.u"          = "src\Engine\Classes"
    "Editor.u"          = "src\Editor\Classes"
    "UnrealEd.u"        = "src\UnrealEd\Classes"
    "Fire.u"            = "src\Fire\Classes"
    "IpDrv.u"           = "src\IpDrv\Classes"
    "Gameplay.u"        = "src\Gameplay\Classes"
    "UWindow.u"         = "src\UWindow\Classes"
    "R6Abstract.u"      = "src\R6Abstract\Classes"
    "R6Engine.u"        = "src\R6Engine\Classes"
    "R6Game.u"          = "src\R6Game\Classes"
    "R6Weapons.u"       = "src\R6Weapons\Classes"
    "R6GameService.u"   = "src\R6GameService\Classes"
    "R6Menu.u"          = "src\R6Menu\Classes"
    "R6Window.u"        = "src\R6Window\Classes"
    "R6SFX.u"           = "src\R6SFX\Classes"
    "R6Characters.u"    = "src\R6Characters\Classes"
    "R6Description.u"   = "src\R6Description\Classes"
    "R6WeaponGadgets.u" = "src\R6WeaponGadgets\Classes"
    "R61stWeapons.u"    = "src\R61stWeapons\Classes"
    "R63rdWeapons.u"    = "src\R63rdWeapons\Classes"
}

# -----------------------------------------------------------------------------
# Combined modifier pattern (longer alternatives before shorter ones so that
# e.g. "nativereplication" is matched before "native").
# -----------------------------------------------------------------------------
$modPattern = '(nativereplication|noteditinlineuse|exportstructs|autocollapsecategories\([^)]*\)|collapsecategories\([^)]*\)|hidecategories\([^)]*\)|notplaceable|cacheexempt|parseconfig|placeable|abstract|nativeonly|native|noexport|safereplace|transient|dependson\([^)]*\)|config\([^)]*\))'

function Fix-ClassHeader {
    param([string]$text)

    # Modifier names to identify class-header continuation lines and same-line concatenation
    $modNames = @('nativereplication','noteditinlineuse','exportstructs',
                  'autocollapsecategories','collapsecategories','hidecategories',
                  'notplaceable','cacheexempt','parseconfig','placeable',
                  'abstract','nativeonly','native','noexport','safereplace',
                  'transient','dependson','config')

    $lines = $text -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line    = $lines[$i]
        $trimmed = $line.TrimStart()

        # Case A: line is a class-header modifier (may or may not end with ;)
        # Exclude actual code declarations (function/var/enum/struct/comment)
        if ($trimmed -match '^(nativereplication|noteditinlineuse|exportstructs|autocollapsecategories|collapsecategories|hidecategories|notplaceable|cacheexempt|parseconfig|placeable|abstract|nativeonly|native|noexport|safereplace|transient|dependson|config)' -and
            $trimmed -notmatch '\b(function|var|enum|struct)\b' -and
            $trimmed -notmatch '^//') {

            $hasSemi = $trimmed -match ';'
            $modStr  = ($trimmed -replace '\s*;.*$', '').Trim()
            $fixed   = [regex]::Replace($modStr, $modPattern, ' $1').TrimStart() -replace ' {2,}', ' '
            $lines[$i] = "    " + $fixed + $(if ($hasSemi) { ";" } else { "" })
        }
        # Case B: modifiers concatenated directly to parent class name on class line
        # e.g. "class Actor extends Objectabstractnative nativereplication;"
        elseif ($line -match '^class\s+\w+\s+extends\s+') {
            if ($line -match '^(class\s+\w+\s+extends\s+)(\w+)(.*)$') {
                $prefix    = $Matches[1]
                $combined  = $Matches[2] + $Matches[3]
                $hasSemi   = $combined -match ';'
                $restClean = ($combined -replace '\s*;.*$', '').Trim()

                # Find first known modifier in the combined string
                $restLower = $restClean.ToLower()
                $bestIdx   = $restClean.Length
                foreach ($mname in $modNames) {
                    $mi = $restLower.IndexOf($mname)
                    if ($mi -ge 1 -and $mi -lt $bestIdx) { $bestIdx = $mi }
                }

                # Only rewrite if modifiers were found embedded in the parent name
                if ($bestIdx -lt $restClean.Length) {
                    $parentClass = $restClean.Substring(0, $bestIdx)
                    $mods        = $restClean.Substring($bestIdx)
                    $fixedMods   = [regex]::Replace($mods, $modPattern, ' $1').TrimStart() -replace ' {2,}', ' '
                    $lines[$i]   = $prefix + $parentClass + "`n    " + $fixedMods + $(if ($hasSemi) { ";" } else { "" })
                }
            }
        }
    }
    return $lines -join "`n"
}

# -----------------------------------------------------------------------------
# Build a case-insensitive index: class basename (lower) → full SDK file path
# -----------------------------------------------------------------------------
function Build-SdkIndex {
    param([string]$sdkRoot)
    $idx = @{}
    if (-not (Test-Path $sdkRoot)) {
        Write-Warning "SDK directory not found: $sdkRoot"
        return $idx
    }
    Get-ChildItem -Path $sdkRoot -Recurse -Filter "*.uc" -ErrorAction SilentlyContinue | ForEach-Object {
        $key = $_.BaseName.ToLower()
        if (-not $idx.ContainsKey($key)) { $idx[$key] = $_.FullName }
    }
    Write-Host "  SDK index: $($idx.Count) files" -ForegroundColor DarkGray
    return $idx
}

# -----------------------------------------------------------------------------
# Extract comment and symbol information from a 1.56 SDK .uc file
# -----------------------------------------------------------------------------
function Parse-SdkFile {
    param([string]$path)

    $r = @{
        Found           = $false
        PreClassComment = ""
        VarInfo         = @{}   # lower_name → @{Pre=""; Inline=""}
        FuncInfo        = @{}   # lower_name → pre_comment_string
        VarNames        = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        FuncNames       = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    if (-not (Test-Path $path)) { return $r }
    $r.Found = $true

    $lines = [System.IO.File]::ReadAllLines($path)
    $n     = $lines.Count
    $i     = 0

    # Collect file header comment (everything before the class declaration)
    $hdr = [System.Text.StringBuilder]::new()
    while ($i -lt $n -and $lines[$i] -notmatch '^\s*class\b') {
        if ($hdr.Length -gt 0) { $hdr.AppendLine() | Out-Null }
        $hdr.Append($lines[$i]) | Out-Null
        $i++
    }
    $r.PreClassComment = $hdr.ToString().Trim().Replace("`r`n", "`n").Replace("`r", "`n")

    # Walk remaining declarations collecting comments
    $pending = [System.Collections.Generic.List[string]]::new()
    for (; $i -lt $n; $i++) {
        $raw  = $lines[$i]
        $trim = $raw.TrimStart()

        if ($trim -match '^//') {
            $pending.Add($raw) | Out-Null
            continue
        }
        if ($trim -eq '') {
            $pending.Clear()
            continue
        }

        # var declaration
        if ($trim -match '^var\b') {
            $commentBlock = if ($pending.Count -gt 0) { $pending -join "`n" } else { "" }
            $inline       = if ($raw -match '//(.+)$') { "// " + ($Matches[1].Trim()) } else { "" }

            # Extract all variable name(s): last identifier in each comma-separated segment
            $decl = ($trim -replace '//.*$', '') -replace '\s*;.*$', ''
            foreach ($seg in ($decl -split ',')) {
                $words = ($seg.Trim() -split '\s+') | Where-Object { $_ -ne '' }
                if ($words.Count -gt 0) {
                    $nm = $words[-1] -replace '[^A-Za-z0-9_]', ''
                    if ($nm -match '^[A-Za-z_]\w*$') {
                        $key = $nm.ToLower()
                        if (-not $r.VarInfo.ContainsKey($key)) {
                            $r.VarInfo[$key] = @{ Pre = $commentBlock; Inline = $inline }
                        }
                        $r.VarNames.Add($nm) | Out-Null
                    }
                }
            }
            $pending.Clear()
            continue
        }

        # function / event declaration (with optional leading modifiers)
        if ($trim -match '\b(function|event)\b') {
            if ($trim -match '(?:function|event)\s+(?:\w+\s+)?(\w+)\s*\(') {
                $fn  = $Matches[1]
                $key = $fn.ToLower()
                if (-not $r.FuncInfo.ContainsKey($key)) {
                    $r.FuncInfo[$key] = if ($pending.Count -gt 0) { $pending -join "`n" } else { "" }
                }
                $r.FuncNames.Add($fn) | Out-Null
            }
            $pending.Clear()
            continue
        }

        $pending.Clear()
    }
    return $r
}

# -----------------------------------------------------------------------------
# Merge SDK 1.56 comments into 1.60 decompiled text
# -----------------------------------------------------------------------------
function Merge-Comments {
    param([string]$text, [hashtable]$sdk)

    # Nothing to merge when no SDK file was found
    if (-not $sdk.Found) { return $text }

    $lines         = $text -split "`r?`n"
    $out           = [System.Text.StringBuilder]::new()
    $seenV         = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $seenF         = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $classInserted = $false
    $inDP          = $false   # inside defaultproperties block

    foreach ($line in $lines) {
        $trim = $line.TrimStart()

        # Insert SDK file header just before the class keyword
        if (-not $classInserted -and $trim -match '^class\b') {
            if ($sdk.PreClassComment -ne '') {
                $out.Append("// From SDK 1.56 - verify still applicable`n") | Out-Null
                foreach ($hl in ($sdk.PreClassComment -split "`n")) {
                    $out.AppendLine($hl) | Out-Null
                }
            }
            $classInserted = $true
        }

        if ($trim -match '^defaultproperties') { $inDP = $true }

        # Annotate var declarations
        if (-not $inDP -and $trim -match '^var\b') {
            $decl = ($trim -replace '//.*$', '') -replace '\s*;.*$', ''
            # Process only the first segment to decide whether to print a leading annotation
            # (multiple names share the same comment block)
            $firstAnnotationDone = $false
            foreach ($seg in ($decl -split ',')) {
                $words = ($seg.Trim() -split '\s+') | Where-Object { $_ -ne '' }
                if ($words.Count -gt 0) {
                    $nm  = $words[-1] -replace '[^A-Za-z0-9_]', ''
                    if ($nm -match '^[A-Za-z_]\w*$' -and -not $firstAnnotationDone) {
                        $seenV.Add($nm) | Out-Null
                        $key = $nm.ToLower()
                        if ($sdk.VarNames.Count -gt 0) {
                            if ($sdk.VarInfo.ContainsKey($key)) {
                                $vi = $sdk.VarInfo[$key]
                                if ($vi.Pre -ne '') {
                                    foreach ($cl in ($vi.Pre -split "`r?`n")) {
                                        $out.Append($cl.TrimEnd([char]13) + "`n") | Out-Null
                                    }
                                }
                                # Append inline comment if the line doesn't already have one
                                if ($vi.Inline -ne '' -and $line -notmatch '//') {
                                    $line = $line.TrimEnd() + "  " + $vi.Inline
                                }
                            } elseif (-not $sdk.VarNames.Contains($nm)) {
                                $out.Append("// NEW IN 1.60`n") | Out-Null
                            }
                        }
                        $firstAnnotationDone = $true
                    }
                }
            }
        }

        # Annotate function / event declarations
        if (-not $inDP -and $trim -match '\b(function|event)\b') {
            if ($trim -match '(?:function|event)\s+(?:\w+\s+)?(\w+)\s*\(') {
                $fn  = $Matches[1]
                $seenF.Add($fn) | Out-Null
                $key = $fn.ToLower()
                if ($sdk.FuncNames.Count -gt 0) {
                    if ($sdk.FuncInfo.ContainsKey($key) -and $sdk.FuncInfo[$key] -ne '') {
                        foreach ($cl in ($sdk.FuncInfo[$key] -split "`r?`n")) {
                            $out.Append($cl.TrimEnd([char]13) + "`n") | Out-Null
                        }
                    } elseif (-not $sdk.FuncNames.Contains($fn)) {
                        $out.Append("// NEW IN 1.60`n") | Out-Null
                    }
                }
            }
        }

        $out.Append($line.TrimEnd([char]13) + "`n") | Out-Null
    }

    # Append REMOVED IN 1.60 section
    $removedV = @($sdk.VarNames  | Where-Object { -not $seenV.Contains($_) })
    $removedF = @($sdk.FuncNames | Where-Object { -not $seenF.Contains($_) })
    if ($removedV.Count -gt 0 -or $removedF.Count -gt 0) {
        $out.Append("`n") | Out-Null
        $out.Append("// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------`n") | Out-Null
        foreach ($v in $removedV) { $out.Append("// REMOVED IN 1.60: var $v`n") | Out-Null }
        foreach ($f in $removedF) { $out.Append("// REMOVED IN 1.60: function $f`n") | Out-Null }
    }

    return $out.ToString()
}

# -----------------------------------------------------------------------------
# Build a file-level banner for each output .uc
# -----------------------------------------------------------------------------
function Make-Banner {
    param([string]$className, [bool]$hasSdk)
    $sdkNote = if ($hasSdk) { "// Comments from Ubisoft SDK 1.56 where applicable" } `
               else          { "// No matching SDK 1.56 source found"               }
    $sep = "//============================================================================="
    return ($sep + "`n" +
            "// " + $className + " - extracted from retail RavenShield 1.60`n" +
            "// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)`n" +
            $sdkNote + "`n" +
            $sep + "`n")
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------
Write-Host "`nBuilding SDK 1.56 comment index ..." -ForegroundColor Cyan
$sdkIdx = Build-SdkIndex -sdkRoot $SdkDir

$buildName      = [UELib.UnrealPackage+GameBuild+BuildName]::R6RS
$totalClasses   = 0
$failedClasses  = 0
$failedPackages = [System.Collections.Generic.List[string]]::new()

foreach ($pkgFile in $packageMap.Keys) {
    $pkgPath = Join-Path $PackagesDir $pkgFile
    $outDir  = Join-Path $RepoRoot ($packageMap[$pkgFile])

    Write-Host "`n=== $pkgFile ===" -ForegroundColor Yellow

    if (-not (Test-Path $pkgPath)) {
        Write-Warning "  Package not found: $pkgPath  — skipping"
        $failedPackages.Add($pkgFile) | Out-Null
        continue
    }

    $pkg = $null
    try {
        $pkg = [UELib.UnrealLoader]::LoadPackage($pkgPath, $buildName, [System.IO.FileAccess]::Read)
        $pkg.InitializePackage()
    } catch {
        Write-Warning "  Failed to load package: $_"
        $failedPackages.Add($pkgFile) | Out-Null
        if ($null -ne $pkg) { try { $pkg.Dispose() } catch {} }
        continue
    }

    $exportedClasses = @()
    try {
        $exportedClasses = @(
            $pkg.Exports |
            Where-Object { $null -ne $_.Object -and $_.Object -is [UELib.Core.UClass] } |
            ForEach-Object { $_.Object }
        )
    } catch {
        Write-Warning "  Could not enumerate exports: $_"
    }

    Write-Host "  Exported classes: $($exportedClasses.Count)" -ForegroundColor Cyan

    if (-not (Test-Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    foreach ($cls in $exportedClasses) {
        $clsName = "(unknown)"
        try {
            $clsName = $cls.Name.ToString()

            # Decompile the class, normalize line endings to CRLF
            $raw = $cls.Decompile()
            if ([string]::IsNullOrWhiteSpace($raw)) {
                Write-Warning "  [EMPTY] $clsName"
                continue
            }
            $raw = $raw.Replace("`r`n", "`n").Replace("`r", "`n")

            # Fix concatenated class-header modifiers
            $raw = Fix-ClassHeader -text $raw

            # Look up matching SDK 1.56 file
            $sdkKey  = $clsName.ToLower()
            $sdk     = @{
                Found           = $false
                PreClassComment = ""
                VarInfo         = @{}
                FuncInfo        = @{}
                VarNames        = [System.Collections.Generic.HashSet[string]]::new()
                FuncNames       = [System.Collections.Generic.HashSet[string]]::new()
            }
            if ($sdkIdx.ContainsKey($sdkKey)) {
                $sdk = Parse-SdkFile -path $sdkIdx[$sdkKey]
            }

            # Merge SDK comments into the decompiled body
            $body = Merge-Comments -text $raw -sdk $sdk

            # Compose final file
            $banner = Make-Banner -className $clsName -hasSdk $sdk.Found
            $final  = $banner + $body

            $outPath = Join-Path $outDir "$clsName.uc"
            [System.IO.File]::WriteAllText($outPath, $final, (New-Object System.Text.UTF8Encoding $false))

            $totalClasses++
            Write-Host "  + $clsName" -ForegroundColor White
        } catch {
            Write-Warning "  [FAIL] $clsName : $_"
            $failedClasses++
        }
    }

    try { $pkg.Dispose() } catch {}
}

Write-Host "`n====================================================" -ForegroundColor Green
Write-Host "  Extracted : $totalClasses classes"                  -ForegroundColor Green
Write-Host "  Failed    : $failedClasses class errors"            -ForegroundColor $(if ($failedClasses -gt 0) { 'Red' } else { 'Green' })
if ($failedPackages.Count -gt 0) {
    Write-Host "  Failed packages: $($failedPackages -join ', ')" -ForegroundColor Red
}
Write-Host ""
