//=============================================================================
// R6MObjRescueHostage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MObjRescueHostage.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// success: if enough hostage are rescued in the extraction zone
// fail: if there's too much dead hostage/civilian to complete the mission
//
// example: 
//  - rescue all hostage
//  - rescue a specific hostage (specify the m_depZone)
//  - rescue a specific group hostage (specify the m_depZone)
// 
// ** no difference between a hostage and a civilian
//=============================================================================
class R6MObjRescueHostage extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

                                                        // ** OR **
var() int m_iRescuePercentage;  // minimum nb of hostage to rescue.
var() bool m_bRescueAllRemainingHostage;  // rescue all hostage until there's no one alive
var() bool m_bCheckPawnKilled;
var() R6DeploymentZone m_depZone;  // rescure hostage in this deployment zone

//------------------------------------------------------------------
// Init
//	
//------------------------------------------------------------------
function Init()
{
	local int iTotal;
	local R6Hostage aHostage;
	local R6ExtractionZone aExtractZone;

	// End:0xBA
	if(R6MissionObjectiveMgr(m_mgr).m_bEnableCheckForErrors)
	{
		// End:0x6B
		if((m_depZone != none))
		{
			// End:0x68
			if((m_depZone.m_aHostage.Length == 0))
			{
				logMObj(("there is no hostage in " $ string(m_depZone.Name)));
			}			
		}
		else
		{
			R6GameInfo(m_mgr.Level.Game).CheckForHostage(self, 1);
		}
		R6GameInfo(m_mgr.Level.Game).CheckForExtractionZone(self);
	}
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	local R6Hostage H, aHostage;
	local float fTotalDeath;
	local int iTotal, i;

	// End:0x0D
	if((!m_bCheckPawnKilled))
	{
		return;
	}
	// End:0x28
	if((int(killedPawn.m_ePawnType) != int(3)))
	{
		return;
	}
	H = R6Hostage(killedPawn);
	// End:0x4C
	if(H.m_bCivilian)
	{
		return;
	}
	// End:0xD2
	if((m_depZone != none))
	{
		// End:0x71
		if((m_depZone != H.m_DZone))
		{
			return;
		}
		i = 0;
		J0x78:

		// End:0xCF [Loop If]
		if((i < m_depZone.m_aHostage.Length))
		{
			// End:0xBE
			if((!m_depZone.m_aHostage[i].IsAlive()))
			{
				(fTotalDeath += float(1));
			}
			(++iTotal);
			(++i);
			// [Loop Continue]
			goto J0x78;
		}		
	}
	else
	{
		// End:0x125
		foreach m_mgr.DynamicActors(Class'R6Engine.R6Hostage', aHostage)
		{
			// End:0x124
			if((!aHostage.m_bCivilian))
			{
				// End:0x11D
				if((!aHostage.IsAlive()))
				{
					(fTotalDeath += float(1));
				}
				(++iTotal);
			}			
		}		
	}
	// End:0x15A
	if(m_bRescueAllRemainingHostage)
	{
		// End:0x157
		if((fTotalDeath == float(iTotal)))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
		}		
	}
	else
	{
		// End:0x1A7
		if(((fTotalDeath > float(0)) && ((float(100) - ((fTotalDeath / float(iTotal)) * 100.0000000)) <= float(m_iRescuePercentage))))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
		}
	}
	// End:0x206
	if(m_bShowLog)
	{
		logX((((((("PawnKilled. failed=" $ string(m_bFailed)) $ " ") $ string(((fTotalDeath / float(iTotal)) * 100.0000000))) $ "/") $ string(m_iRescuePercentage)) $ "%"));
	}
	return;
}

function EnteredExtractionZone(Pawn aPawn)
{
	local R6Hostage H, aHostage;
	local float fRescuedNum;
	local int iTotal, i, iTotalAlive;

	// End:0x1B
	if((int(aPawn.m_ePawnType) != int(3)))
	{
		return;
	}
	H = R6Hostage(aPawn);
	// End:0x3F
	if(H.m_bCivilian)
	{
		return;
	}
	// End:0xFB
	if((m_depZone != none))
	{
		// End:0x64
		if((m_depZone != H.m_DZone))
		{
			return;
		}
		i = 0;
		J0x6B:

		// End:0xF8 [Loop If]
		if((i < m_depZone.m_aHostage.Length))
		{
			aHostage = m_depZone.m_aHostage[i];
			// End:0xEE
			if((!aHostage.m_bCivilian))
			{
				// End:0xE7
				if(aHostage.IsAlive())
				{
					(iTotalAlive++);
					// End:0xE7
					if(aHostage.m_bExtracted)
					{
						(fRescuedNum += float(1));
					}
				}
				(++iTotal);
			}
			(++i);
			// [Loop Continue]
			goto J0x6B;
		}		
	}
	else
	{
		// End:0x165
		foreach m_mgr.DynamicActors(Class'R6Engine.R6Hostage', aHostage)
		{
			// End:0x164
			if((!aHostage.m_bCivilian))
			{
				// End:0x15D
				if(aHostage.IsAlive())
				{
					(iTotalAlive++);
					// End:0x15D
					if(aHostage.m_bExtracted)
					{
						(fRescuedNum += float(1));
					}
				}
				(++iTotal);
			}			
		}		
	}
	// End:0x19A
	if(m_bRescueAllRemainingHostage)
	{
		// End:0x197
		if((fRescuedNum == float(iTotalAlive)))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
		}		
	}
	else
	{
		// End:0x1D2
		if((((fRescuedNum / float(iTotal)) * 100.0000000) >= float(m_iRescuePercentage)))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
		}
	}
	// End:0x238
	if(m_bShowLog)
	{
		logX((((((("EnteredExtZone. completed=" $ string(m_bCompleted)) $ " ") $ string(((fRescuedNum / float(iTotal)) * 100.0000000))) $ "/") $ string(m_iRescuePercentage)) $ "%"));
	}
	return;
}

function string GetDescriptionBasedOnNbOfHostages(LevelInfo Level)
{
	local R6Hostage aHostage;
	local int iTotal;

	// End:0x49
	foreach Level.DynamicActors(Class'R6Engine.R6Hostage', aHostage)
	{
		// End:0x48
		if((aHostage.IsAlive() && (!aHostage.m_bCivilian)))
		{
			(++iTotal);
		}		
	}	
	switch(iTotal)
	{
		// End:0x78
		case 1:
			return "RescueTheHostageToExtractionZone";
		// End:0xA2
		case 2:
			return "RescueBothHostagesToExtractionZone";
		// End:0xCD
		case 3:
			return "RescueThreeHostagesToExtractionZone";
		// End:0xFFFF
		default:
			return "RescueAllHostagesToExtractionZone";
			break;
	}
	return;
}

defaultproperties
{
	m_iRescuePercentage=100
	m_bCheckPawnKilled=true
	m_bIfFailedMissionIsAborted=true
	m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_HostageKilled'
	m_szDescription="Rescue hostage"
	m_szDescriptionInMenu="RescueAllHostagesToExtractionZone"
}
