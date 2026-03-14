//=============================================================================
//  R6IOObject : This should allow action moves on the door
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6IOObject extends R6IActionObject
    native;

#exec OBJ LOAD FILE=..\StaticMeshes\R6ActionObjects.usx PACKAGE=R6ActionObjects
#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons

// --- Enums ---
enum eStateIOObejct
{
    SIO_Start,
    SIO_Interrupt,
    SIO_Complete
};
enum eDeviceCircumstantialAction
{
    DCA_None,
    DCA_DisarmBomb,
    DCA_ArmBomb,
	DCA_Device
};

// --- Variables ---
var /* replicated */ bool m_bIsActivated;
// ^ NEW IN 1.60
var eDeviceAnimToPlay m_eAnimToPlay;
// ^ NEW IN 1.60
// time the object started to be used. Only one pawn can interact with this object
var float m_fLockObjectTime;
var float m_fGainTimeWithElectronicsKit;
// ^ NEW IN 1.60
var bool m_bToggleType;
// ^ NEW IN 1.60
var eStateIOObejct m_ObjectState;
var /* replicated */ bool sm_bIsActivated;
var Sound m_CompletedSnd;
var Sound m_InterruptedSnd;
var Sound m_StartSnd;
var bool sm_bToggleType;

// --- Functions ---
simulated function ToggleDevice(R6Pawn aPawn) {}
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}
simulated function float GetTimeRequired(R6Pawn aPawn) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
// GetMaxTimeRequired
//	used to unlock an IOObject that was locked
//------------------------------------------------------------------
simulated function float GetMaxTimeRequired() {}
// ^ NEW IN 1.60
simulated function bool CanToggle() {}
// ^ NEW IN 1.60
simulated function bool HasKit(R6Pawn aPawn) {}
// ^ NEW IN 1.60
//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
simulated function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query) {}
simulated function R6CircumstantialActionCancel() {}
//===========================================================================//
// R6GetCircumstantialActionProgress()                                       //
//   Update the device planting progress                                     //
//   Should be affected by the skills of the pawn planting it                //
//===========================================================================//
simulated function int R6GetCircumstantialActionProgress(Pawn actingPawn, R6AbstractCircumstantialActionQuery Query) {}
// ^ NEW IN 1.60
function PerformSoundAction(eStateIOObejct eState) {}
//------------------------------------------------------------------
// LockObjectUse
//
//------------------------------------------------------------------
simulated function LockObjectUse(bool bIsInUse) {}
//------------------------------------------------------------------
// SaveOriginalData
//
//------------------------------------------------------------------
simulated function SaveOriginalData() {}

defaultproperties
{
}
