//=============================================================================
// R6StoryModeGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6StoryModeGame.uc : Single player and Coop game info.
//						 See mission objectives and morality design docs.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//	  2002/02/19 * Created by S�bastien Lussier
//=============================================================================
class R6StoryModeGame extends R6GameInfo
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

//------------------------------------------------------------------
// InitObjectives
//	 Story Mode Objective
//------------------------------------------------------------------
function InitObjectives()
{
	InitObjectivesOfStoryMode();
	super.InitObjectives();
	return;
}

///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6GameReplicationInfo gameRepInfo;
	local R6MissionObjectiveBase obj;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x97
	if((int(m_missionMgr.m_eMissionObjectiveStatus) == int(1)))
	{
		BroadcastMissionObjMsg("", "", "", m_Player.Level.m_sndMissionComplete);
		BroadcastMissionObjMsg("", "", "MissionSuccesfulObjectivesCompleted", Level.m_sndPlayMissionExtro);		
	}
	else
	{
		obj = m_missionMgr.GetMObjFailed();
		BroadcastMissionObjMsg("", "", "MissionFailed");
		// End:0x10A
		if((obj != none))
		{
			BroadcastMissionObjMsg(Level.GetMissionObjLocFile(obj), "", obj.GetDescriptionFailure(), obj.GetSoundFailure());
		}
	}
	super.EndGame(Winner, Reason);
	// End:0x129
	if(m_bUsingPlayerCampaign)
	{
		UpdatePlayerCampaign();
	}
	return;
}

//------------------------------------------------------------------
// UpdatePlayerCampaign()
//	
//------------------------------------------------------------------
function UpdatePlayerCampaign()
{
	local R6PlayerCampaign MyCampaign;
	local R6MissionRoster oDetailOfTheOperative;
	local R6Operative oOperative, oOperativeTmp;
	local array<int> iOperativeInMission;
	local bool bAlreadyUpdate;
	local int i, j;
	local R6Rainbow aR6Rainbow;
	local R6RainbowTeam aR6Team;
	local R6Console R6Console;

	R6Console = R6Console(m_Player.Player.Console);
	MyCampaign = R6Console.m_PlayerCampaign;
	oDetailOfTheOperative = MyCampaign.m_OperativesMissionDetails;
	// End:0x85
	if(bShowLog)
	{
		Log("===== Update operative skills in mission =====");
	}
	i = 0;
	J0x8C:

	// End:0x5F0 [Loop If]
	if((i < 3))
	{
		aR6Team = R6RainbowTeam(GetRainbowTeam(i));
		// End:0x5E6
		if((aR6Team != none))
		{
			// End:0xD6
			if(bShowLog)
			{
				Log(("R6Team " $ string(aR6Team)));
			}
			j = 0;
			J0xDD:

			// End:0x5E6 [Loop If]
			if((j < 4))
			{
				aR6Rainbow = aR6Team.m_Team[j];
				// End:0x123
				if(bShowLog)
				{
					Log(("R6Rainbow " $ string(aR6Rainbow)));
				}
				// End:0x131
				if((aR6Rainbow == none))
				{
					// [Explicit Break]
					goto J0x5E6;
				}
				aR6Rainbow.UpdateRainbowSkills();
				// End:0x178
				if(bShowLog)
				{
					Log(("aR6Rainbow.m_iOperativeID" @ string(aR6Rainbow.m_iOperativeID)));
				}
				iOperativeInMission[iOperativeInMission.Length] = aR6Rainbow.m_iOperativeID;
				oOperative = oDetailOfTheOperative.m_MissionOperatives[aR6Rainbow.m_iOperativeID];
				oOperative.m_fAssault = (aR6Rainbow.m_fSkillAssault * float(100));
				oOperative.m_fDemolitions = (aR6Rainbow.m_fSkillDemolitions * float(100));
				oOperative.m_fElectronics = (aR6Rainbow.m_fSkillElectronics * float(100));
				oOperative.m_fSniper = (aR6Rainbow.m_fSkillSniper * float(100));
				oOperative.m_fStealth = (aR6Rainbow.m_fSkillStealth * float(100));
				oOperative.m_fSelfControl = (aR6Rainbow.m_fSkillSelfControl * float(100));
				oOperative.m_fLeadership = (aR6Rainbow.m_fSkillLeadership * float(100));
				oOperative.m_fObservation = (aR6Rainbow.m_fSkillObservation * float(100));
				oOperative.m_iHealth = int(aR6Rainbow.m_eHealth);
				(oOperative.m_iNbMissionPlayed++);
				(oOperative.m_iTerrokilled += aR6Rainbow.m_iKills);
				(oOperative.m_iRoundsfired += aR6Rainbow.m_iBulletsFired);
				(oOperative.m_iRoundsOntarget += aR6Rainbow.m_iBulletsHit);
				// End:0x36F
				if(bShowLog)
				{
					oOperative.DisplayStats();
				}
				// End:0x5DC
				if((oOperative.m_iHealth > 1))
				{
					switch(aR6Rainbow.m_szSpecialityID)
					{
						// End:0x3D4
						case "ID_ASSAULT":
							oOperative = new (none) Class'R6Game.R6RookieAssault';
							oOperative.m_szOperativeClass = "R6RookieAssault";
							// End:0x4E5
							break;
						// End:0x413
						case "ID_SNIPER":
							oOperative = new (none) Class'R6Game.R6RookieSniper';
							oOperative.m_szOperativeClass = "R6RookieSniper";
							// End:0x4E5
							break;
						// End:0x45C
						case "ID_DEMOLITIONS":
							oOperative = new (none) Class'R6Game.R6RookieDemolitions';
							oOperative.m_szOperativeClass = "R6RookieDemolitions";
							// End:0x4E5
							break;
						// End:0x4A5
						case "ID_ELECTRONICS":
							oOperative = new (none) Class'R6Game.R6RookieElectronics';
							oOperative.m_szOperativeClass = "R6RookieElectronics";
							// End:0x4E5
							break;
						// End:0x4E2
						case "ID_RECON":
							oOperative = new (none) Class'R6Game.R6RookieRecon';
							oOperative.m_szOperativeClass = "R6RookieRecon";
							// End:0x4E5
							break;
						// End:0xFFFF
						default:
							break;
					}
					// End:0x51F
					if(bShowLog)
					{
						Log(("aR6Rainbow.m_szSpecialityID: " $ aR6Rainbow.m_szSpecialityID));
					}
					// End:0x55B
					if(bShowLog)
					{
						Log(("oOperative.m_szOperativeClass: " $ oOperative.m_szOperativeClass));
					}
					oOperative.m_iUniqueID = oDetailOfTheOperative.m_MissionOperatives.Length;
					oOperative.m_iRookieID = GetNextRookieIndex(oOperative.m_szOperativeClass);
					iOperativeInMission[iOperativeInMission.Length] = oDetailOfTheOperative.m_MissionOperatives.Length;
					oDetailOfTheOperative.m_MissionOperatives[oDetailOfTheOperative.m_MissionOperatives.Length] = oOperative;
				}
				(j++);
				// [Loop Continue]
				goto J0xDD;
			}
		}
		J0x5E6:

		(i++);
		// [Loop Continue]
		goto J0x8C;
	}
	// End:0x62C
	if(bShowLog)
	{
		Log("===== Update operative skills in training =====");
	}
	i = 0;
	J0x633:

	// End:0x6FD [Loop If]
	if((i < MyCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length))
	{
		bAlreadyUpdate = false;
		j = 0;
		J0x664:

		// End:0x69E [Loop If]
		if((j < iOperativeInMission.Length))
		{
			// End:0x694
			if((i == iOperativeInMission[j]))
			{
				bAlreadyUpdate = true;
				// [Explicit Break]
				goto J0x69E;
			}
			(j++);
			// [Loop Continue]
			goto J0x664;
		}
		J0x69E:

		// End:0x6F3
		if((!bAlreadyUpdate))
		{
			oOperative = MyCampaign.m_OperativesMissionDetails.m_MissionOperatives[i];
			oOperative.UpdateSkills();
			// End:0x6F3
			if(bShowLog)
			{
				oOperative.DisplayStats();
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x633;
	}
	// End:0x779
	if((int(m_missionMgr.m_eMissionObjectiveStatus) == int(1)))
	{
		// End:0x768
		if((MyCampaign.m_iNoMission < (R6Console.m_CurrentCampaign.m_missions.Length - 1)))
		{
			(MyCampaign.m_iNoMission++);
			MyCampaign.m_bCampaignCompleted = 0;			
		}
		else
		{
			MyCampaign.m_bCampaignCompleted = 1;
		}
	}
	return;
}

function int GetNextRookieIndex(string _szOperativeClass)
{
	local R6PlayerCampaign MyCampaign;
	local R6MissionRoster oDetailOfTheOperative;
	local int i, iNbOfOperatives, ITemp, iRookieIndex;

	MyCampaign = R6Console(m_Player.Player.Console).m_PlayerCampaign;
	oDetailOfTheOperative = MyCampaign.m_OperativesMissionDetails;
	iNbOfOperatives = oDetailOfTheOperative.m_MissionOperatives.Length;
	iRookieIndex = 0;
	i = 0;
	J0x62:

	// End:0xF3 [Loop If]
	if((i < iNbOfOperatives))
	{
		// End:0xE9
		if((oDetailOfTheOperative.m_MissionOperatives[i].m_szOperativeClass == _szOperativeClass))
		{
			// End:0xE9
			if((oDetailOfTheOperative.m_MissionOperatives[i].m_iRookieID != -1))
			{
				iRookieIndex = Max(iRookieIndex, oDetailOfTheOperative.m_MissionOperatives[i].m_iRookieID);
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x62;
	}
	(iRookieIndex++);
	return iRookieIndex;
	return;
}

function string GetIntelVideoName(R6MissionDescription Desc)
{
	return Desc.m_MapName;
	return;
}

defaultproperties
{
	m_bUsingPlayerCampaign=true
	m_bUsingCampaignBriefing=true
	m_szDefaultActionPlan="_MISSION_ACTION"
	m_bUseClarkVoice=true
	m_bPlayIntroVideo=true
	m_bPlayOutroVideo=true
	m_szGameTypeFlag="RGM_StoryMode"
}
