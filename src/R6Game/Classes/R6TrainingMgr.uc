//=============================================================================
//  R6TrainingMgr.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/19 * Created by Guillaume Borgia
//=============================================================================
class R6TrainingMgr extends R6PracticeModeGame;

// --- Constants ---
const C_NbWeapons =  12;

// --- Enums ---
enum ETrainingWeapons
{
    TW_SMG,
    TW_Pistol,
    TW_Sniper,
    TW_HBSensor,
    TW_Assault,
    TW_AssaultSilenced,
    TW_LMG,
    TW_Shotgun,
    TW_Grenades,
    TW_BreachCharge,
    TW_RemoteCharge,
    TW_Claymore,
    TW_MAX
};

// --- Variables ---
var R6EngineWeapon m_Weapons[12];
var string m_WeaponsName[12];
var int m_WeaponsSlot[12];
var ETrainingWeapons m_eCurrentWeapon;
var bool m_bInitialized;

// --- Functions ---
function LoadPlanningInTraining() {}
//============================================================================
// SwitchToWeapon -
//============================================================================
function SwitchToWeapon(ETrainingWeapons eWT, bool bSwitch) {}
//============================================================================
// LoadWeapons -
//============================================================================
function LoadWeapons() {}
//============================================================================
// ShowWeaponAndAttachment -
//============================================================================
function ShowWeaponAndAttachment(bool bShow, R6EngineWeapon AWeapon) {}
//============================================================================
// LaunchAction -
//============================================================================
function LaunchAction(int iSoundIndex, int iBoxNb) {}
//============================================================================
// DeployCharacters -
//============================================================================
function DeployCharacters(PlayerController ControlledByPlayer) {}
function EndGame(string Reason, PlayerReplicationInfo Winner) {}
//============================================================================
// ResetGunAmmo -
//============================================================================
function ResetGunAmmo() {}
function bool IsBasicMap() {}
// ^ NEW IN 1.60
function string GetIntelVideoName(R6MissionDescription Desc) {}
// ^ NEW IN 1.60
//============================================================================
// Object GetTrainingMgr -
//============================================================================
function R6TrainingMgr GetTrainingMgr(R6Pawn P) {}
// ^ NEW IN 1.60
//============================================================================
// BOOL CanChangeText -
//============================================================================
function bool CanChangeText(int iBoxNumber) {}
// ^ NEW IN 1.60
//------------------------------------------------------------------
//
//
//------------------------------------------------------------------
function float GetEndGamePauseTime() {}
// ^ NEW IN 1.60

defaultproperties
{
}
