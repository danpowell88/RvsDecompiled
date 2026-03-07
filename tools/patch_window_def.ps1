# patch_window_def.ps1
# Comments out unresolved symbols in Window.def by prepending ";  "

$unresolvedPath = "C:\Users\danpo\Desktop\rvs\build\window_unresolved.txt"
$defPath = "C:\Users\danpo\Desktop\rvs\src\window\Window.def"

# Read unresolved symbols into a HashSet for O(1) lookup
$unresolvedSymbols = [System.Collections.Generic.HashSet[string]]::new()
foreach ($line in (Get-Content $unresolvedPath)) {
    $sym = $line.Trim()
    if ($sym -ne "") {
        [void]$unresolvedSymbols.Add($sym)
    }
}
Write-Host "Loaded $($unresolvedSymbols.Count) unresolved symbols"

# Read .def file lines
$defLines = Get-Content $defPath
$commentedCount = 0
$outputLines = [System.Collections.Generic.List[string]]::new($defLines.Count)

foreach ($defLine in $defLines) {
    $trimmed = $defLine.TrimStart()

    # Skip header lines (LIBRARY, EXPORTS, blank, already commented)
    if ($trimmed -eq "" -or $trimmed.StartsWith("LIBRARY") -or $trimmed.StartsWith("EXPORTS") -or $trimmed.StartsWith(";")) {
        $outputLines.Add($defLine)
        continue
    }

    # Extract the symbol name (everything before the first whitespace run preceding @ordinal)
    # Lines look like: "    ?Symbol@@XXX    @123"
    # Split on whitespace to get the symbol part
    $parts = $trimmed -split '\s+'
    $symbol = $parts[0]

    if ($unresolvedSymbols.Contains($symbol)) {
        $outputLines.Add(";  " + $defLine)
        $commentedCount++
    } else {
        $outputLines.Add($defLine)
    }
}

Write-Host "Commented out $commentedCount lines in Window.def"
Write-Host "Total .def lines: $($defLines.Count)"

# Write back
$outputLines | Set-Content $defPath -Encoding UTF8
Write-Host "Window.def patched successfully."
