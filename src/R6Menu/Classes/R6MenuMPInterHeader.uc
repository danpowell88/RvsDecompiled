//=============================================================================
// R6MenuMPInterHeader - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPInterHeader.uc : Intermission widget (when you press start during MP game or 
//  the size of the window is 640 * 480. The part in the top of multi menu in-game
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPInterHeader extends UWindowWindow;

const C_iSERVER_NAME = 0;
const C_iSERVER_IP = 1;
const C_iMAP_NAME = 2;
const C_iGAME_TYPE = 3;
const C_iROUND = 4;
const C_iTIME_PER_ROUND = 5;
const C_iTOT_GREEN_TEAM_VICTORY = 6;
const C_iTOT_RED_TEAM_VICTORY = 7;
const C_iMISSION_STATUS = 8;
const C_fXBORDER_OFFSET = 2;
const C_fXTEXT_HEADER_OFFSET = 4;
const C_fYPOS_OF_TEAMSCORE = 48;

var int m_iIndex[9];  // array of text label (6 is for nb of server info + 2 for team case + 1 mission status)
var bool m_bDisplayTotVictory;  // display the win games for each team
var bool m_bDisplayCoopStatus;  // display the coop mission status
var bool m_bDisplayCoopBox;
var R6WindowTextLabelExt m_pTextHeader;  // all the names for the header
var string m_szGameResult[5];

function Created()
{
	m_szGameResult[0] = Localize("MPInGame", "AlphaTeamScore", "R6Menu");
	m_szGameResult[1] = Localize("MPInGame", "BravoTeamScore", "R6Menu");
	m_szGameResult[2] = Localize("DebriefingMenu", "SUCCESS", "R6Menu");
	m_szGameResult[3] = Localize("DebriefingMenu", "FAILED", "R6Menu");
	m_szGameResult[4] = Localize("MPInGame", "MissionInProgress", "R6Menu");
	m_bDisplayCoopBox = false;
	InitTextHeader();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float fX;

	fX = (2.0000000 + float(4));
	// End:0xF5
	if(m_bDisplayTotVictory)
	{
		DrawTeamScore(C, Root.Colors.TeamColor[1], Root.Colors.TeamColorDark[1], fX, 48.0000000, ((WinWidth * 0.5000000) - (float(2) * fX)), 14.0000000);
		DrawTeamScore(C, Root.Colors.TeamColor[0], Root.Colors.TeamColorDark[0], ((WinWidth * 0.5000000) + fX), 48.0000000, ((WinWidth * 0.5000000) - (float(2) * fX)), 14.0000000);		
	}
	else
	{
		// End:0x158
		if(m_bDisplayCoopBox)
		{
			DrawTeamScore(C, m_pTextHeader.GetTextColor(m_iIndex[8]), m_pTextHeader.GetTextColor(m_iIndex[8]), fX, 48.0000000, (WinWidth - (float(2) * fX)), 14.0000000);
		}
	}
	return;
}

//===============================================================================
// DrawTeamScore: Display a box with a background (use for team score and mission progress)
//===============================================================================
function DrawTeamScore(Canvas C, Color _cTeamColor, Color _cBGColor, float _fX, float _fY, float _fW, float _fH)
{
	DrawSimpleBackGround(C, _fX, _fY, _fW, _fH, _cBGColor);
	C.SetDrawColor(_cTeamColor.R, _cTeamColor.G, _cTeamColor.B);
	DrawStretchedTextureSegment(C, _fX, _fY, _fW, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, _fX, ((_fY + _fH) - float(m_BorderTextureRegion.H)), _fW, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, _fX, (_fY + float(m_BorderTextureRegion.H)), float(m_BorderTextureRegion.W), (_fH - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, ((_fX + _fW) - float(m_BorderTextureRegion.W)), (_fY + float(m_BorderTextureRegion.H)), float(m_BorderTextureRegion.W), (_fH - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

//===============================================================================
// Init text header
//===============================================================================
function InitTextHeader()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
		fSizeOfCounter;

	local Font ButtonFont;

	m_pTextHeader = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, WinWidth, WinHeight, self));
	m_pTextHeader.bAlwaysBehind = true;
	m_pTextHeader.SetNoBorder();
	m_pTextHeader.m_Font = Root.Fonts[6];
	m_pTextHeader.m_vTextColor = Root.Colors.White;
	fXOffset = 4.0000000;
	fYOffset = 4.0000000;
	fWidth = (WinWidth * 0.5000000);
	fYStep = 14.0000000;
	m_pTextHeader.AddTextLabel(Localize("MPInGame", "ServerName", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	(fYOffset += fYStep);
	m_pTextHeader.AddTextLabel(Localize("MPInGame", "ServerIP", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	(fYOffset += fYStep);
	m_pTextHeader.AddTextLabel(Localize("MPInGame", "MapName", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = (fWidth + float(4));
	fYOffset = 4.0000000;
	m_pTextHeader.AddTextLabel(Localize("MPInGame", "GameType", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	(fYOffset += fYStep);
	m_pTextHeader.AddTextLabel(Localize("MPInGame", "Round", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	(fYOffset += fYStep);
	m_pTextHeader.AddTextLabel(Localize("MPInGame", "TimePerRound", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fWidth = (WinWidth * 0.2500000);
	fXOffset = (WinWidth * 0.2000000);
	fYOffset = 4.0000000;
	m_pTextHeader.m_vTextColor = Root.Colors.BlueLight;
	m_pTextHeader.m_bUpDownBG = true;
	m_iIndex[0] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 12.0000000);
	(fYOffset += fYStep);
	m_iIndex[1] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 12.0000000);
	(fYOffset += fYStep);
	m_iIndex[2] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 12.0000000);
	fXOffset = ((WinWidth * 0.5000000) + fXOffset);
	fYOffset = 4.0000000;
	m_iIndex[3] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 12.0000000);
	(fYOffset += fYStep);
	m_iIndex[4] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 12.0000000);
	(fYOffset += fYStep);
	m_iIndex[5] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 12.0000000);
	fXOffset = 4.0000000;
	fYOffset = (48.0000000 + float(1));
	fWidth = ((WinWidth * 0.5000000) - (float(2) * fXOffset));
	m_pTextHeader.m_bUpDownBG = false;
	m_pTextHeader.m_vTextColor = Root.Colors.TeamColorLight[1];
	m_iIndex[6] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 14.0000000);
	fXOffset = (fWidth + float(4));
	m_pTextHeader.m_vTextColor = Root.Colors.TeamColorLight[0];
	m_iIndex[7] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 14.0000000);
	fXOffset = (2.0000000 + float(4));
	fWidth = (WinWidth - (float(2) * fXOffset));
	m_pTextHeader.m_vTextColor = Root.Colors.White;
	m_iIndex[8] = m_pTextHeader.AddTextLabel("", fXOffset, fYOffset, fWidth, 2, false, 14.0000000);
	return;
}

//===============================================================================
// Refresh server header info
//===============================================================================
function RefreshInterHeaderInfo()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local string szIP, szGameType, szTemp;
	local float fCurrentTime;
	local R6GameReplicationInfo r6GameRep;
	local R6MenuMPInterWidget MpInter;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x5B9
	if((r6Root.m_R6GameMenuCom != none))
	{
		r6GameRep = R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo);
		// End:0x53
		if((r6GameRep == none))
		{
			return;
		}
		szIP = R6Console(Root.Console).szStoreIP;
		m_pTextHeader.ChangeTextLabel(r6GameRep.ServerName, m_iIndex[0]);
		m_pTextHeader.ChangeTextLabel(szIP, m_iIndex[1]);
		// End:0xED
		if((!Root.GetMapNameLocalisation(GetLevel().GetURLMap(), szTemp)))
		{
			szTemp = GetLevel().GetURLMap();
		}
		m_pTextHeader.ChangeTextLabel(szTemp, m_iIndex[2]);
		szGameType = GetLevel().GetGameNameLocalization(r6Root.m_R6GameMenuCom.GetGameType());
		m_pTextHeader.ChangeTextLabel(szGameType, m_iIndex[3]);
		RefreshRoundInfo();
		MpInter = R6MenuMPInterWidget(OwnerWindow);
		// End:0x19D
		if(r6Root.m_R6GameMenuCom.IsInBetweenRoundMenu())
		{
			fCurrentTime = float(r6GameRep.TimeLimit);			
		}
		else
		{
			fCurrentTime = r6GameRep.GetRoundTime();
		}
		m_pTextHeader.ChangeTextLabel(((Class'Engine.Actor'.static.ConvertIntTimeToString(int(fCurrentTime)) @ "/") @ Class'Engine.Actor'.static.ConvertIntTimeToString(r6GameRep.TimeLimit)), m_iIndex[5]);
		// End:0x277
		if(m_bDisplayTotVictory)
		{
			m_pTextHeader.ChangeTextLabel(((m_szGameResult[0] $ " ") $ string(r6GameRep.m_aTeamScore[0])), m_iIndex[6]);
			m_pTextHeader.ChangeTextLabel(((m_szGameResult[1] $ " ") $ string(r6GameRep.m_aTeamScore[1])), m_iIndex[7]);			
		}
		else
		{
			// End:0x4CB
			if(m_bDisplayCoopStatus)
			{
				// End:0x3F3
				if(MpInter.IsMissionInProgress())
				{
					// End:0x300
					if((!r6Root.m_R6GameMenuCom.IsInBetweenRoundMenu(true)))
					{
						m_pTextHeader.ChangeColorLabel(Root.Colors.White, m_iIndex[8]);
						m_pTextHeader.ChangeTextLabel(m_szGameResult[4], m_iIndex[8]);						
					}
					else
					{
						// End:0x333
						if((int(MpInter.GetLastMissionSuccess()) == 0))
						{
							m_pTextHeader.ChangeTextLabel("", m_iIndex[8]);							
						}
						else
						{
							// End:0x3A1
							if((int(R6MenuMPInterWidget(OwnerWindow).GetLastMissionSuccess()) == 1))
							{
								m_pTextHeader.ChangeColorLabel(Root.Colors.TeamColorLight[1], m_iIndex[8]);
								m_pTextHeader.ChangeTextLabel(m_szGameResult[2], m_iIndex[8]);								
							}
							else
							{
								m_pTextHeader.ChangeColorLabel(Root.Colors.TeamColorLight[0], m_iIndex[8]);
								m_pTextHeader.ChangeTextLabel(m_szGameResult[3], m_iIndex[8]);
							}
						}
					}					
				}
				else
				{
					// End:0x457
					if(MpInter.IsMissionSuccess())
					{
						m_pTextHeader.ChangeColorLabel(Root.Colors.TeamColorLight[1], m_iIndex[8]);
						m_pTextHeader.ChangeTextLabel(m_szGameResult[2], m_iIndex[8]);						
					}
					else
					{
						m_pTextHeader.ChangeColorLabel(Root.Colors.TeamColorLight[0], m_iIndex[8]);
						m_pTextHeader.ChangeTextLabel(m_szGameResult[3], m_iIndex[8]);
					}
				}
				m_bDisplayCoopBox = (m_pTextHeader.GetTextLabel(m_iIndex[8]) != "");				
			}
			else
			{
				ResetDisplayInfo();
			}
		}
		// End:0x5A5
		if(r6Root.m_R6GameMenuCom.IsInBetweenRoundMenu())
		{
			// End:0x538
			if(r6GameRep.m_bRepMenuCountDownTimePaused)
			{
				r6Root.UpdateTimeInBetRound(0, Localize("MPInGame", "PausedMessage", "R6Menu"));				
			}
			else
			{
				// End:0x582
				if(r6GameRep.m_bRepMenuCountDownTimeUnlimited)
				{
					r6Root.UpdateTimeInBetRound(0, Localize("MPInGame", "WaitMessage", "R6Menu"));					
				}
				else
				{
					r6Root.UpdateTimeInBetRound(int(r6GameRep.GetRoundTime()));
				}
			}			
		}
		else
		{
			r6Root.UpdateTimeInBetRound(-1);
		}
	}
	return;
}

function RefreshRoundInfo()
{
	local R6GameReplicationInfo r6GameRep;
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	r6GameRep = R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo);
	// End:0x3F
	if((r6GameRep == none))
	{
		return;
	}
	// End:0xA6
	if(GetLevel().IsGameTypeCooperative(r6Root.m_szCurrentGameType))
	{
		// End:0xA6
		if(r6GameRep.m_bRotateMap)
		{
			m_pTextHeader.ChangeTextLabel((string((r6GameRep.m_iCurrentRound + 1)) @ "/ --"), m_iIndex[4]);
			return;
		}
	}
	// End:0x12C
	if((int(r6Root.m_R6GameMenuCom.m_GameRepInfo.m_eCurrectServerState) == r6Root.m_R6GameMenuCom.m_GameRepInfo.4))
	{
		m_pTextHeader.ChangeTextLabel(Localize("MPInGame", "MatchCompleted", "R6Menu"), m_iIndex[4]);		
	}
	else
	{
		m_pTextHeader.ChangeTextLabel(((string((r6GameRep.m_iCurrentRound + 1)) @ "/") @ string(r6GameRep.m_iRoundsPerMatch)), m_iIndex[4]);
	}
	return;
}

//===============================================================================
// ResetDisplayInfo: 
//===============================================================================
function ResetDisplayInfo()
{
	m_pTextHeader.ChangeTextLabel("", m_iIndex[6]);
	m_pTextHeader.ChangeTextLabel("", m_iIndex[7]);
	m_pTextHeader.ChangeTextLabel("", m_iIndex[8]);
	return;
}

//===============================================================================
// Reset: reset all the gametype variables
//===============================================================================
function Reset()
{
	m_bDisplayTotVictory = false;
	m_bDisplayCoopStatus = false;
	m_bDisplayCoopBox = false;
	ResetDisplayInfo();
	return;
}

