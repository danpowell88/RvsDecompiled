//=============================================================================
//  R6TeamReplicationInfo.uc : replicates pawn's location for the team's member
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/05 * Created by Jean-Francois Dube
//=============================================================================
class R6TeamMemberReplicationInfo extends Actor
    native;

// --- Variables ---
// var ? m_iTeamID; // REMOVED IN 1.60
// REPLICATED: Character Name. Use in InGame Map and Operative Selector
var /* replicated */ string m_CharacterName;
// REPLICATED: Owner's team
var /* replicated */ int m_iTeam;
// REPLICATED: Position of the character in his team
var /* replicated */ byte m_iTeamPosition;
// REPLICATED: Primary Weapon ID
var /* replicated */ string m_PrimaryWeapon;
// REPLICATED: Secondary Weapon ID
var /* replicated */ string m_SecondaryWeapon;
// REPLICATED: Primary Gadget ID
var /* replicated */ string m_PrimaryGadget;
// REPLICATED: Secondary Gadget ID
var /* replicated */ string m_SecondaryGadget;
// REPLICATED: Is the character still have primary gadgets
var /* replicated */ bool m_bIsPrimaryGadgetEmpty;
// REPLICATED: Is the character still have secondary gadgets
var /* replicated */ bool m_bIsSecondaryGadgetEmpty;
// REPLICATED: Short Rotation. Use in the Ingame Map
var /* replicated */ byte m_RotationYaw;
// REPLICATED: Location
var /* replicated */ Vector m_Location;
// REPLICATED: Used to know that we need to start blinking
var /* replicated */ byte m_BlinkCounter;
var /* replicated */ int m_iTeamId;   // Network team identifier for this member
// ^ NEW IN 1.60
// REPLICATED: Owners's health
var /* replicated */ byte m_eHealth;
// REPLICATED: Is this pawn the pilot?
var /* replicated */ bool m_bIsPilot;
//    CLIENTS: Used to know that the server requested blinking
var byte m_BlinkCounterOld;
//    CLIENTS: Blinking time
var float m_fLastCommunicationTime;
//     SERVER: Replication update frequency in seconds
var float m_fClientUpdateFrequency;
//     SERVER: Last replication update
var float m_fClientLastUpdate;
var /* replicated */ bool m_bIsIntruder; // True when this member is the designated intruder in CTE mode
// ^ NEW IN 1.60
var /* replicated */ bool m_bHasFloppy;  // True when this member is carrying the floppy disk objective
// ^ NEW IN 1.60
var /* replicated */ float m_fCompteurFrameDetection; // Replicated frame counter used for client-side speed-hack detection
// ^ NEW IN 1.60

defaultproperties
{
}
