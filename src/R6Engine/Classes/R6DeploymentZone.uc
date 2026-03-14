//=============================================================================
//  R6DeploymentZone.uc : Zone for terrorist deployment
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/10 * Created by Guillaume Borgia
//=============================================================================
class R6DeploymentZone extends Actor
    native
    abstract;

#exec OBJ LOAD FILE=..\Textures\R6Engine_T.utx PACKAGE=R6Engine_T

// --- Constants ---
const C_NB_Template =  5;

// --- Structs ---
struct STTemplate
{
    var()   String  m_szName;
    var()   INT     m_iChance;
};

// --- Variables ---
var const array<array> m_aTerrorist;
var bool m_bUseGrenade;           // Allow terrorists in this zone to throw grenades
// ^ NEW IN 1.60
var array<array> m_pListOfCoverNodes;  // Cover nodes available to AI in this zone
// ^ NEW IN 1.60
var const array<array> m_aHostage;
var bool m_bClassicMissionCivilian;  // Mark zone occupants as civilians in classic mission mode
// ^ NEW IN 1.60
var int m_iChanceToUseGrenadeAtFirstReaction;  // Percentage chance (0-100) terrorist throws grenade on first alert
// ^ NEW IN 1.60
var R6InteractiveObject m_InteractiveObject;  // Interactive object AI in this zone will interact with
// ^ NEW IN 1.60
var EEngageReaction m_eEngageReaction;  // How terrorists in this zone react when they spot an enemy
// ^ NEW IN 1.60
var int m_HostageShootChance;    // Percentage chance terrorist shoots a hostage when threatened
// ^ NEW IN 1.60
var bool m_bHuntDisallowed;      // Prevent terrorists in this zone from actively hunting enemies
// ^ NEW IN 1.60
var bool m_bDontSeePlayer;       // Debug: terrorists here cannot visually detect the player
// ^ NEW IN 1.60
var bool m_bDontHearPlayer;      // Debug: terrorists here cannot hear the player
// ^ NEW IN 1.60
var bool m_bHearNothing;          // Terrorists in this zone ignore all sounds
// ^ NEW IN 1.60
var bool m_bAllowLeave;           // Allow terrorists to leave this zone when reacting
// ^ NEW IN 1.60
var bool m_bPreventCrouching;    // Prevent AI in this zone from crouching
// ^ NEW IN 1.60
var bool m_bKnowInPlanning;      // Show this zone's contents during mission planning phase
// ^ NEW IN 1.60
var bool m_bHuntFromStart;       // Terrorists immediately hunt enemies from mission start
// ^ NEW IN 1.60
var bool m_bAlreadyInitialized;
var int m_iGroupID;               // ID grouping this zone with others for coordinated AI reactions
// ^ NEW IN 1.60
var array<array> m_iGroupIDsToCall;  // List of group IDs to alert when this zone is triggered
// ^ NEW IN 1.60
var array<array> m_HostageZoneToCheck;  // Hostage zones monitored by terrorists in this zone
// ^ NEW IN 1.60
var EDefCon m_eDefCon;            // Default DEFCON (alert level) for terrorists in this zone
// ^ NEW IN 1.60
var int m_iMinTerrorist;          // Minimum number of terrorists spawned in this zone
// ^ NEW IN 1.60
var int m_iMaxTerrorist;          // Maximum number of terrorists spawned in this zone
// ^ NEW IN 1.60
var STTemplate m_Template[5];    // Up to 5 terrorist loadout templates for this zone
// ^ NEW IN 1.60
var int m_iMinHostage;            // Minimum number of hostages spawned in this zone
// ^ NEW IN 1.60
var int m_iMaxHostage;            // Maximum number of hostages spawned in this zone
// ^ NEW IN 1.60
var STTemplate m_HostageTemplates[5];  // Up to 5 hostage type templates for this zone
// ^ NEW IN 1.60
var int m_iPrisonerTeam;          // Team ID for CTE (Capture The Enemy) prisoner assignment
// ^ NEW IN 1.60

// --- Functions ---
final native function R6Hostage GetClosestHostage(Vector vPoint) {}
// ^ NEW IN 1.60
final native function OrderTerroListFromDistanceTo(Vector vPoint) {}
// ^ NEW IN 1.60
final native function AddHostage(R6Hostage hostage) {}
// ^ NEW IN 1.60
final native function Vector FindClosestPointTo(Vector vPoint) {}
// ^ NEW IN 1.60
final native function bool IsPointInZone(Vector vPoint) {}
// ^ NEW IN 1.60
final native function FirstInit() {}
// ^ NEW IN 1.60
final native function Vector FindRandomPointInArea() {}
// ^ NEW IN 1.60
final native function bool HaveTerrorist() {}
// ^ NEW IN 1.60
final native function bool HaveHostage() {}
// ^ NEW IN 1.60
function InitZone() {}
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}

defaultproperties
{
}
