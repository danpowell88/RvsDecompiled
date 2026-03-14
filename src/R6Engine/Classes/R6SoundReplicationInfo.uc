//=============================================================================
// R6SoundReplicationInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6SoundReplicationInfo.uc : replicates weapon's infos
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/11 * Created by Jean-Francois Dube
//=============================================================================
class R6SoundReplicationInfo extends Actor
	native
 notplaceable;

var byte m_CurrentWeapon;  // REPLICATED: What weapon they use righ now
var byte m_NewWeaponSound;  // REPLICATED: Contain the sound to play
var byte m_NewPawnState;  // REPLICATED: contain : m_GunSoundType, m_PawnState
var byte m_Material;  // REPLICATED: m_Material
var byte m_pawnState;
var byte m_TeamColor;
var byte m_GunSoundType;
var byte m_StatusOtherTeam;
var byte m_LastPlayedWeaponSound;  // Only use on client side
var bool m_bInitialize;
var bool m_bLastSoundFullAuto;
var float m_fClientUpdateFrequency;  // SERVER: Replication update frequency in seconds
var float m_fClientLastUpdate;  // SERVER: Last replication update
var R6Pawn m_pawnOwner;  // REPLICATED: Pawn
var R6PawnReplicationInfo m_PawnRepInfo;  // REPLICATED: PawnReplicationInfo for each in controller for each pawn
var Vector m_Location;  // REPLICATED: Location

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_Location, m_Material, 
		m_NewPawnState;

	// Pos:0x00D
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_CurrentWeapon, m_NewWeaponSound, 
		m_PawnRepInfo, m_pawnOwner;
}

// Export UR6SoundReplicationInfo::execPlayWeaponSound(FFrame&, void* const)
 native(2727) final function PlayWeaponSound(R6EngineWeapon.EWeaponSound EWeaponSound);

// Export UR6SoundReplicationInfo::execStopWeaponSound(FFrame&, void* const)
 native(2728) final function StopWeaponSound();

// Export UR6SoundReplicationInfo::execPlayLocalWeaponSound(FFrame&, void* const)
 native(3000) final function PlayLocalWeaponSound(R6EngineWeapon.EWeaponSound EWeaponSound);

// NEW IN 1.60
function Destroyed()
{
	m_pawnOwner = none;
	super.Destroyed();
	return;
}

defaultproperties
{
	m_fClientUpdateFrequency=1.0000000
	RemoteRole=3
	DrawType=0
	bHidden=true
	bSkipActorPropertyReplication=true
	m_fSoundRadiusActivation=5600.0000000
	NetUpdateFrequency=10.0000000
}
