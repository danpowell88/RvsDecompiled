//=============================================================================
// R6MObjPreventKillInDepZone - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MObjPreventKillInDepZone.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjPreventKillInDepZone extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

var() R6DeploymentZone m_depZone;  // neutralize terro in this deployment zone

function Init()
{
	local int iTotal;
	local R6Terrorist aTerrorist;

	// End:0x6A
	if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
	{
		// End:0x6A
		if((m_depZone != none))
		{
			// End:0x6A
			if((m_depZone.m_aTerrorist.Length == 0))
			{
				logMObj(("there is no terrorist in " $ string(m_depZone.Name)));
			}
		}
	}
	return;
}

function PawnKilled(Pawn killed)
{
	local float fNeutralized;
	local int iTotal;
	local R6Terrorist aTerrorist;
	local int i, iResult;

	// End:0x1B
	if((int(killed.m_ePawnType) != int(2)))
	{
		return;
	}
	// End:0xA8
	if((m_depZone != none))
	{
		aTerrorist = R6Terrorist(killed);
		// End:0x50
		if((m_depZone != aTerrorist.m_DZone))
		{
			return;
		}
		// End:0xA8
		if((!aTerrorist.IsAlive()))
		{
			// End:0x91
			if(m_bShowLog)
			{
				logX(("PawnKilled failed=" $ string(m_bFailed)));
			}
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
		}
	}
	return;
}

defaultproperties
{
	m_bVisibleInMenu=false
	m_bIfFailedMissionIsAborted=true
	m_szDescription="Dont kill pawn in this depzone"
}
