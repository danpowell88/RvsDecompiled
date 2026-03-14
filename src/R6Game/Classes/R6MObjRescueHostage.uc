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
		if(__NFUN_119__(m_depZone, none))
		{
			// End:0x68
			if(__NFUN_154__(m_depZone.m_aHostage.Length, 0))
			{
				logMObj(__NFUN_112__("there is no hostage in ", string(m_depZone.Name)));
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
	if(__NFUN_129__(m_bCheckPawnKilled))
	{
		return;
	}
	// End:0x28
	if(__NFUN_155__(int(killedPawn.m_ePawnType), int(3)))
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
	if(__NFUN_119__(m_depZone, none))
	{
		// End:0x71
		if(__NFUN_119__(m_depZone, H.m_DZone))
		{
			return;
		}
		i = 0;
		J0x78:

		// End:0xCF [Loop If]
		if(__NFUN_150__(i, m_depZone.m_aHostage.Length))
		{
			// End:0xBE
			if(__NFUN_129__(m_depZone.m_aHostage[i].IsAlive()))
			{
				__NFUN_184__(fTotalDeath, float(1));
			}
			__NFUN_163__(iTotal);
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x78;
		}		
	}
	else
	{
		// End:0x125
		foreach m_mgr.__NFUN_313__(Class'R6Engine.R6Hostage', aHostage)
		{
			// End:0x124
			if(__NFUN_129__(aHostage.m_bCivilian))
			{
				// End:0x11D
				if(__NFUN_129__(aHostage.IsAlive()))
				{
					__NFUN_184__(fTotalDeath, float(1));
				}
				__NFUN_163__(iTotal);
			}			
		}		
	}
	// End:0x15A
	if(m_bRescueAllRemainingHostage)
	{
		// End:0x157
		if(__NFUN_180__(fTotalDeath, float(iTotal)))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
		}		
	}
	else
	{
		// End:0x1A7
		if(__NFUN_130__(__NFUN_177__(fTotalDeath, float(0)), __NFUN_178__(__NFUN_175__(float(100), __NFUN_171__(__NFUN_172__(fTotalDeath, float(iTotal)), 100.0000000)), float(m_iRescuePercentage))))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
		}
	}
	// End:0x206
	if(m_bShowLog)
	{
		logX(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("PawnKilled. failed=", string(m_bFailed)), " "), string(__NFUN_171__(__NFUN_172__(fTotalDeath, float(iTotal)), 100.0000000))), "/"), string(m_iRescuePercentage)), "%"));
	}
	return;
}

function EnteredExtractionZone(Pawn aPawn)
{
	local R6Hostage H, aHostage;
	local float fRescuedNum;
	local int iTotal, i, iTotalAlive;

	// End:0x1B
	if(__NFUN_155__(int(aPawn.m_ePawnType), int(3)))
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
	if(__NFUN_119__(m_depZone, none))
	{
		// End:0x64
		if(__NFUN_119__(m_depZone, H.m_DZone))
		{
			return;
		}
		i = 0;
		J0x6B:

		// End:0xF8 [Loop If]
		if(__NFUN_150__(i, m_depZone.m_aHostage.Length))
		{
			aHostage = m_depZone.m_aHostage[i];
			// End:0xEE
			if(__NFUN_129__(aHostage.m_bCivilian))
			{
				// End:0xE7
				if(aHostage.IsAlive())
				{
					__NFUN_165__(iTotalAlive);
					// End:0xE7
					if(aHostage.m_bExtracted)
					{
						__NFUN_184__(fRescuedNum, float(1));
					}
				}
				__NFUN_163__(iTotal);
			}
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0x6B;
		}		
	}
	else
	{
		// End:0x165
		foreach m_mgr.__NFUN_313__(Class'R6Engine.R6Hostage', aHostage)
		{
			// End:0x164
			if(__NFUN_129__(aHostage.m_bCivilian))
			{
				// End:0x15D
				if(aHostage.IsAlive())
				{
					__NFUN_165__(iTotalAlive);
					// End:0x15D
					if(aHostage.m_bExtracted)
					{
						__NFUN_184__(fRescuedNum, float(1));
					}
				}
				__NFUN_163__(iTotal);
			}			
		}		
	}
	// End:0x19A
	if(m_bRescueAllRemainingHostage)
	{
		// End:0x197
		if(__NFUN_180__(fRescuedNum, float(iTotalAlive)))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
		}		
	}
	else
	{
		// End:0x1D2
		if(__NFUN_179__(__NFUN_171__(__NFUN_172__(fRescuedNum, float(iTotal)), 100.0000000), float(m_iRescuePercentage)))
		{
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
		}
	}
	// End:0x238
	if(m_bShowLog)
	{
		logX(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("EnteredExtZone. completed=", string(m_bCompleted)), " "), string(__NFUN_171__(__NFUN_172__(fRescuedNum, float(iTotal)), 100.0000000))), "/"), string(m_iRescuePercentage)), "%"));
	}
	return;
}

function string GetDescriptionBasedOnNbOfHostages(LevelInfo Level)
{
	local R6Hostage aHostage;
	local int iTotal;

	// End:0x49
	foreach Level.__NFUN_313__(Class'R6Engine.R6Hostage', aHostage)
	{
		// End:0x48
		if(__NFUN_130__(aHostage.IsAlive(), __NFUN_129__(aHostage.m_bCivilian)))
		{
			__NFUN_163__(iTotal);
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
