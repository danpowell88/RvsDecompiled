//=============================================================================
// R6MObjAcceptableLosses - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MObjAcceptableLosses.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MObjAcceptableLosses extends R6MissionObjectiveBase
    abstract
	editinlinenew
    hidecategories(Object);

var Actor.EPawnType m_ePawnTypeKiller;
var Actor.EPawnType m_ePawnTypeDead;
var() int m_iAcceptableLost;
var int m_iKillerTeamID;
var() bool m_bConsiderSuicide;

function Reset()
{
	super.Reset();
	m_iKillerTeamID = default.m_iKillerTeamID;
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killed)
{
	local int iLost;
	local R6Pawn aPawn;
	local float fTotal;

	// End:0x1E
	if((int(killed.m_ePawnType) != int(m_ePawnTypeDead)))
	{
		return;
	}
	// End:0x60
	if((m_iKillerTeamID != -1))
	{
		aPawn = R6Pawn(killed);
		// End:0x60
		if((aPawn.m_KilledBy.m_iTeam != m_iKillerTeamID))
		{
			return;
		}
	}
	// End:0x1AB
	foreach m_mgr.DynamicActors(Class'R6Engine.R6Pawn', aPawn)
	{
		// End:0x99
		if((int(aPawn.m_ePawnType) != int(m_ePawnTypeDead)))
		{
			continue;			
		}
		// End:0xE3
		if((int(aPawn.m_ePawnType) == int(3)))
		{
			// End:0xE3
			if((R6Hostage(killed).m_bCivilian != R6Hostage(aPawn).m_bCivilian))
			{
				continue;				
			}
		}
		(fTotal += float(1));
		// End:0x103
		if(aPawn.IsAlive())
		{
			continue;			
		}
		// End:0x1AA
		if((((m_bConsiderSuicide && aPawn.m_bSuicided) || ((aPawn.m_bSuicided == false) && (int(m_ePawnTypeKiller) == int(4)))) || (int(aPawn.m_KilledBy.m_ePawnType) == int(m_ePawnTypeKiller))))
		{
			// End:0x1AA
			if(((m_iKillerTeamID == -1) || (aPawn.m_KilledBy.m_iTeam == m_iKillerTeamID)))
			{
				(iLost += 1);
			}
		}		
	}	
	iLost = int(((float(iLost) / fTotal) * 100.0000000));
	// End:0x24E
	if(((iLost >= 100) || ((iLost > 0) && (iLost > m_iAcceptableLost))))
	{
		// End:0x237
		if(m_bShowLog)
		{
			logX((" failed: iLost > m_iAcceptableLost=" $ string((iLost > m_iAcceptableLost))));
		}
		R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
	}
	// End:0x2FC
	if(m_bShowLog)
	{
		aPawn = R6Pawn(killed);
		logX(((((((((("PawnKilled failed=" $ string(m_bFailed)) $ " ") $ string(killed.Name)) $ " was killed by ") $ string(aPawn.m_KilledBy.Name)) $ " lost=") $ string(iLost)) $ " acceptable=") $ string(m_iAcceptableLost)));
	}
	return;
}

defaultproperties
{
	m_iKillerTeamID=-1
	m_bConsiderSuicide=true
	m_bIfFailedMissionIsAborted=true
	m_bMoralityObjective=true
}
