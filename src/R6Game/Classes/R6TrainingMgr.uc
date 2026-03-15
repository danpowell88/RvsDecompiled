//=============================================================================
// R6TrainingMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TrainingMgr.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/19 * Created by Guillaume Borgia
//=============================================================================
class R6TrainingMgr extends R6PracticeModeGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const C_NbWeapons = 12;

enum ETrainingWeapons
{
	TW_SMG,                         // 0
	TW_Pistol,                      // 1
	TW_Sniper,                      // 2
	TW_HBSensor,                    // 3
	TW_Assault,                     // 4
	TW_AssaultSilenced,             // 5
	TW_LMG,                         // 6
	TW_Shotgun,                     // 7
	TW_Grenades,                    // 8
	TW_BreachCharge,                // 9
	TW_RemoteCharge,                // 10
	TW_Claymore,                    // 11
	TW_MAX                          // 12
};

var R6TrainingMgr.ETrainingWeapons m_eCurrentWeapon;
// NEW IN 1.60
var int m_WeaponsSlot[12];
var bool m_bInitialized;
// NEW IN 1.60
var R6EngineWeapon m_Weapons[12];
// NEW IN 1.60
var string m_WeaponsName[12];

function bool IsBasicMap()
{
	local string szMapName;

	szMapName = Class'Engine.Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_MapName;
	szMapName = Caps(szMapName);
	// End:0x69
	if((szMapName == "TRAINING_BASICS"))
	{
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function float GetEndGamePauseTime()
{
	// End:0x0F
	if(IsBasicMap())
	{
		return 20.0000000;
	}
	return super(R6AbstractGameInfo).GetEndGamePauseTime();
	return;
}

//============================================================================
// BOOL CanChangeText - 
//============================================================================
function bool CanChangeText(int iBoxNumber)
{
	return true;
	return;
}

//============================================================================
// Object GetTrainingMgr - 
//============================================================================
function R6TrainingMgr GetTrainingMgr(R6Pawn P)
{
	return self;
	return;
}

//============================================================================
// DeployCharacters - 
//============================================================================
function DeployCharacters(PlayerController ControlledByPlayer)
{
	local R6RainbowAI aRainbowAI;
	local int i;
	local R6PlayerController aPC;
	local R6Pawn pPawn;
	local string szMapName;
	local R6StartGameInfo StartGameInfo;

	super(R6GameInfo).DeployCharacters(ControlledByPlayer);
	StartGameInfo = Class'Engine.Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo;
	szMapName = StartGameInfo.m_MapName;
	szMapName = Caps(szMapName);
	// End:0xC1
	if((!(((szMapName == "TRAINING_BASICS") || (szMapName == "TRAINING_SHOOTING")) || (szMapName == "TRAINING_EXPLOSIVES"))))
	{
		return;
	}
	m_Player.bGodMode = true;
	pPawn = R6Pawn(m_Player.Pawn);
	aPC = R6PlayerController(m_Player);
	i = 0;
	J0x102:

	// End:0x147 [Loop If]
	if((i < 12))
	{
		R6PlayerController(m_Player).SetWeaponSound(m_Player.m_PawnRepInfo, m_WeaponsName[i], 0);
		(i++);
		// [Loop Continue]
		goto J0x102;
	}
	R6PlayerController(m_Player).ClientFinalizeLoading(pPawn.Region.Zone);
	LoadWeapons();
	return;
}

//============================================================================
// LoadWeapons - 
//============================================================================
function LoadWeapons()
{
	local int i;
	local R6Pawn pPawn;

	pPawn = R6Pawn(m_Player.Pawn);
	i = 0;
	J0x20:

	// End:0x201 [Loop If]
	if((i < 12))
	{
		// End:0x7A
		if((i == 0))
		{
			pPawn.ServerGivesWeaponToClient(m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6MiniScopeGadget");			
		}
		else
		{
			// End:0xCC
			if((i == 2))
			{
				pPawn.ServerGivesWeaponToClient(m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6ThermalScopeGadget");				
			}
			else
			{
				// End:0x11B
				if((i == 4))
				{
					pPawn.ServerGivesWeaponToClient(m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6MiniScopeGadget");					
				}
				else
				{
					// End:0x169
					if((i == 5))
					{
						pPawn.ServerGivesWeaponToClient(m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6SilencerGadget");						
					}
					else
					{
						pPawn.ServerGivesWeaponToClient(m_WeaponsName[i], 1, "", "");
					}
				}
			}
		}
		m_Weapons[i] = pPawn.m_WeaponsCarried[0];
		pPawn.m_WeaponsCarried[0] = none;
		ShowWeaponAndAttachment(m_Weapons[i], false);
		m_Weapons[i].WeaponInitialization(pPawn);
		m_Weapons[i].LoadFirstPersonWeapon();
		(i++);
		// [Loop Continue]
		goto J0x20;
	}
	return;
}

//============================================================================
// ResetGunAmmo - 
//============================================================================
function ResetGunAmmo()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x71 [Loop If]
	if((i < 4))
	{
		// End:0x67
		if((R6Pawn(m_Player.Pawn).m_WeaponsCarried[i] != none))
		{
			R6Pawn(m_Player.Pawn).m_WeaponsCarried[i].FillClips();
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//============================================================================
// ShowWeaponAndAttachment - 
//============================================================================
function ShowWeaponAndAttachment(R6EngineWeapon AWeapon, bool bShow)
{
	local R6AbstractWeapon pWeapon;

	pWeapon = R6AbstractWeapon(AWeapon);
	// End:0x1D
	if((pWeapon == none))
	{
		return;
	}
	pWeapon.bHidden = (!bShow);
	// End:0x6A
	if((pWeapon.m_SelectedWeaponGadget != none))
	{
		pWeapon.m_SelectedWeaponGadget.bHidden = (!bShow);
	}
	// End:0x9F
	if((pWeapon.m_MuzzleGadget != none))
	{
		pWeapon.m_MuzzleGadget.bHidden = (!bShow);
	}
	// End:0xD4
	if((pWeapon.m_ScopeGadget != none))
	{
		pWeapon.m_ScopeGadget.bHidden = (!bShow);
	}
	// End:0x109
	if((pWeapon.m_BipodGadget != none))
	{
		pWeapon.m_BipodGadget.bHidden = (!bShow);
	}
	// End:0x13E
	if((pWeapon.m_MagazineGadget != none))
	{
		pWeapon.m_MagazineGadget.bHidden = (!bShow);
	}
	return;
}

//============================================================================
// SwitchToWeapon - 
//============================================================================
function SwitchToWeapon(R6TrainingMgr.ETrainingWeapons eWT, bool bSwitch)
{
	local R6Pawn pPawn;
	local R6DemolitionsGadget pGadget;
	local R6EngineWeapon wpn;

	pPawn = R6Pawn(m_Player.Pawn);
	// End:0x53
	if(((R6PlayerController(m_Player).m_TeamManager.m_iRainbowTeamName != 0) || (pPawn.m_iPermanentID != 0)))
	{
		return;
	}
	R6PlayerController(m_Player).DoZoom(true);
	// End:0x111
	if((int(eWT) >= int(8)))
	{
		pGadget = R6DemolitionsGadget(m_Weapons[int(eWT)]);
		// End:0xC2
		if(((pGadget != none) && (!pGadget.IsInState('ChargeArmed'))))
		{
			pGadget.UpdateHands();
		}
		// End:0xF7
		if((!m_Weapons[int(eWT)].HasAmmo()))
		{
			pPawn.EngineWeapon.GotoState('RaiseWeapon');
		}
		m_Weapons[int(eWT)].FullAmmo();		
	}
	else
	{
		R6AbstractWeapon(m_Weapons[int(eWT)]).m_FPHands.ResetNeutralAnim();
		wpn = R6Pawn(m_Player.Pawn).m_WeaponsCarried[m_WeaponsSlot[int(eWT)]];
		// End:0x180
		if((wpn != none))
		{
			wpn.FillClips();
		}
	}
	// End:0x195
	if((int(m_eCurrentWeapon) == int(eWT)))
	{
		return;
	}
	ShowWeaponAndAttachment(pPawn.m_WeaponsCarried[m_WeaponsSlot[int(eWT)]], false);
	ShowWeaponAndAttachment(m_Weapons[int(eWT)], true);
	StopAllSoundsActor(pPawn.m_SoundRepInfo);
	pPawn.m_WeaponsCarried[m_WeaponsSlot[int(eWT)]] = m_Weapons[int(eWT)];
	R6PlayerController(m_Player).SetWeaponSound(m_Player.m_PawnRepInfo, m_WeaponsName[int(eWT)], byte(m_WeaponsSlot[int(eWT)]));
	// End:0x280
	if((pPawn.m_SoundRepInfo != none))
	{
		pPawn.m_SoundRepInfo.m_CurrentWeapon = byte(m_WeaponsSlot[int(eWT)]);
	}
	m_eCurrentWeapon = eWT;
	// End:0x335
	if(bSwitch)
	{
		// End:0x2DB
		if((pPawn.EngineWeapon != none))
		{
			pPawn.EngineWeapon.bHidden = true;
			pPawn.EngineWeapon.GotoState('PutWeaponDown');
		}
		pPawn.ServerChangedWeapon(pPawn.EngineWeapon, m_Weapons[int(eWT)]);
		// End:0x332
		if((pPawn.EngineWeapon != none))
		{
			pPawn.EngineWeapon.GotoState('RaiseWeapon');
		}		
	}
	else
	{
		m_Weapons[int(eWT)].bHidden = true;
	}
	return;
}

function LoadPlanningInTraining()
{
	local R6FileManagerPlanning pFileManager;
	local R6StartGameInfo StartGameInfo;
	local string szLoadErrorMsgMapName, szLoadErrorMsgGameType, szMapName, szGameTypeDirName, szEnglishGTDirectory;

	local R6MissionDescription missionDescription;
	local int i, j;

	StartGameInfo = Class'Engine.Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo;
	pFileManager = new (none) Class'R6Game.R6FileManagerPlanning';
	missionDescription = R6MissionDescription(StartGameInfo.m_CurrentMission);
	szMapName = Localize(missionDescription.m_MapName, "ID_MENUNAME", missionDescription.LocalizationFile, true);
	// End:0xB4
	if((szMapName == ""))
	{
		szMapName = StartGameInfo.m_MapName;
	}
	Level.GetGameTypeSaveDirectories(szGameTypeDirName, szEnglishGTDirectory);
	// End:0x1B5
	if(pFileManager.LoadPlanning(missionDescription.m_MapName, szMapName, szEnglishGTDirectory, szGameTypeDirName, ((missionDescription.m_ShortName $ "") $ m_szDefaultActionPlan), StartGameInfo, szLoadErrorMsgMapName, szLoadErrorMsgGameType))
	{
		Log(((((("LoadPlanningInTraining failed  map=" $ StartGameInfo.m_MapName) $ " filename=") $ missionDescription.m_ShortName) $ "") $ m_szDefaultActionPlan));
		Log(((("Planning Was Created for : " $ szLoadErrorMsgMapName) $ " : ") $ szLoadErrorMsgGameType));
	}
	i = 0;
	J0x1BC:

	// End:0x67D [Loop If]
	if((i < 3))
	{
		R6PlanningInfo(StartGameInfo.m_TeamInfo[i].m_pPlanning).InitPlanning(i, none);
		// End:0x25C
		if((R6PlanningInfo(StartGameInfo.m_TeamInfo[i].m_pPlanning).GetNbActionPoint() > 0))
		{
			R6PlanningInfo(StartGameInfo.m_TeamInfo[i].m_pPlanning).m_iCurrentNode = 0;			
		}
		else
		{
			R6PlanningInfo(StartGameInfo.m_TeamInfo[i].m_pPlanning).m_iCurrentNode = -1;
		}
		j = 0;
		J0x294:

		// End:0x673 [Loop If]
		if((j < StartGameInfo.m_TeamInfo[i].m_iNumberOfMembers))
		{
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_CharacterName = Localize("Training", "ROOKIE", "R6Menu", true);
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceTexture = Class'R6Game.R6RookieAssault'.default.m_TMenuFaceSmall;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.X = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallX);
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.Y = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallY);
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.Z = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallW);
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.W = float(Class'R6Game.R6RookieAssault'.default.m_RMenuFaceSmallH);
			// End:0x4A0
			if(((i == 2) && (j == 0)))
			{
				StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_szSpecialityID = "ID_SNIPER";				
			}
			else
			{
				StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_szSpecialityID = "ID_ASSAULT";
			}
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillAssault = 0.8500000;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillDemolitions = 0.8500000;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillElectronics = 0.8500000;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillSniper = 0.8500000;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillStealth = 0.8500000;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillSelfControl = 0.8500000;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillLeadership = 0.8500000;
			StartGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillObservation = 0.8500000;
			(j++);
			// [Loop Continue]
			goto J0x294;
		}
		(i++);
		// [Loop Continue]
		goto J0x1BC;
	}
	return;
}

//============================================================================
// LaunchAction - 
//============================================================================
function LaunchAction(int iBoxNb, int iSoundIndex)
{
	local R6GameReplicationInfo aGRI;

	// End:0x28
	if(((m_Player == none) || (R6Pawn(m_Player.Pawn) == none)))
	{
		return;
	}
	aGRI = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x164
	if((iSoundIndex == 0))
	{
		switch(iBoxNb)
		{
			// End:0x51
			case 1:
				// End:0x164
				break;
			// End:0x6B
			case 8:
				SwitchToWeapon(1, false);
				SwitchToWeapon(0, true);
				// End:0x164
				break;
			// End:0x7C
			case 9:
				SwitchToWeapon(0, true);
				// End:0x164
				break;
			// End:0x8D
			case 10:
				SwitchToWeapon(1, true);
				// End:0x164
				break;
			// End:0x9E
			case 11:
				SwitchToWeapon(0, true);
				// End:0x164
				break;
			// End:0xAF
			case 12:
				SwitchToWeapon(4, true);
				// End:0x164
				break;
			// End:0xC0
			case 13:
				SwitchToWeapon(7, true);
				// End:0x164
				break;
			// End:0xD1
			case 14:
				SwitchToWeapon(2, true);
				// End:0x164
				break;
			// End:0xE2
			case 15:
				SwitchToWeapon(6, true);
				// End:0x164
				break;
			// End:0xFC
			case 16:
				SwitchToWeapon(11, false);
				SwitchToWeapon(8, true);
				// End:0x164
				break;
			// End:0x10D
			case 17:
				SwitchToWeapon(8, true);
				// End:0x164
				break;
			// End:0x11E
			case 18:
				SwitchToWeapon(9, true);
				// End:0x164
				break;
			// End:0x12F
			case 19:
				SwitchToWeapon(11, true);
				// End:0x164
				break;
			// End:0x140
			case 20:
				SwitchToWeapon(10, true);
				// End:0x164
				break;
			// End:0x145
			case 21:
			// End:0x14A
			case 24:
			// End:0x14F
			case 25:
			// End:0x154
			case 26:
			// End:0x159
			case 27:
			// End:0x161
			case 28:
				// End:0x164
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

function string GetIntelVideoName(R6MissionDescription Desc)
{
	return "";
	return;
}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	Class'Engine.Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
	Class'Engine.Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
	Class'Engine.Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
	// End:0xD8
	if(IsBasicMap())
	{
		Level.m_sndMissionComplete = none;
	}
	super(R6StoryModeGame).EndGame(Winner, Reason);
	return;
}

defaultproperties
{
	m_eCurrentWeapon=12
	m_WeaponsSlot[1]=1
	m_WeaponsSlot[3]=2
	m_WeaponsSlot[8]=2
	m_WeaponsSlot[9]=2
	m_WeaponsSlot[10]=2
	m_WeaponsSlot[11]=3
	m_WeaponsName[0]="R63rdWeapons.NormalSubMP5A4"
	m_WeaponsName[1]="R63rdWeapons.NormalPistolUSP"
	m_WeaponsName[2]="R63rdWeapons.NormalSniperM82A1"
	m_WeaponsName[3]="R6Weapons.R6HBSGadget"
	m_WeaponsName[4]="R63rdWeapons.NormalAssaultM4"
	m_WeaponsName[5]="R63rdWeapons.SilencedAssaultM4"
	m_WeaponsName[6]="R63rdWeapons.NormalLMGM60E4"
	m_WeaponsName[7]="R63rdWeapons.BuckShotgunM1"
	m_WeaponsName[8]="R6Weapons.R6FragGrenadeGadget"
	m_WeaponsName[9]="R6Weapons.R6BreachingChargeGadget"
	m_WeaponsName[10]="R6Weapons.R6RemoteChargeGadget"
	m_WeaponsName[11]="R6Weapons.R6ClaymoreGadget"
	m_bUsingCampaignBriefing=false
	m_szDefaultActionPlan="_MISSION_DEFAULT"
	m_bUseClarkVoice=false
	m_bPlayIntroVideo=false
	m_bPlayOutroVideo=false
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_WeaponsC_NbWeapons
// REMOVED IN 1.60: var m_WeaponsNameC_NbWeapons
// REMOVED IN 1.60: var m_WeaponsSlotC_NbWeapons
