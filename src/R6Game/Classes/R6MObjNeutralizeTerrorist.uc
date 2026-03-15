//=============================================================================
// R6MObjNeutralizeTerrorist - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MObjNeutralizeTerrorist.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// fail: if m_bMustSecureTerroInDepZone and the terro is dead
// success: once m_iNeutralizePercentage is reached
//
// example: 
//  - kill or secure all terro in the level
//  - kill or secure a group of terro (specify deployment zone) 
//  - kill or secure a specific terro (specify deployment zone) 
//  - secure a specific terro (specify deployment zone & m_bMustSecureTerroInDepZone) 
//=============================================================================
class R6MObjNeutralizeTerrorist extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

var() int m_iNeutralizePercentage;
var() bool m_bMustSecureTerroInDepZone;  // must secure the terro, if kill failed
var() R6DeploymentZone m_depZone;  // neutralize terro in this deployment zone

function Init()
{
	local int iTotal;
	local R6Terrorist aTerrorist;

	// End:0xEB
	if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
	{
		// End:0x6D
		if((m_depZone != none))
		{
			// End:0x6A
			if((m_depZone.m_aTerrorist.Length == 0))
			{
				logMObj(("there is no terrorist in " $ string(m_depZone.Name)));
			}			
		}
		else
		{
			// End:0xC3
			if(m_bMustSecureTerroInDepZone)
			{
				logMObj("m_bMustSecureTerroInDepZone was enabled but without a deployment zone");
			}
			R6GameInfo(m_mgr.Level.Game).CheckForTerrorist(self, 1);
		}
	}
	return;
}

function PawnKilled(Pawn killed)
{
	PawnSecure(killed);
	return;
}

function PawnSecure(Pawn secured)
{
	local float fNeutralized;
	local int iTotal;
	local R6Terrorist aTerrorist;
	local int i, iResult;

	// End:0x1B
	if((int(secured.m_ePawnType) != int(2)))
	{
		return;
	}
	// End:0x197
	if((m_depZone != none))
	{
		aTerrorist = R6Terrorist(secured);
		// End:0x50
		if((m_depZone != aTerrorist.m_DZone))
		{
			return;
		}
		i = 0;
		J0x57:

		// End:0x194 [Loop If]
		if((i < m_depZone.m_aTerrorist.Length))
		{
			aTerrorist = m_depZone.m_aTerrorist[i];
			// End:0x13D
			if(m_bMustSecureTerroInDepZone)
			{
				// End:0x10A
				if((!aTerrorist.IsAlive()))
				{
					R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
					// End:0x108
					if(m_bShowLog)
					{
						logX((("PawnKilled failed=" $ string(m_bFailed)) $ " should have been secured"));
					}
					return;
				}
				// End:0x13A
				if((aTerrorist.m_bIsKneeling || aTerrorist.m_bIsUnderArrest))
				{
					(fNeutralized += float(1));
				}				
			}
			else
			{
				// End:0x183
				if((((!aTerrorist.IsAlive()) || aTerrorist.m_bIsKneeling) || aTerrorist.m_bIsUnderArrest))
				{
					(fNeutralized += float(1));
				}
			}
			(++iTotal);
			(++i);
			// [Loop Continue]
			goto J0x57;
		}		
	}
	else
	{
		fNeutralized = float(R6GameInfo(m_mgr.Level.Game).GetNbTerroNeutralized());
		// End:0x1E6
		foreach m_mgr.DynamicActors(Class'R6Engine.R6Terrorist', aTerrorist)
		{
			(++iTotal);			
		}		
	}
	// End:0x235
	if((iTotal > 0))
	{
		iResult = int(((fNeutralized / float(iTotal)) * 100.0000000));
		// End:0x235
		if((iResult >= m_iNeutralizePercentage))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
		}
	}
	// End:0x2B2
	if(m_bShowLog)
	{
		logX((((((((("PawnSecured/Killed. completed=" $ string(m_bCompleted)) $ " neutralized=") $ string(secured.Name)) $ " ") $ string(iResult)) $ "/") $ string(m_iNeutralizePercentage)) $ "%"));
	}
	return;
}

defaultproperties
{
	m_iNeutralizePercentage=100
	m_bIfCompletedMissionIsSuccessfull=true
	m_szDescription="Neutralize all terrorist"
	m_szDescriptionInMenu="NeutralizeAllTerrorist"
}
