$file = "C:\Users\danpo\Desktop\rvs\ghidra\exports\R6Engine\_global.cpp"
$content = [System.IO.File]::ReadAllLines($file)
$funcs = @(
    @("AdjustFluidCollisionCylinder", 5300, 5430),
    @("Crawl", 15352, 15620),
    @("GetCurrentMaterial", 17445, 17475),
    @("ResetColBox", 25187, 25300),
    @("UnCrawl", 28724, 28900),
    @("UpdateColBox", 35392, 35700),
    @("UpdateMovementAnimation", 36314, 36500),
    @("UpdatePawnTrackActor", 37157, 37200),
    @("UpdatePeeking", 37196, 37400),
    @("actorReachableFromLocation", 38905, 39000),
    @("calcVelocity", 39171, 39280),
    @("execCheckCylinderTranslation", 41713, 41800),
    @("execFootStep", 43166, 43280),
    @("execPawnTrackActor", 46326, 46390),
    @("execToggleScopeProperties", 47553, 47700),
    @("execUpdatePawnTrackActor", 47664, 47730),
    @("performPhysics", 53617, 53795),
    @("physLadder", 53795, 53960)
)
foreach ($f in $funcs) {
    $name = $f[0]; $start = $f[1]-1; $end = $f[2]-1
    $body = $content[$start..$end]
    $found = $body | Where-Object { $_ -match "FUN_" } | Select-Object -First 3
    if ($found) {
        Write-Output ("=== " + $name + " HAS FUN_ ===")
        $found | ForEach-Object { Write-Output ("  " + $_) }
    } else {
        Write-Output ("=== " + $name + " clean ===")
    }
}
