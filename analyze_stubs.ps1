param(
    [string]$CppFile
)

function Detect-Stubs {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath"
        return
    }
    
    $content = Get-Content $FilePath -Raw
    $lines = Get-Content $FilePath
    
    # Remove C-style comments but keep important markers
    $cleaned = $content -replace '/\*.*?\*/', ''
    
    # Find all function definitions
    $functionPattern = '^\s*(?:FORCEINLINE|inline|virtual|static|const)?\s*(?:void|int|bool|float|FVector|FRotator|UBOOL|DWORD|HANDLE|UINT|[\w:]+\*?)\s+(\w+)\s*\([^)]*\)\s*(?:const)?\s*\{'
    
    $functions = [regex]::Matches($content, $functionPattern, [Text.RegularExpressions.RegexOptions]::Multiline)
    
    $stubs = @()
    $totalFuncs = 0
    $divergenceOnStubs = @()
    
    foreach ($funcMatch in $functions) {
        $totalFuncs++
        $funcName = $funcMatch.Groups[1].Value
        $startPos = $funcMatch.Index + $funcMatch.Length
        
        # Find matching closing brace
        $braceCount = 1
        $pos = $startPos
        $bodyStart = $startPos
        
        while ($pos -lt $content.Length -and $braceCount -gt 0) {
            if ($content[$pos] -eq '{') { $braceCount++ }
            elseif ($content[$pos] -eq '}') { $braceCount-- }
            $pos++
        }
        
        if ($braceCount -eq 0) {
            $bodyEnd = $pos - 1
            $body = $content.Substring($bodyStart, $bodyEnd - $bodyStart)
            
            # Normalize whitespace
            $normalized = $body -replace '\s+', ' ' -replace '^\s*|\s*$'
            $normalized = $normalized -replace '//.*?$', '' # Remove line comments
            $normalized = $normalized -replace '/\*.*?\*/', '' # Remove block comments
            $normalized = $normalized -replace '^\s*|\s*$'
            
            # Check if it's a stub
            $isStub = $false
            
            # Empty body
            if ([string]::IsNullOrWhiteSpace($normalized)) {
                $isStub = $true
            }
            # Only guard/unguard
            elseif ($normalized -match '^\s*guard\s*\([^)]*\)\s*;\s*unguard\s*;\s*$') {
                $isStub = $true
            }
            # Only return with no real work
            elseif ($normalized -match '^\s*(?:guard\s*\([^)]*\)\s*;)?\s*(?:return\s+(?:0|false|NULL|nullptr|TRUE|FALSE|FVector\s*\(\s*0\s*,\s*0\s*,\s*0\s*\)|FRotator\(\)|void))\s*;\s*(?:unguard\s*;)?\s*$') {
                $isStub = $true
            }
            # Only appUnimplemented
            elseif ($normalized -match '^\s*appUnimplemented\s*\(\s*\)\s*;\s*$') {
                $isStub = $true
            }
            # Only TODO comment
            elseif ($normalized -match '^\s*// TODO') {
                $isStub = $true
            }
            
            if ($isStub) {
                $stubs += $funcName
                
                # Check for DIVERGENCE comment in context around function
                $funcLineStart = $content.Substring(0, $funcMatch.Index).Split("`n").Count - 1
                $searchStart = [Math]::Max(0, $funcLineStart - 5)
                $searchEnd = [Math]::Min($lines.Count, $funcLineStart + 20)
                $context = $lines[$searchStart..$searchEnd] -join "`n"
                
                if ($context -like "*DIVERGENCE*") {
                    $divergenceOnStubs += @{
                        Function = $funcName
                        Context = $context
                    }
                }
            }
        }
    }
    
    [PSCustomObject]@{
        File = $FilePath
        TotalFunctions = $totalFuncs
        StubCount = $stubs.Count
        Stubs = $stubs
        DivergenceOnStubs = $divergenceOnStubs
    }
}

Detect-Stubs -FilePath $CppFile
