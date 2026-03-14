//=============================================================================
// R6TerroristMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TerroristMgr.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:  Terrorist AI manager for interaction with hostage
//    2001/12/03 * Created by Guillaume Borgia
//=============================================================================
class R6TerroristMgr extends R6
    AbstractTerroristMgr
    native;

const MAX_Hostage = 16;

struct STHostage
{
	var R6Hostage hostage;
	var R6TerroristAI terro;
	var int bInZone;
};

var int m_iCurrentMax;
var int m_iCurrentGroupID;
// List of DZone with hostage associated
var const array<R6DeploymentZone> m_aDeploymentZoneWithHostage;
// NEW IN 1.60
var STHostage m_ArrayHostage[16];

// Export UR6TerroristMgr::execInit(FFrame&, void* const)
// Init the manager.  Dummy actor can be anything, just needed to have a pointer on the level
native(1825) final function Init(Actor dummy);

// Export UR6TerroristMgr::execFindNearestZoneForHostage(FFrame&, void* const)
// Get the zone in wich the terrorist must go to park the hostage
native(1826) final function R6DeploymentZone FindNearestZoneForHostage(R6Terrorist terro);

function Initialization(Actor dummy)
{
	__NFUN_1825__(dummy);
	return;
}

//============================================================================
// ResetOriginalData - 
//============================================================================
function ResetOriginalData()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x53 [Loop If]
	if(__NFUN_150__(i, 16))
	{
		m_ArrayHostage[i].hostage = none;
		m_ArrayHostage[i].terro = none;
		m_ArrayHostage[i].bInZone = 0;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	m_iCurrentMax = 0;
	return;
}

//============================================================================
// FindHostageIndex - 
//============================================================================
function int FindHostageIndex(R6Hostage hostage)
{
	local int i;

	// End:0x2A
	if(__NFUN_155__(hostage.m_iIndex, -1))
	{
		return hostage.m_iIndex;		
	}
	else
	{
		__NFUN_165__(m_iCurrentMax);
		assert(__NFUN_150__(m_iCurrentMax, 16));
		m_ArrayHostage[m_iCurrentMax].hostage = hostage;
		hostage.m_iIndex = m_iCurrentMax;
		return m_iCurrentMax;
	}
	return;
}

//============================================================================
// IsHostageAssigned - 
//============================================================================
function bool IsHostageAssigned(R6Hostage hostage)
{
	local int i;

	i = FindHostageIndex(hostage);
	// End:0x2F
	if(__NFUN_154__(int(hostage.m_ePersonality), int(3)))
	{
		return true;		
	}
	else
	{
		return __NFUN_132__(__NFUN_119__(m_ArrayHostage[i].terro, none), __NFUN_154__(m_ArrayHostage[i].bInZone, 1));
	}
	return;
}

//============================================================================
// AssignHostageTo - 
//============================================================================
function AssignHostageTo(R6Hostage hostage, R6TerroristAI terro)
{
	local int i;
	local R6DeploymentZone Zone;

	i = FindHostageIndex(hostage);
	m_ArrayHostage[i].terro = terro;
	m_ArrayHostage[i].bInZone = 0;
	return;
}

//============================================================================
// AssignHostageToZone - 
//============================================================================
function AssignHostageToZone(R6Hostage hostage, R6DeploymentZone Zone)
{
	local int i;

	i = FindHostageIndex(hostage);
	m_ArrayHostage[i].terro = none;
	m_ArrayHostage[i].bInZone = 1;
	Zone.__NFUN_1836__(hostage);
	return;
}

//============================================================================
// RemoveHostageAssignment - 
//============================================================================
function RemoveHostageAssignment(R6Hostage hostage)
{
	local int i;

	i = FindHostageIndex(hostage);
	m_ArrayHostage[i].terro = none;
	m_ArrayHostage[i].bInZone = 0;
	return;
}

defaultproperties
{
	m_iCurrentMax=-1
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_ArrayHostageMAX_Hostage
