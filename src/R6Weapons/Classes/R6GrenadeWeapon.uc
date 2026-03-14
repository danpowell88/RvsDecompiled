//=============================================================================
//  R6GrenadeWeapon.uc : "Weapon" used for throwing grenades
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/07/09 * Created by Sebastien Lussier
//    2001/11/07 * taken over by Joel Tremblay
//=============================================================================
class R6GrenadeWeapon extends R6Gadget
    native
    abstract;

// --- Variables ---
var eGrenadeThrow m_eThrow;
var bool m_bFistPersonAnimFinish;
var bool m_bCanThrowGrenade;
var bool m_bReadyToThrow;
var bool m_bPinToRemove;

// --- Functions ---
// function ? ShowInfo(...); // REMOVED IN 1.60
function ServerSetGrenade(eGrenadeThrow eGrenade) {}
function Fire(float fValue) {}
function ThrowGrenade() {}
function DestroyReticules() {}
simulated function DropGrenade() {}
simulated function PostBeginPlay() {}
simulated function WeaponInitialization(Pawn pawnOwner) {}
delegate ServerSetThrow(eGrenadeThrow eThrow) {}
delegate ServerImReadyToThrow(bool bReady) {}
simulated function StartFalling() {}
function float GetExplosionDelay() {}
// ^ NEW IN 1.60
function ClientThrowGrenade() {}
//------------------------------------------------------------------
// GetSaveDistanceToThrow: return the save distance from the grenade
//	to be for avoiding any harm.
//------------------------------------------------------------------
function float GetSaveDistanceToThrow() {}
// ^ NEW IN 1.60
simulated event HideAttachment() {}
function bool CanSwitchToWeapon() {}
// ^ NEW IN 1.60

state StandByToThrow
{
    function BeginState() {}
    function Fire(float fValue) {}
    function AltFire(float fValue) {}
    function FirstPersonAnimOver() {}
}

state DiscardWeapon
{
    simulated function BeginState() {}
    function Fire(float Value) {}
    function AltFire(float Value) {}
    function StopFire(optional bool bSoundOnly) {}
    function StopAltFire() {}
    function PlayReloading() {}
    simulated function EndState() {}
}

state ReadyToThrow
{
    simulated function Tick(float fDeltaTime) {}
    function Fire(float fValue) {}
    function AltFire(float fValue) {}
    delegate StopFire(optional bool bSoundOnly) {}
    function StopAltFire() {}
    function BeginState() {}
    function FirstPersonAnimOver() {}
}

state WaitEndOfThrow
{
    function Fire(float fValue) {}
    function AltFire(float fValue) {}
    delegate StopFire(optional bool bSoundOnly) {}
    function StopAltFire() {}
    function FirstPersonAnimOver() {}
    simulated function Tick(float fDeltaTime) {}
    function BeginState() {}
}

state NoGrenadeLeft
{
    function Fire(float fValue) {}
    delegate StopFire(optional bool bSoundOnly) {}
    function AltFire(float fValue) {}
    function StopAltFire() {}
    function BeginState() {}
}

state RaiseWeapon
{
    function FirstPersonAnimOver() {}
    simulated function EndState() {}
    simulated function BeginState() {}
}

state PutWeaponDown
{
    simulated function BeginState() {}
}

state BringWeaponUp
{
    simulated function BeginState() {}
    function FirstPersonAnimOver() {}
    simulated function EndState() {}
}

defaultproperties
{
}
