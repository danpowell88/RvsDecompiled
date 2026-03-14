//=============================================================================
// R6DeploymentZone - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DeploymentZone.uc : Zone for terrorist deployment
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/10 * Created by Guillaume Borgia
//=============================================================================
class R6DeploymentZone extends Actor
    abstract
    native
    notplaceable;

const C_NB_Template = 5;

struct STTemplate
{
	var() string m_szName;
	var() int m_iChance;
};

var(R6DZoneTerrorist) R6Terrorist.EDefCon m_eDefCon;
var(R6DZoneTerrorist) R6TerroristAI.EEngageReaction m_eEngageReaction;
var(R6DZoneTerrorist) int m_iGroupID;
var(R6DZoneTerrorist) int m_HostageShootChance;
var(R6DZoneTerrorist) int m_iMinTerrorist;
var(R6DZoneTerrorist) int m_iMaxTerrorist;
// NEW IN 1.60
var(R6DZoneTerrorist) int m_iChanceToUseGrenadeAtFirstReaction;
var(R6DZoneHostage) int m_iMinHostage;
var(R6DZoneHostage) int m_iMaxHostage;
// NEW IN 1.60
var(R6DZoneHostage) int m_iPrisonerTeam;
var(Debug) bool m_bDontSeePlayer;  // Only for debug purpose
var(Debug) bool m_bDontHearPlayer;  // Only for debug purpose
var(Debug) bool m_bHearNothing;  // Only for debug purpose
var(R6DZoneTerrorist) bool m_bAllowLeave;
var(R6DZoneTerrorist) bool m_bPreventCrouching;
var(R6DZoneTerrorist) bool m_bKnowInPlanning;
var(R6DZoneTerrorist) bool m_bHuntDisallowed;
var(R6DZoneTerrorist) bool m_bHuntFromStart;
var bool m_bAlreadyInitialized;
// NEW IN 1.60
var(R6DZoneTerrorist) bool m_bUseGrenade;
// NEW IN 1.60
var(MP2Civilian) bool m_bClassicMissionCivilian;
var(R6DZoneTerrorist) R6InteractiveObject m_InteractiveObject;
var(R6DZoneTerrorist) editinline array<editinline int> m_iGroupIDsToCall;
var(R6DZoneTerrorist) array<R6DeploymentZone> m_HostageZoneToCheck;
// NEW IN 1.60
var(MP2Civilian) array<PathNode> m_pListOfCoverNodes;
var const array<R6Terrorist> m_aTerrorist;
var const array<R6Hostage> m_aHostage;
// NEW IN 1.60
var(R6DZoneTerrorist) STTemplate m_Template[5];
// NEW IN 1.60
var(R6DZoneHostage) STTemplate m_HostageTemplates[5];

// Export UR6DeploymentZone::execFirstInit(FFrame&, void* const)
native(1830) final function FirstInit();

// Export UR6DeploymentZone::execFindRandomPointInArea(FFrame&, void* const)
native(1831) final function Vector FindRandomPointInArea();

// Export UR6DeploymentZone::execIsPointInZone(FFrame&, void* const)
native(1832) final function bool IsPointInZone(Vector vPoint);

// Export UR6DeploymentZone::execFindClosestPointTo(FFrame&, void* const)
native(1833) final function Vector FindClosestPointTo(Vector vPoint);

// Export UR6DeploymentZone::execHaveTerrorist(FFrame&, void* const)
native(1834) final function bool HaveTerrorist();

// Export UR6DeploymentZone::execHaveHostage(FFrame&, void* const)
native(1835) final function bool HaveHostage();

// Export UR6DeploymentZone::execAddHostage(FFrame&, void* const)
native(1836) final function AddHostage(R6Hostage hostage);

// Export UR6DeploymentZone::execOrderTerroListFromDistanceTo(FFrame&, void* const)
native(1837) final function OrderTerroListFromDistanceTo(Vector vPoint);

// Export UR6DeploymentZone::execGetClosestHostage(FFrame&, void* const)
native(1838) final function R6Hostage GetClosestHostage(Vector vPoint);

function InitZone()
{
	__NFUN_1830__();
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super.ResetOriginalData();
	m_aTerrorist.Remove(0, m_aTerrorist.Length);
	m_aHostage.Remove(0, m_aHostage.Length);
	return;
}

defaultproperties
{
	m_eDefCon=3
	m_iMinTerrorist=1
	m_iMaxTerrorist=1
	m_iChanceToUseGrenadeAtFirstReaction=100
	m_bAllowLeave=true
	m_bKnowInPlanning=true
	m_bUseGrenade=true
	bStatic=true
	bHidden=true
	bNoDelete=true
	m_bUseR6Availability=true
	DrawScale=3.0000000
	CollisionRadius=40.0000000
	CollisionHeight=85.0000000
	Texture=Texture'R6Engine_T.Icons.DZoneTer'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_TemplateC_NB_Template
// REMOVED IN 1.60: var m_HostageTemplatesC_NB_Template
