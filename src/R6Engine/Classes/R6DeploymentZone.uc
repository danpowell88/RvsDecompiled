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
var bool m_bUseGrenade;
// ^ NEW IN 1.60
var array<array> m_pListOfCoverNodes;
// ^ NEW IN 1.60
var const array<array> m_aHostage;
var bool m_bClassicMissionCivilian;
// ^ NEW IN 1.60
var int m_iChanceToUseGrenadeAtFirstReaction;
// ^ NEW IN 1.60
var R6InteractiveObject m_InteractiveObject;
// ^ NEW IN 1.60
var EEngageReaction m_eEngageReaction;
// ^ NEW IN 1.60
var int m_HostageShootChance;
// ^ NEW IN 1.60
var bool m_bHuntDisallowed;
// ^ NEW IN 1.60
var bool m_bDontSeePlayer;
// ^ NEW IN 1.60
var bool m_bDontHearPlayer;
// ^ NEW IN 1.60
var bool m_bHearNothing;
// ^ NEW IN 1.60
var bool m_bAllowLeave;
// ^ NEW IN 1.60
var bool m_bPreventCrouching;
// ^ NEW IN 1.60
var bool m_bKnowInPlanning;
// ^ NEW IN 1.60
var bool m_bHuntFromStart;
// ^ NEW IN 1.60
var bool m_bAlreadyInitialized;
var int m_iGroupID;
// ^ NEW IN 1.60
var array<array> m_iGroupIDsToCall;
// ^ NEW IN 1.60
var array<array> m_HostageZoneToCheck;
// ^ NEW IN 1.60
var EDefCon m_eDefCon;
// ^ NEW IN 1.60
var int m_iMinTerrorist;
// ^ NEW IN 1.60
var int m_iMaxTerrorist;
// ^ NEW IN 1.60
var STTemplate m_Template[5];
// ^ NEW IN 1.60
var int m_iMinHostage;
// ^ NEW IN 1.60
var int m_iMaxHostage;
// ^ NEW IN 1.60
var STTemplate m_HostageTemplates[5];
// ^ NEW IN 1.60
var int m_iPrisonerTeam;
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
