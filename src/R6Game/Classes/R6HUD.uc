//=============================================================================
// R6HUD - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//============================================================================//
// R6HUD.uc : Rainbow 6 HUD Base Class
// Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//    2001/09/11 * Modified by Lysanne Martin
//    2002/01/07 * Modified by Sebastien Lussier			
//============================================================================//
class R6HUD extends R6
    AbstractHUD
    native;

var Object.EMovementMode m_eLastMovementMode;
var R6RainbowTeam.eTeamState m_eLastTeamState;
var R6RainbowTeam.eTeamState m_eLastOtherTeamState[2];
var Object.EPlanAction m_eLastPlayerAPAction;
var Object.EGoCode m_eLastGoCode;
// Current Weapon Info
var int m_iBulletCount;
var int m_iMaxBulletCount;
var int m_iMagCount;
var int m_iCurrentMag;
// game stats
var(Debug) bool m_bDrawHUDinScript;
// Game Mode HUD Filters
var bool m_bGMIsSinglePlayer;
var bool m_bGMIsCoop;
var bool m_bGMIsTeamAdverserial;
// User HUD Filters  
var bool m_bShowCharacterInfo;
var bool m_bShowCurrentTeamInfo;
var bool m_bShowOtherTeamInfo;
var bool m_bShowWeaponInfo;
var bool m_bShowFPWeapon;
var bool m_bShowWaypointInfo;
var bool m_bShowActionIcon;
var bool m_bShowMPRadar;
var bool m_bShowTeamMatesNames;
var bool m_bUpdateHUDInTraining;  // For training, update only once
var bool m_bDisplayTimeBomb;
var bool m_bDisplayRemainingTime;
var bool m_bNoDeathCamera;
var bool m_bLastSniperHold;
var bool m_bShowPressGoCode;
var bool m_bPressGoCodeCanBlink;
var float m_fPosX;
var float m_fPosY;
var float m_fScaleX;
var float m_fScaleY;
var float m_fScale;
var R6GameReplicationInfo m_GameRepInfo;
var R6PlayerController m_PlayerOwner;
var Texture m_FlashbangFlash;
var Texture m_TexNightVision;
var Texture m_TexHeatVision;
var Material m_TexHeatVisionActor;
var Material m_TexHUDElements;
var Material m_pCurrentMaterial;
var Texture m_HeartBeatMaskMul;
var Texture m_HeartBeatMaskAdd;
var Texture m_Waypoint;
var Texture m_WaypointArrow;
var Texture m_InGamePlanningPawnIcon;
var Texture m_LoadingScreen;
var Texture m_TexNoise;
var Material m_TexProneTrail;
var FinalBlend m_pAlphaBlend;
var Actor m_pNextWayPoint;
//R6RADAR
var Material m_TexRadarTextures[10];
var R6RainbowTeam m_pLastRainbowTeam;
var array<R6IOBomb> m_aIOBombs;
var Color m_iCurrentTeamColor;
// Upper Left
var Color m_CharacterInfoBoxColor;
var Color m_CharacterInfoOutlineColor;
// Lower Left
var Color m_WeaponBoxColor;
var Color m_WeaponOutlineColor;
// Upper Right
var Color m_TeamBoxColor;
var Color m_TeamBoxOutlineColor;
// Lower Right;
var Color m_OtherTeamBoxColor;
var Color m_OtherTeamOutlineColor;
// Other
var Color m_WPIconBox;
var Color m_WPIconOutlineColor;
var R6HUDState m_HUDElements[16];
var string m_szMovementMode;
var string m_szTeamState;
var string m_szOtherTeamState[2];
var string m_aszOtherTeamName[2];
var string m_szLastPlayerAPAction;
var string m_szPressGoCode;
var string m_szTeam;

// Export UR6HUD::execDrawNativeHUD(FFrame&, void* const)
native(1605) final function DrawNativeHUD(Canvas C);

// Export UR6HUD::execHudStep(FFrame&, void* const)
native(1609) final function HudStep(int iBox, int iIDStep, optional bool bFlash);

//===========================================================================//
// PostBeginPlay()                                                           //
//===========================================================================//
function PostBeginPlay()
{
	super(HUD).PostBeginPlay();
	// End:0x13
	if((Owner == none))
	{
		return;
	}
	m_PlayerOwner = R6PlayerController(Owner);
	// End:0x44
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		m_bDisplayRemainingTime = false;
	}
	m_bUpdateHUDInTraining = true;
	SetTimer(0.2500000, true);
	StopFadeToBlack();
	return;
}

simulated function ResetOriginalData()
{
	super(Actor).ResetOriginalData();
	m_iCycleHUDLayer = default.m_iCycleHUDLayer;
	m_bToggleHelmet = default.m_bToggleHelmet;
	m_bNoDeathCamera = false;
	m_pLastRainbowTeam = none;
	// End:0x42
	if(m_bDisplayTimeBomb)
	{
		InitBombTimer(m_bDisplayTimeBomb);
	}
	StopFadeToBlack();
	return;
}

//------------------------------------------------------------------
// FUCKING WORKAROUND FOR THE GAME TYPE
//	
//------------------------------------------------------------------
function Timer()
{
	// End:0x86
	if(((((Level != none) && (m_PlayerOwner != none)) && (m_PlayerOwner.GameReplicationInfo != none)) && (int(m_PlayerOwner.GameReplicationInfo.m_bReceivedGameType) == 1)))
	{
		m_GameRepInfo = R6GameReplicationInfo(m_PlayerOwner.GameReplicationInfo);
		m_PlayerOwner.HidePlanningActors();
		UpdateHudFilter();
		SetTimer(0.0000000, false);
	}
	return;
}

simulated function InitBombTimer(bool bDisplayTimeBomb)
{
	local R6IOBomb ioBomb;

	m_bDisplayTimeBomb = bDisplayTimeBomb;
	m_aIOBombs.Remove(0, m_aIOBombs.Length);
	// End:0x47
	if(m_bDisplayTimeBomb)
	{
		// End:0x46
		foreach AllActors(Class'R6Engine.R6IOBomb', ioBomb)
		{
			m_aIOBombs[m_aIOBombs.Length] = ioBomb;			
		}		
	}
	return;
}

function UpdateHudFilter()
{
	local R6GameOptions GameOptions;
	local int iStepCount;
	local bool bDisplayFPWeapon;

	GameOptions = GetGameOptions();
	m_bGMIsSinglePlayer = true;
	bDisplayFPWeapon = GameOptions.HUDShowFPWeapon;
	// End:0x87
	if(Level.IsGameTypeMultiplayer(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep))
	{
		m_bGMIsSinglePlayer = false;
		bDisplayFPWeapon = (bDisplayFPWeapon || R6GameReplicationInfo(m_PlayerOwner.GameReplicationInfo).m_bFFPWeapon);
	}
	m_bGMIsCoop = Level.IsGameTypeCooperative(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep);
	m_bGMIsTeamAdverserial = Level.IsGameTypeTeamAdversarial(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep);
	// End:0x2A0
	if(((Level.Game == none) || ((Level.Game != none) && (R6GameInfo(Level.Game).GetTrainingMgr(R6Pawn(m_PlayerOwner.Pawn)) == none))))
	{
		m_bShowCharacterInfo = GameOptions.HUDShowCharacterInfo;
		m_bShowCurrentTeamInfo = ((m_bGMIsSinglePlayer || m_bGMIsCoop) && GameOptions.HUDShowCurrentTeamInfo);
		m_bShowOtherTeamInfo = (m_bGMIsSinglePlayer && GameOptions.HUDShowOtherTeamInfo);
		m_bShowWeaponInfo = GameOptions.HUDShowWeaponInfo;
		m_bShowWaypointInfo = (m_bGMIsSinglePlayer && GameOptions.HUDShowWaypointInfo);
		m_PlayerOwner.Set1stWeaponDisplay(bDisplayFPWeapon);
		m_bShowActionIcon = GameOptions.HUDShowActionIcon;
		// End:0x29D
		if(((m_GameRepInfo.m_iDiffLevel == 1) && (Level.Game != none)))
		{
			// End:0x29D
			if(((Level.Game.m_szGameTypeFlag == "RGM_PracticeMode") || (Level.Game.m_szGameTypeFlag == "RGM_StoryMode")))
			{
				m_bShowPressGoCode = true;
				m_bPressGoCodeCanBlink = false;
			}
		}		
	}
	else
	{
		m_bShowPressGoCode = true;
		m_bPressGoCodeCanBlink = true;
		// End:0x312
		if(m_bUpdateHUDInTraining)
		{
			m_bShowCharacterInfo = true;
			m_bShowCurrentTeamInfo = true;
			m_bShowOtherTeamInfo = true;
			m_bShowWeaponInfo = true;
			m_bShowWaypointInfo = true;
			m_PlayerOwner.Set1stWeaponDisplay(true);
			m_PlayerOwner.m_bHideReticule = false;
			m_bShowActionIcon = true;
			m_bUpdateHUDInTraining = true;
		}
	}
	// End:0x34D
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		m_PlayerOwner.m_wAutoAim = byte(GameOptions.AutoTargetSlider);		
	}
	else
	{
		m_PlayerOwner.m_wAutoAim = 0;
	}
	// End:0x38E
	if(Level.IsGameTypeDisplayBombTimer(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep))
	{
		InitBombTimer(true);
	}
	return;
}

//===========================================================================//
// Tick()                                                                    //
//===========================================================================//
simulated function Tick(float fDelta)
{
	super(Actor).Tick(fDelta);
	m_PlayerOwner = R6PlayerController(Owner);
	// End:0x3E
	if(((m_PlayerOwner == none) || (m_PlayerOwner.GameReplicationInfo == none)))
	{
		return;
	}
	m_GameRepInfo = R6GameReplicationInfo(m_PlayerOwner.GameReplicationInfo);
	return;
}

//===========================================================================//
// PostRender()                                                              //
//  Render HUD and call post render on the player controller                 //
//===========================================================================//
simulated event PostRender(Canvas C)
{
	// End:0x50
	if(m_bDrawHUDinScript)
	{
		C.UseVirtualSize(true);
		super.PostRender(C);
		// End:0x40
		if((m_PlayerOwner != none))
		{
			m_PlayerOwner.PostRender(C);
		}
		C.UseVirtualSize(false);		
	}
	else
	{
		super.PostRender(C);
		// End:0x7A
		if((m_PlayerOwner != none))
		{
			m_PlayerOwner.PostRender(C);
		}
	}
	return;
}

//===========================================================================//
// DrawHUD()                                                                 //
//===========================================================================//
function DrawHUD(Canvas C)
{
	local Vector viewLocation;
	local Rotator ViewRotation;
	local int flashBangCoefficient;
	local R6Pawn aPlayerPawn;

	// End:0x17
	if((Level.m_bInGamePlanningActive == true))
	{
		return;
	}
	// End:0x3B
	if((m_PlayerOwner != none))
	{
		aPlayerPawn = R6Pawn(m_PlayerOwner.Pawn);
	}
	// End:0xAA
	if(((m_PlayerOwner != none) && (m_PlayerOwner.m_TeamManager != none)))
	{
		// End:0xAA
		if((R6PlanningInfo(m_PlayerOwner.m_TeamManager.m_TeamPlanning) != none))
		{
			m_pNextWayPoint = R6PlanningInfo(m_PlayerOwner.m_TeamManager.m_TeamPlanning).GetNextActionPoint();
		}
	}
	DrawNativeHUD(C);
	// End:0x11F
	if((m_PlayerOwner != none))
	{
		// End:0xEE
		if((m_PlayerOwner.m_InteractionCA != none))
		{
			m_PlayerOwner.m_InteractionCA.m_color = m_iCurrentTeamColor;
		}
		// End:0x11F
		if((m_PlayerOwner.m_InteractionInventory != none))
		{
			m_PlayerOwner.m_InteractionInventory.m_color = m_iCurrentTeamColor;
		}
	}
	// End:0x133
	if(m_bDisplayTimeBomb)
	{
		DisplayBombTimer(C);
	}
	return;
}

simulated event PostFadeRender(Canvas Canvas)
{
	// End:0x14
	if(m_bDisplayRemainingTime)
	{
		DisplayRemainingTime(Canvas);
	}
	// End:0x28
	if(m_bNoDeathCamera)
	{
		DisplayNoDeathCamera(Canvas);
	}
	return;
}

function ActivateNoDeathCameraMsg(bool bToggleOn)
{
	m_bNoDeathCamera = bToggleOn;
	return;
}

function DisplayNoDeathCamera(Canvas C)
{
	local string szText;
	local float W, H, f;

	// End:0x1B
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		return;
	}
	// End:0x35
	if(((m_GameRepInfo == none) || (m_PlayerOwner == none)))
	{
		return;
	}
	// End:0x57
	if((int(m_GameRepInfo.m_eCurrectServerState) != m_GameRepInfo.3))
	{
		return;
	}
	// End:0x8C
	if(((m_GameRepInfo.m_MenuCommunication != none) && (!m_GameRepInfo.m_MenuCommunication.IsInGame())))
	{
		return;
	}
	C.UseVirtualSize(true, 640.0000000, 480.0000000);
	C.Style = 5;
	C.Font = m_FontRainbow6_17pt;
	C.SetDrawColor(byte(255), byte(255), byte(255));
	szText = Localize("Game", "NoDeathCamera", "R6GameInfo");
	C.TextSize(szText, W, H);
	f = ((640.0000000 - W) / float(2));
	// End:0x159
	if((f < float(0)))
	{
		f = 0.0000000;
	}
	C.SetClip(640.0000000, 480.0000000);
	C.SetOrigin(0.0000000, 0.0000000);
	C.SetPos(f, 220.0000000);
	C.DrawText(szText);
	C.UseVirtualSize(false);
	return;
}

//------------------------------------------------------------------
// DisplayRemainingTime
//	
//------------------------------------------------------------------
function DisplayRemainingTime(Canvas C)
{
	local float fBkpOrigX, fBkpOrigY, fPosX, fPosY, W, H,
		fDefaultNamePosX;

	local string szTime;

	// End:0x1A
	if(((m_GameRepInfo == none) || (m_PlayerOwner == none)))
	{
		return;
	}
	// End:0x66
	if((((!m_PlayerOwner.bOnlySpectator) || (int(m_GameRepInfo.m_eCurrectServerState) != m_GameRepInfo.3)) || m_GameRepInfo.m_bInPostBetweenRoundTime))
	{
		return;
	}
	// End:0x9B
	if(((m_GameRepInfo.m_MenuCommunication != none) && (!m_GameRepInfo.m_MenuCommunication.IsInGame())))
	{
		return;
	}
	fBkpOrigX = C.OrgX;
	fBkpOrigY = C.OrgY;
	C.OrgX = 0.0000000;
	C.OrgY = 0.0000000;
	C.UseVirtualSize(true, 640.0000000, 480.0000000);
	fDefaultNamePosX = 600.0000000;
	fPosY = 394.0000000;
	C.Style = 5;
	C.Font = m_FontRainbow6_14pt;
	C.SetDrawColor(byte(255), byte(255), byte(255));
	szTime = (Localize("MPInGame", "Round", "R6Menu") $ " ");
	C.TextSize(szTime, W, H);
	C.SetPos((fDefaultNamePosX - W), fPosY);
	C.DrawText(szTime);
	C.SetPos(fDefaultNamePosX, fPosY);
	C.DrawText(ConvertIntTimeToString(int(m_GameRepInfo.GetRoundTime()), true));
	C.UseVirtualSize(false);
	C.SetOrigin(fBkpOrigX, fBkpOrigY);
	return;
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function DisplayBombTimer(Canvas C)
{
	local int i, j;
	local float fPosX, fPosY, fPosYDelta, W, H, fDefaultNamePosX;

	local string szTime, szBomb;
	local R6IOBomb pBomb;

	C.UseVirtualSize(true, 640.0000000, 480.0000000);
	fDefaultNamePosX = 600.0000000;
	fPosYDelta = 16.0000000;
	fPosY = 380.0000000;
	C.Style = 5;
	C.Font = m_FontRainbow6_14pt;
	i = 0;
	J0x64:

	// End:0x13C [Loop If]
	if((i < (m_aIOBombs.Length - 1)))
	{
		// End:0x132
		if(m_aIOBombs[i].m_bIsActivated)
		{
			j = 0;
			J0x96:

			// End:0x132 [Loop If]
			if((j < m_aIOBombs.Length))
			{
				// End:0x128
				if((m_aIOBombs[j].m_bIsActivated && (m_aIOBombs[j].GetTimeLeft() < m_aIOBombs[i].GetTimeLeft())))
				{
					pBomb = m_aIOBombs[i];
					m_aIOBombs[i] = m_aIOBombs[j];
					m_aIOBombs[j] = pBomb;
				}
				(++j);
				// [Loop Continue]
				goto J0x96;
			}
		}
		(++i);
		// [Loop Continue]
		goto J0x64;
	}
	i = (m_aIOBombs.Length - 1);
	J0x14B:

	// End:0x2AE [Loop If]
	if((i >= 0))
	{
		// End:0x2A4
		if(m_aIOBombs[i].m_bIsActivated)
		{
			// End:0x1A7
			if((m_aIOBombs[i].GetTimeLeft() > float(20)))
			{
				C.SetDrawColor(byte(255), byte(255), byte(255));				
			}
			else
			{
				// End:0x1DE
				if((m_aIOBombs[i].GetTimeLeft() > float(10)))
				{
					C.SetDrawColor(byte(255), byte(255), 0);					
				}
				else
				{
					C.SetDrawColor(byte(255), 0, 0);
				}
			}
			szBomb = (m_aIOBombs[i].m_szIdentity $ " ");
			C.TextSize(szBomb, W, H);
			C.SetPos((fDefaultNamePosX - W), fPosY);
			C.DrawText(szBomb);
			C.SetPos(fDefaultNamePosX, fPosY);
			C.DrawText(ConvertIntTimeToString(int(m_aIOBombs[i].GetTimeLeft()), true));
			(fPosY -= fPosYDelta);
		}
		(--i);
		// [Loop Continue]
		goto J0x14B;
	}
	C.UseVirtualSize(false);
	return;
}

//------------------------------------------------------------------
// StartFadeToBlack
//	
//------------------------------------------------------------------
function StartFadeToBlack(int iSec, int iPercentageOfBlack)
{
	local Canvas C;
	local int iBlack;
	local float fAlpha;

	C = Class'Engine.Actor'.static.GetCanvas();
	// End:0x163
	if(C.m_bFading)
	{
		fAlpha = (C.m_fFadeCurrentTime / C.m_fFadeTotalTime);
		fAlpha = float(Clamp(int(fAlpha), 0, 1));
		C.m_FadeStartColor.R = byte(((float(C.m_FadeEndColor.R) * fAlpha) + (float(C.m_FadeStartColor.R) * (1.0000000 - fAlpha))));
		C.m_FadeStartColor.G = byte(((float(C.m_FadeEndColor.G) * fAlpha) + (float(C.m_FadeStartColor.G) * (1.0000000 - fAlpha))));
		C.m_FadeStartColor.B = byte(((float(C.m_FadeEndColor.B) * fAlpha) + (float(C.m_FadeStartColor.B) * (1.0000000 - fAlpha))));		
	}
	else
	{
		C.m_FadeStartColor = C.MakeColor(byte(255), byte(255), byte(255));
	}
	iBlack = ((255 * (100 - iPercentageOfBlack)) / 100);
	C.m_bFading = true;
	C.m_fFadeCurrentTime = 0.0000000;
	C.m_fFadeTotalTime = float(iSec);
	C.m_FadeEndColor = C.MakeColor(byte(iBlack), byte(iBlack), byte(iBlack));
	C.m_bFadeAutoStop = false;
	return;
}

//------------------------------------------------------------------
// StopFadeToBlack
//	
//------------------------------------------------------------------
function StopFadeToBlack()
{
	local Canvas C;

	C = Class'Engine.Actor'.static.GetCanvas();
	C.m_bFading = true;
	C.m_fFadeCurrentTime = 0.0000000;
	C.m_fFadeTotalTime = 0.0000000;
	C.m_FadeStartColor = C.MakeColor(0, 0, 0);
	C.m_FadeEndColor = C.MakeColor(byte(255), byte(255), byte(255));
	C.m_bFadeAutoStop = true;
	return;
}

//===========================================================================//
// Message()                                                                 //
//  Parse recieved msg - inherited                                           //
//===========================================================================//
simulated function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType)
{
	// End:0x51
	if(((MsgType == 'Console') && (("SAY" == Caps(Left(Msg, Len("Say")))) || ("TEAMSAY" == Caps(Left(Msg, Len("TeamSay")))))))
	{
		return;
	}
	super(HUD).Message(PRI, Msg, MsgType);
	return;
}

//===========================================================================//
// DisplayMessages()                                                         //
//  Inherited                                                                //
//===========================================================================//
simulated function DisplayMessages(Canvas C)
{
	C.SetDrawColor(m_iCurrentTeamColor.R, m_iCurrentTeamColor.G, m_iCurrentTeamColor.B, m_iCurrentTeamColor.A);
	C.Style = 5;
	C.Font = m_FontRainbow6_14pt;
	super(HUD).DisplayMessages(C);
	return;
}

//===========================================================================//
// SetDefaultFontSettings()                                                  //
//===========================================================================//
function SetDefaultFontSettings(Canvas C)
{
	C.SetDrawColor(m_iCurrentTeamColor.R, m_iCurrentTeamColor.G, m_iCurrentTeamColor.B, m_iCurrentTeamColor.A);
	C.Style = 5;
	C.Font = m_FontRainbow6_22pt;
	return;
}

defaultproperties
{
	m_bDisplayRemainingTime=true
	m_FlashbangFlash=Texture'Inventory_t.Flash.Flash'
	m_TexNightVision=Texture'Inventory_t.NightVision.NightVisionTex'
	m_TexHeatVision=Texture'Inventory_t.HeatVision.HeatVision'
	m_TexHeatVisionActor=FinalBlend'Inventory_t.HeatVision.HeatVisionActorMat'
	m_TexHUDElements=Texture'R6HUD.HUDElements'
	m_HeartBeatMaskMul=Texture'Inventory_t.HeartBeat.HeartBeatMaskMul'
	m_HeartBeatMaskAdd=Texture'Inventory_t.HeartBeat.HeartBeatMaskAdd'
	m_Waypoint=Texture'R6HUD.WayPoint'
	m_WaypointArrow=Texture'R6HUD.WayPointArrow'
	m_InGamePlanningPawnIcon=Texture'R6Planning.InGamePlanning.PawnIcon'
	m_TexNoise=Texture'Inventory_t.Misc.Noise'
	m_TexRadarTextures[0]=Texture'Inventory_t.Radar.RadarBack'
	m_TexRadarTextures[1]=Texture'Inventory_t.Radar.RadarTop'
	m_TexRadarTextures[2]=Texture'Inventory_t.Radar.RadarOutline'
	m_TexRadarTextures[3]=Texture'Inventory_t.Radar.RadarDead'
	m_TexRadarTextures[4]=Texture'Inventory_t.Radar.RadarSameFloor'
	m_TexRadarTextures[5]=Texture'Inventory_t.Radar.RadarHigherFloor'
	m_TexRadarTextures[6]=Texture'Inventory_t.Radar.RadarLowerFloor'
	m_TexRadarTextures[7]=Texture'Inventory_t.Radar.RadarPilotSameFloor'
	m_TexRadarTextures[8]=Texture'Inventory_t.Radar.RadarPilotHigherFloor'
	m_TexRadarTextures[9]=Texture'Inventory_t.Radar.RadarPilotLowerFloor'
	m_bToggleHelmet=true
	m_ConsoleBackground=Texture'Inventory_t.Console.ConsoleBack'
}
