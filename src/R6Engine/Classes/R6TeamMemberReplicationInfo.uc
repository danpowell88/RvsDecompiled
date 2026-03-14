//=============================================================================
// R6TeamMemberReplicationInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TeamReplicationInfo.uc : replicates pawn's location for the team's member
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/05 * Created by Jean-Francois Dube
//=============================================================================
class R6TeamMemberReplicationInfo extends Actor
    native
    notplaceable;

var byte m_RotationYaw;  // REPLICATED: Short Rotation. Use in the Ingame Map
var byte m_BlinkCounter;  // REPLICATED: Used to know that we need to start blinking
var byte m_iTeamPosition;  // REPLICATED: Position of the character in his team
var byte m_eHealth;  // REPLICATED: Owners's health
var byte m_BlinkCounterOld;  // CLIENTS: Used to know that the server requested blinking
var int m_iTeam;  // REPLICATED: Owner's team
var int m_iTeamId;  // REPLICATED: Owner's team ID
var bool m_bIsPrimaryGadgetEmpty;  // REPLICATED: Is the character still have primary gadgets
var bool m_bIsSecondaryGadgetEmpty;  // REPLICATED: Is the character still have secondary gadgets
var bool m_bIsPilot;  // REPLICATED: Is this pawn the pilot?
// NEW IN 1.60
var bool m_bIsIntruder;
// NEW IN 1.60
var bool m_bHasFloppy;
var float m_fLastCommunicationTime;  // CLIENTS: Blinking time
var float m_fClientUpdateFrequency;  // SERVER: Replication update frequency in seconds
var float m_fClientLastUpdate;  // SERVER: Last replication update
// NEW IN 1.60
var float m_fCompteurFrameDetection;
var Vector m_Location;  // REPLICATED: Location
var string m_CharacterName;  // REPLICATED: Character Name. Use in InGame Map and Operative Selector
var string m_PrimaryWeapon;  // REPLICATED: Primary Weapon ID
var string m_SecondaryWeapon;  // REPLICATED: Secondary Weapon ID
var string m_PrimaryGadget;  // REPLICATED: Primary Gadget ID
var string m_SecondaryGadget;  // REPLICATED: Secondary Gadget ID

replication
{
	// Pos:0x000
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_BlinkCounter, m_CharacterName, 
		m_Location, m_PrimaryGadget, 
		m_PrimaryWeapon, m_RotationYaw, 
		m_SecondaryGadget, m_SecondaryWeapon, 
		m_bIsPilot, m_bIsPrimaryGadgetEmpty, 
		m_bIsSecondaryGadgetEmpty, m_eHealth, 
		m_iTeam, m_iTeamId, 
		m_iTeamPosition;

	// Pos:0x00D
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		m_bHasFloppy, m_bIsIntruder, 
		m_fCompteurFrameDetection;
}

defaultproperties
{
	m_iTeamId=-1
	m_fClientUpdateFrequency=0.2000000
	RemoteRole=3
	DrawType=0
	bHidden=true
	bSkipActorPropertyReplication=true
	NetUpdateFrequency=5.0000000
}
