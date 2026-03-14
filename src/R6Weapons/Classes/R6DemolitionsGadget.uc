//=============================================================================
//  R6DemolitionsGadget.uc : Abstract base for demolitions gadget inventory items.
//  Extends R6Gadget; subclassed by R6BreachingChargeGadget, R6ClaymoreGadget, R6RemoteChargeGadget.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Rima Brek
//=============================================================================
class R6DemolitionsGadget extends R6Gadget
    native
    abstract;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Variables ---
// var ? m_pDetonatorReticuleClass; // REMOVED IN 1.60
// var ? m_pReticuleBlockClass; // REMOVED IN 1.60
var /* replicated */ R6Grenade BulletActor;
var bool m_bRaiseWeapon;
var bool m_bChargeInPosition;
var bool m_bInstallingCharge;
var bool m_bDetonated;
var /* replicated */ bool m_bDetonator;
var R6Reticule m_ReticuleConfirm;
var Vector m_vLocation;
var R6Reticule m_ReticuleBlock;
var R6Reticule m_ReticuleDetonator;
var /* replicated */ bool m_bHide;
var bool m_bCancelChargeInstallation;
var bool m_bCanPlaceCharge;
// 1st person
var StaticMesh m_DetonatorStaticMesh;
var name m_DetonatorAttachPoint;
var name m_ChargeAttachPoint;
// 3rd person
var StaticMesh m_ChargeStaticMesh;
var string m_szDetonatorReticuleClass;
// ^ NEW IN 1.60
var string m_szReticuleBlockClass;
// ^ NEW IN 1.60
var class<Emitter> m_pExplosionParticles;
var Texture m_DetonatorTexture;

// --- Functions ---
// function ? ShowInfo(...); // REMOVED IN 1.60
function Fire(float fValue) {}
delegate ServerPlaceChargeAnimation() {}
function PlaceChargeAnimation() {}
function SetAmmoStaticMesh() {}
delegate ServerPlaceCharge(Vector vLocation) {}
simulated event HideAttachment() {}
simulated function Tick(float fDeltaTime) {}
function StopAltFire() {}
function AltFire(float fValue) {}
delegate StopFire(optional bool bSoundOnly) {}
delegate ServerDetonate() {}
event NbBulletChange() {}
// this must be redefined in each demolitions gadget class
simulated function bool CanPlaceCharge() {}
// ^ NEW IN 1.60
function bool CanSwitchToWeapon() {}
// ^ NEW IN 1.60
simulated function R6SetReticule(optional Controller LocalPlayerController) {}
function DestroyReticules() {}
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController) {}
// ^ NEW IN 1.60
simulated function PostNetBeginPlay() {}
function Activate() {}
event PostBeginPlay() {}
simulated function UpdateHands() {}
function ClientMyUnitIsDestroyed() {}
function MyUnitIsDestroyed() {}
//When changing charter, this is to start playing the wait animations.
function StartLoopingAnims() {}
function SwitchToDetonatorHandAnimations() {}
function SwitchToChargeHandAnimations() {}
//Delete the first person weapon.  To keep only one in memory
simulated function RemoveFirstPersonWeapon() {}
function HideReticule() {}
delegate ServerGotoSetExplosive() {}
delegate ServerCancelChargeInstallation() {}
simulated function CancelChargeInstallation() {}
simulated event SetGadgetStaticMesh() {}

state RaiseWeapon
{
    simulated function EndState() {}
    simulated function FirstPersonAnimOver() {}
    simulated function BeginState() {}
    function Fire(float Value) {}
    function AltFire(float Value) {}
    function StopFire(optional bool bSoundOnly) {}
    function StopAltFire() {}
    function PlayReloading() {}
}

state GetNextCharge
{
    function BeginState() {}
    function FirstPersonAnimOver() {}
    function Fire(float fValue) {}
    function StopFire(optional bool bSoundOnly) {}
    function AltFire(float fValue) {}
    function StopAltFire() {}
}

state ChargeReady
{
	// set timer for placing charge - check demolitions skill...
    function Timer() {}
    function Fire(float fValue) {}
    function BeginState() {}
    function EndState() {}
    function FirstPersonAnimOver() {}
}

state NoChargesLeft
{
    function BeginState() {}
    function FirstPersonAnimOver() {}
    function Fire(float fValue) {}
    function StopFire(optional bool bSoundOnly) {}
    function AltFire(float fValue) {}
    function StopAltFire() {}
}

state ChargeArmed
{
    function BeginState() {}
    function EndState() {}
    function FirstPersonAnimOver() {}
    function Fire(float fValue) {}
}

state DiscardWeapon
{
    function Fire(float Value) {}
    function AltFire(float Value) {}
    function StopFire(optional bool bSoundOnly) {}
    function StopAltFire() {}
    function PlayReloading() {}
    simulated function BeginState() {}
}

state BringWeaponUp
{
    simulated function BeginState() {}
    simulated function FirstPersonAnimOver() {}
    simulated function EndState() {}
}

defaultproperties
{
}
