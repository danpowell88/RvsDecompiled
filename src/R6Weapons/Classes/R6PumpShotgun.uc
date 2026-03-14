//============================================================================//
//  R6Shotgun.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6PumpShotgun extends R6Shotgun;

// --- Functions ---
simulated function AddClips(int iNbOfExtraClips) {}
simulated function bool GunIsFull() {}
// ^ NEW IN 1.60
simulated function bool IsPumpShotGun() {}
// ^ NEW IN 1.60
//Function called only on client, Add a shell before it's replicated.
//To fix a problem with reload animations and network lag.
function ClientAddShell() {}
delegate ServerPutBulletInShotgun() {}

state Reloading
{
    function int GetReloadProgress() {}
// ^ NEW IN 1.60
    event Tick(float fDeltaTime) {}
    function EndState() {}
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
    simulated function ChangeClip() {}
}

state NormalFire
{
    function Fire(float Value) {}
    function EndState() {}
}

defaultproperties
{
}
