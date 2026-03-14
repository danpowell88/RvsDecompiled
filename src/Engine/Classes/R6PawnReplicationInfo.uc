//=============================================================================
//  R6PawnReplicationInfo.uc : replicates weapon's infos
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/11 * Created by Serge Dor�
//=============================================================================
class R6PawnReplicationInfo extends Actor
    native;

// --- Variables ---
var Sound m_ShellEndFullAutoSnd[4];
var Sound m_ShellFullAutoSnd[4];
var Sound m_ShellBurstFireSnd[4];
var Sound m_ShellSingleFireSnd[4];
var Sound m_ReloadSnd[4];
var Sound m_ReloadEmptySnd[4];
var Sound m_EmptyMagSnd[4];
var Sound m_FullAutoEndStereoSnd[4];
var Sound m_FullAutoStereoSnd[4];
var Sound m_BurstFireStereoSnd[4];
var Sound m_SingleFireEndStereoSnd[4];
var Sound m_SingleFireStereoSnd[4];
var Sound m_TriggerSnd[4];
// Assure that the sound will not be played when the player is dead.
var bool m_bDoNotPlayFullAutoSound;
// REPLICATED: Owner
var /* replicated */ Controller m_ControllerOwner;
// REPLICATED: Pawn Type
var /* replicated */ byte m_PawnType;
// REPLICATED: Sex of the player
var /* replicated */ bool m_bSex;

// --- Functions ---
// only set on the client side
simulated function AssignSound(class<R6EngineWeapon> WeaponClass, byte u8CurrentWepon) {}
simulated function ResetOriginalData() {}

defaultproperties
{
}
