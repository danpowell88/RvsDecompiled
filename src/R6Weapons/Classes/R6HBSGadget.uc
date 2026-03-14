// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Weapons.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6HBSGadget extends R6Gadget
    native;

#exec OBJ LOAD FILE="..\StaticMeshes\R63rdWeapons_SM.usx"  Package="R63rdWeapons_SM"

// --- Variables ---
// Heart Beat sensor activation.
var bool m_bHeartBeatOn;
var Sound m_sndDesactivation;
var Sound m_sndActivation;

// --- Functions ---
function ServerToggleHeartBeatProperties(bool bActiveHeartBeat) {}
// Display the HeartBeat in the map.
function DisplayHeartBeat(bool bActivateHeartBeat) {}
// When we change player in the team we have to desactivate or reactivate the HBS
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController) {}
// ^ NEW IN 1.60
final native function ToggleHeartBeatProperties(bool bTurnItOn) {}
// ^ NEW IN 1.60
simulated event bool IsGoggles() {}
// ^ NEW IN 1.60
// ----------------------------------------
// All This function do nothing in the HBS
function Fire(float fValue) {}
delegate StopFire(optional bool bSoundOnly) {}
function AltFire(float fValue) {}
function StopAltFire() {}
// When the player change the weapon we have to desactivate the HBS
simulated function RemoveFirstPersonWeapon() {}
// Turn off the heart beat sensor
simulated function DisableWeaponOrGadget() {}
function StartLoopingAnims() {}

state DiscardWeapon
{
    simulated function BeginState() {}
    simulated function EndState() {}
}

state PutWeaponDown
{
    simulated function BeginState() {}
}

state BringWeaponUp
{
    simulated function BeginState() {}
    simulated function EndState() {}
    function FirstPersonAnimOver() {}
}

state RaiseWeapon
{
    function FirstPersonAnimOver() {}
    simulated function EndState() {}
    simulated function BeginState() {}
}

state NormalFire
{
    simulated function BeginState() {}
}

defaultproperties
{
}
