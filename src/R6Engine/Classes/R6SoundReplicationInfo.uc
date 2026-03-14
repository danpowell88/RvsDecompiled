//=============================================================================
//  R6SoundReplicationInfo.uc : replicates weapon's infos
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/11 * Created by Jean-Francois Dube
//=============================================================================
class R6SoundReplicationInfo extends Actor
    native;

// --- Variables ---
// var ? m_PawnOwner; // REMOVED IN 1.60
// var ? m_PawnState; // REMOVED IN 1.60
// REPLICATED: What weapon they use righ now
var /* replicated */ byte m_CurrentWeapon;
var /* replicated */ R6Pawn m_pawnOwner;
// ^ NEW IN 1.60
// REPLICATED: PawnReplicationInfo for each in controller for each pawn
var /* replicated */ R6PawnReplicationInfo m_PawnRepInfo;
// REPLICATED: Contain the sound to play
var /* replicated */ byte m_NewWeaponSound;
// REPLICATED: Location
var /* replicated */ Vector m_Location;
// REPLICATED: contain : m_GunSoundType, m_PawnState
var /* replicated */ byte m_NewPawnState;
// REPLICATED: m_Material
var /* replicated */ byte m_Material;
//     SERVER: Replication update frequency in seconds
var float m_fClientUpdateFrequency;
//     SERVER: Last replication update
var float m_fClientLastUpdate;
var byte m_pawnState;
// ^ NEW IN 1.60
var byte m_TeamColor;
var byte m_GunSoundType;
var byte m_StatusOtherTeam;
var bool m_bInitialize;
var bool m_bLastSoundFullAuto;
// Only use on client side
var byte m_LastPlayedWeaponSound;

// --- Functions ---
final native function PlayLocalWeaponSound(EWeaponSound EWeaponSound) {}
final native function PlayWeaponSound(EWeaponSound EWeaponSound) {}
final native function StopWeaponSound() {}
function Destroyed() {}

defaultproperties
{
}
