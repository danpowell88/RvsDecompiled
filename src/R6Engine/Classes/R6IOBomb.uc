//=============================================================================
//  R6IOBomb : This should allow action moves on the door
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOBomb extends R6IOObject
    native;

// --- Constants ---
const C_fBombTimerInterval =  0.1;

// --- Enums ---
enum ESoundBeepBomb
{
    SBB_Normal,
    SBB_Fast,
    SBB_Faster
};

// --- Variables ---
// if 0, the bomb has unlimited time
var float m_fTimeLeft;
// time replicated and computed on the client. send by server every X sec.
var /* replicated */ float m_fRepTimeLeft;
var /* replicated */ bool m_bExploded;
var ESoundBeepBomb m_eBeepState;
var float m_fLastLevelTime;
var Sound m_sndPlayBeepFaster;
var Sound m_sndPlayBeepFast;
var int m_iEnergy;                // Structural integrity; bomb detonates when this reaches zero via damage
// ^ NEW IN 1.60
var Sound m_sndStopBeepFaster;
var Sound m_sndStopBeepFast;
var float m_fTimeOfExplosion;
var bool bShowLog;                // Enable verbose bomb-state debug logging
// ^ NEW IN 1.60
var Sound m_sndPlayBeepNormal;
var float m_fKillBlastRadius;     // Inner radius of the explosion where damage is fatal
// ^ NEW IN 1.60
var float m_fDisarmBombTimeMax;   // Maximum time (seconds) required to disarm this bomb
// ^ NEW IN 1.60
var float m_fDisarmBombTimeMin;   // Minimum time (seconds) required to disarm this bomb
// ^ NEW IN 1.60
var string m_szMissionObjLocalization;  // Localization key for the mission objective text tied to this bomb
// ^ NEW IN 1.60
var class<Light> m_pExplosionLight;
var Sound m_sndEarthQuake;
var Sound m_sndExplosion;
var Sound m_sndActivationBomb;
var float m_fExplosionRadius;     // Radius of the damaging explosion when this bomb detonates
// ^ NEW IN 1.60
var Material m_ArmedTexture;      // Texture displayed on the bomb mesh when it is armed
// ^ NEW IN 1.60
// msg shown:                 Bomb A
var string m_szIdentity;
var string m_szIdentityID;        // Unique string identifier for this bomb, used by objectives/scripting
// ^ NEW IN 1.60
var Vector m_vOffset;
var string m_szMsgArmedID;        // Localization key for the HUD message shown when bomb is armed
// ^ NEW IN 1.60
var string m_szMsgDisarmedID;     // Localization key for the HUD message shown when bomb is disarmed
// ^ NEW IN 1.60

// --- Functions ---
simulated function Timer() {}
//------------------------------------------------------------------
// ForceTimeLeft
//
//------------------------------------------------------------------
function ForceTimeLeft(float fTime) {}
function bool ArmBomb(R6Pawn aPawn) {}
function bool DisarmBomb(R6Pawn aPawn) {}
simulated function bool HasKit(R6Pawn aPawn) {}
// ^ NEW IN 1.60
simulated function string R6GetCircumstantialActionString(int iAction) {}
// ^ NEW IN 1.60
simulated function float GetTimeRequired(R6Pawn aPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// DetonateBomb
//	will explode only if the bomb was activated
//------------------------------------------------------------------
simulated function DetonateBomb(optional R6Pawn P) {}
simulated function ToggleDevice(R6Pawn aPawn) {}
//------------------------------------------------------------------
// HurtActor
//
//------------------------------------------------------------------
function HurtActor(Actor aActor) {}
simulated event R6QueryCircumstantialAction(out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController, float fDistance) {}
simulated function PostBeginPlay() {}
simulated function string GetMissionObjLocFile() {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
simulated function bool CanToggle() {}
// ^ NEW IN 1.60
simulated function float GetTimeLeft() {}
// ^ NEW IN 1.60
function ChangeSoundBomb() {}
function StartBombSound() {}
function StopSoundBomb() {}
simulated function float GetMaxTimeRequired() {}
// ^ NEW IN 1.60

defaultproperties
{
}
