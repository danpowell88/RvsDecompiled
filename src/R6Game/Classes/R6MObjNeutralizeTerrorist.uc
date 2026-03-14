//=============================================================================
// R6MObjNeutralizeTerrorist - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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
		if(__NFUN_119__(m_depZone, none))
		{
			// End:0x6A
			if(__NFUN_154__(m_depZone.m_aTerrorist.Length, 0))
			{
				logMObj(__NFUN_112__("there is no terrorist in ", string(m_depZone.Name)));
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
	if(__NFUN_155__(int(secured.m_ePawnType), int(2)))
	{
		return;
	}
	// End:0x197
	if(__NFUN_119__(m_depZone, none))
	{
		aTerrorist = R6Terrorist(secured);
		// End:0x50
		if(__NFUN_119__(m_depZone, aTerrorist.m_DZone))
		{
			return;
		}
		i = 0;
		J0x57:

		// End:0x194 [Loop If]
		if(__NFUN_150__(i, m_depZone.m_aTerrorist.Length))
		{
			aTerrorist = m_depZone.m_aTerrorist[i];
			// End:0x13D
			if(m_bMustSecureTerroInDepZone)
			{
				// End:0x10A
				if(__NFUN_129__(aTerrorist.IsAlive()))
				{
					R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
					// End:0x108
					if(m_bShowLog)
					{
						logX(__NFUN_112__(__NFUN_112__("PawnKilled failed=", string(m_bFailed)), " should have been secured"));
					}
					return;
				}
				// End:0x13A
				if(__NFUN_132__(aTerrorist.m_bIsKneeling, aTerrorist.m_bIsUnderArrest))
				{
					__NFUN_184__(fNeutralized, float(1));
				}				
			}
			else
			{
				// End:0x183
				if(__NFUN_132__(__NFUN_132__(__NFUN_129__(aTerrorist.IsAlive()), aTerrorist.m_bIsKneeling), aTerrorist.m_bIsUnderArrest))
				{
					__NFUN_184__(fNeutralized, float(1));
				}
			}
			__NFUN_163__(iTotal);
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x57;
		}		
	}
	else
	{
		fNeutralized = float(R6GameInfo(m_mgr.Level.Game).GetNbTerroNeutralized());
		// End:0x1E6
		foreach m_mgr.__NFUN_313__(Class'R6Engine.R6Terrorist', aTerrorist)
		{
			__NFUN_163__(iTotal);			
		}		
	}
	// End:0x235
	if(__NFUN_151__(iTotal, 0))
	{
		iResult = int(__NFUN_171__(__NFUN_172__(fNeutralized, float(iTotal)), 100.0000000));
		// End:0x235
		if(__NFUN_153__(iResult, m_iNeutralizePercentage))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
		}
	}
	// End:0x2B2
	if(m_bShowLog)
	{
		logX(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("PawnSecured/Killed. completed=", string(m_bCompleted)), " neutralized="), string(secured.Name)), " "), string(iResult)), "/"), string(m_iNeutralizePercentage)), "%"));
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
