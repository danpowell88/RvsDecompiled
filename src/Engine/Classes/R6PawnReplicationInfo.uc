//=============================================================================
// R6PawnReplicationInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PawnReplicationInfo.uc : replicates weapon's infos
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/11 * Created by Serge Dor�
//=============================================================================
class R6PawnReplicationInfo extends Actor
    native
    notplaceable;

var byte m_PawnType;  // REPLICATED: Pawn Type
var bool m_bSex;  // REPLICATED: Sex of the player
var bool m_bDoNotPlayFullAutoSound;  // Assure that the sound will not be played when the player is dead.
var Controller m_ControllerOwner;  // REPLICATED: Owner
var Sound m_TriggerSnd[4];
var Sound m_SingleFireStereoSnd[4];
var Sound m_SingleFireEndStereoSnd[4];
var Sound m_BurstFireStereoSnd[4];
var Sound m_FullAutoStereoSnd[4];
var Sound m_FullAutoEndStereoSnd[4];
var Sound m_EmptyMagSnd[4];
var Sound m_ReloadEmptySnd[4];
var Sound m_ReloadSnd[4];
var Sound m_ShellSingleFireSnd[4];
var Sound m_ShellBurstFireSnd[4];
var Sound m_ShellFullAutoSnd[4];
var Sound m_ShellEndFullAutoSnd[4];

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_ControllerOwner, m_PawnType, 
		m_bSex;
}

simulated function ResetOriginalData()
{
	super.ResetOriginalData();
	m_bDoNotPlayFullAutoSound = false;
	return;
}

// only set on the client side
simulated function AssignSound(Class<R6EngineWeapon> WeaponClass, byte u8CurrentWepon)
{
	// End:0x2F3
	if(__NFUN_119__(WeaponClass, none))
	{
		m_TriggerSnd[int(u8CurrentWepon)] = WeaponClass.default.m_TriggerSnd;
		m_SingleFireStereoSnd[int(u8CurrentWepon)] = WeaponClass.default.m_SingleFireStereoSnd;
		m_SingleFireEndStereoSnd[int(u8CurrentWepon)] = WeaponClass.default.m_SingleFireEndStereoSnd;
		m_BurstFireStereoSnd[int(u8CurrentWepon)] = WeaponClass.default.m_BurstFireStereoSnd;
		m_FullAutoStereoSnd[int(u8CurrentWepon)] = WeaponClass.default.m_FullAutoStereoSnd;
		m_FullAutoEndStereoSnd[int(u8CurrentWepon)] = WeaponClass.default.m_FullAutoEndStereoSnd;
		m_ReloadSnd[int(u8CurrentWepon)] = WeaponClass.default.m_ReloadSnd;
		m_ReloadEmptySnd[int(u8CurrentWepon)] = WeaponClass.default.m_ReloadEmptySnd;
		m_EmptyMagSnd[int(u8CurrentWepon)] = WeaponClass.default.m_EmptyMagSnd;
		m_ShellSingleFireSnd[int(u8CurrentWepon)] = WeaponClass.default.m_ShellSingleFireSnd;
		m_ShellBurstFireSnd[int(u8CurrentWepon)] = WeaponClass.default.m_ShellBurstFireSnd;
		m_ShellFullAutoSnd[int(u8CurrentWepon)] = WeaponClass.default.m_ShellFullAutoSnd;
		m_ShellEndFullAutoSnd[int(u8CurrentWepon)] = WeaponClass.default.m_ShellEndFullAutoSnd;
		__NFUN_2717__(WeaponClass.default.m_EquipSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_UnEquipSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_ReloadSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_ReloadEmptySnd, 3);
		__NFUN_2717__(WeaponClass.default.m_ChangeROFSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_SingleFireStereoSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_SingleFireEndStereoSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_BurstFireStereoSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_FullAutoStereoSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_FullAutoEndStereoSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_EmptyMagSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_TriggerSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_ShellSingleFireSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_ShellBurstFireSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_ShellFullAutoSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_ShellEndFullAutoSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_SniperZoomFirstSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_SniperZoomSecondSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_CommonWeaponZoomSnd, 3);
		__NFUN_2717__(WeaponClass.default.m_BipodSnd, 3);
	}
	return;
}

defaultproperties
{
	m_PawnType=1
	RemoteRole=3
	DrawType=0
	bHidden=true
	bAlwaysRelevant=true
	bSkipActorPropertyReplication=true
	NetUpdateFrequency=5.0000000
}
