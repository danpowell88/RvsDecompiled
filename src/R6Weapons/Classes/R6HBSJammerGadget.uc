// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Weapons.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6HBSJammerGadget extends R6Gadget;

// --- Variables ---
//  Heart Beat Jammer ativated.
var bool m_bHeartBeatJammerOn;

// --- Functions ---
function ServerToggleHeartBeatJammerProperties(bool bGadgetOn) {}
simulated function TurnOnGadget(bool bGadgetOn) {}
// When we change player in the team we have to desactivate or reactivate the HBS
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController) {}
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

state PutWeaponDown
{
    simulated function BeginState() {}
}

state BringWeaponUp
{
    function FirstPersonAnimOver() {}
    simulated function EndState() {}
}

state RaiseWeapon
{
    function FirstPersonAnimOver() {}
    function BeginState() {}
    simulated function EndState() {}
}

state DiscardWeapon
{
    simulated function BeginState() {}
}

state NormalFire
{
    simulated function BeginState() {}
}

defaultproperties
{
}
