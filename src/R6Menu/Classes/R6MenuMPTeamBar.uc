//=============================================================================
// R6MenuMPTeamBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPTeamBar.uc : The team bar with the name of each player and theirs stats
//  the size of the window is 640 * 480
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPTeamBar extends UWindowWindow;

const C_fTEAMBAR_ICON_HEIGHT = 15;
const C_fTEAMBAR_TOT_HEIGHT = 12;
const C_iMISSION_TITLE_H = 20;
const C_iREADY = 0;
const C_iTEAM_NAME = 1;
const C_iROUNDSWON = 2;
const C_iNUMBER_OF_KILLS = 3;
const C_iNUMBER_OF_MYDEAD = 4;
const C_iPERCENT_EFFICIENT = 5;
const C_iROUND_FIRED = 6;
const C_iTOT_ROUND_TAKEN = 7;
const C_iTOTAL_TEAM_STATUS = 8;
const C_iPLAYER_MAX = 16;

enum eMenuLayout
{
	eML_Ready,                      // 0
	eML_HealthStatus,               // 1
	eML_Name,                       // 2
	eML_RoundsWon,                  // 3
	eML_Kill,                       // 4
	eML_DeadCounter,                // 5
	eML_Efficiency,                 // 6
	eML_RoundFired,                 // 7
	eML_RoundHit,                   // 8
	eML_KillerName,                 // 9
	eML_PingTime                    // 10
};

enum eIconType
{
	IT_Ready,                       // 0
	IT_Health,                      // 1
	IT_RoundsWon,                   // 2
	IT_Kill,                        // 3
	IT_DeadCounter,                 // 4
	IT_Efficiency,                  // 5
	IT_RoundFired,                  // 6
	IT_RoundTaken,                  // 7
	IT_KillerName,                  // 8
	IT_Ping                         // 9
};

struct stCoord
{
	var float fXPos;
	var float fWidth;
};

var int m_iIndex[9];  // array of text label
var int m_iTotalKills;  // Team total Number of kills
var int m_iTotalNbOfDead;  // Team total Number of Dead
var int m_iTotalEfficiency;  // Team total Efficiency (hits/shot)
var int m_iTotalRoundsFired;  // Team total Rounds fired (Bullets shot by the player)
var int m_iTotalRoundsTaken;  // Team total Rounds taken (Rounds that hits the player)
var int m_iTotalRoomTake;
var bool m_bTeamMenuLayout;  // for team menu layout (team deathmatch, tema survivor, team etc!!!)
var bool m_bDisplayObj;  // display the objectives
var Texture m_TIcon;  // where are the icon tex
var R6WindowTextLabelExt m_pTextTeamBar;  // display the names of the team and nb of players
var R6WindowIGPlayerInfoListBox m_IGPlayerInfoListBox;  // List of players with scroll bar
// COOP
var R6WindowTextLabel m_pTitleCoop;
var R6MenuMPInGameObj m_pMissionObj;
var Color m_vTeamColor;  // the color of the team
var stCoord m_stMenuCoord[11];  // the coordinates of all menu
var string m_szTeamName;

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	// End:0x150
	if((!m_bDisplayObj))
	{
		// End:0x83
		if(m_vTeamColor == Root.Colors.TeamColorLight[0])
		{
			DrawSimpleBackGround(C, 2.0000000, 0.0000000, (WinWidth - float(4)), WinHeight, Root.Colors.TeamColorDark[0]);			
		}
		else
		{
			DrawSimpleBackGround(C, 2.0000000, 0.0000000, (WinWidth - float(4)), WinHeight, Root.Colors.TeamColorDark[1]);
		}
		C.SetDrawColor(m_vTeamColor.R, m_vTeamColor.G, m_vTeamColor.B);
		DrawInGameTeamBar(C, 0.0000000, 15.0000000);
		DrawInGameTeamBarUpBorder(C, 2.0000000, 0.0000000, (WinWidth - float(4)), 15.0000000);
		DrawInGameTeamBarDownBorder(C, 2.0000000, (WinHeight - float(12)), (WinWidth - float(4)), 12.0000000);
	}
	return;
}

//===============================================================================
// Set the new parameters of this window and the child
//===============================================================================
function SetWindowSize(float _fX, float _fY, float _fW, float _fH)
{
	local float fOldTop, fOldLeft;

	fOldTop = WinTop;
	fOldLeft = WinLeft;
	WinTop = _fY;
	WinLeft = _fX;
	WinWidth = _fW;
	WinHeight = _fH;
	// End:0x112
	if(m_bDisplayObj)
	{
		// End:0x92
		if((m_pTitleCoop != none))
		{
			m_pTitleCoop.WinTop = 0.0000000;
			m_pTitleCoop.WinWidth = _fW;
			m_pTitleCoop.WinHeight = 20.0000000;
		}
		// End:0x112
		if((m_pMissionObj != none))
		{
			m_pMissionObj.WinTop = 20.0000000;
			m_pMissionObj.WinWidth = _fW;
			m_pMissionObj.WinHeight = (_fH - float(20));
			m_pMissionObj.SetNewObjWindowSizes(_fX, _fY, _fW, _fH, true);
			m_pMissionObj.UpdateObjectives();
		}
	}
	// End:0x15F
	if((m_pTextTeamBar != none))
	{
		m_pTextTeamBar.WinTop = 0.0000000;
		m_pTextTeamBar.WinWidth = _fW;
		m_pTextTeamBar.WinHeight = _fH;
		Refresh();
	}
	// End:0x1AE
	if((m_IGPlayerInfoListBox != none))
	{
		m_IGPlayerInfoListBox.WinTop = 15.0000000;
		m_IGPlayerInfoListBox.WinWidth = _fW;
		m_IGPlayerInfoListBox.WinHeight = (_fH - GetPlayerListBorderHeight());
	}
	return;
}

//===============================================================================
// Refresh server info
//===============================================================================
function RefreshTeamBarInfo(int _iTeam)
{
	local int iTotalOfPlayers;
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x42
	if((r6Root.m_szCurrentGameType == "RGM_DeathmatchMode"))
	{
		iTotalOfPlayers = 16;		
	}
	else
	{
		iTotalOfPlayers = 8;
	}
	m_iTotalKills = 0;
	m_iTotalNbOfDead = 0;
	m_iTotalEfficiency = 0;
	m_iTotalRoundsFired = 0;
	m_iTotalRoundsTaken = 0;
	m_iTotalRoomTake = 0;
	ClearListOfItem();
	AddItems(_iTeam, iTotalOfPlayers);
	// End:0x185
	if((r6Root.m_szCurrentGameType == "RGM_DeathmatchMode"))
	{
		m_pTextTeamBar.ChangeTextLabel(Localize("MPInGame", "PlayersName", "R6Menu"), m_iIndex[1]);
		m_pTextTeamBar.ChangeTextLabel("", m_iIndex[8]);
		m_pTextTeamBar.ChangeTextLabel("", m_iIndex[3]);
		m_pTextTeamBar.ChangeTextLabel("", m_iIndex[4]);
		m_pTextTeamBar.ChangeTextLabel("", m_iIndex[5]);
		m_pTextTeamBar.ChangeTextLabel("", m_iIndex[6]);
		m_pTextTeamBar.ChangeTextLabel("", m_iIndex[7]);		
	}
	else
	{
		m_pTextTeamBar.ChangeTextLabel(m_szTeamName, m_iIndex[1]);
		m_pTextTeamBar.ChangeTextLabel(Localize("MPInGame", "TotalTeamStatus", "R6Menu"), m_iIndex[8]);
		m_pTextTeamBar.ChangeTextLabel(string(m_iTotalKills), m_iIndex[3]);
		m_pTextTeamBar.ChangeTextLabel(string(m_iTotalNbOfDead), m_iIndex[4]);
		m_pTextTeamBar.ChangeTextLabel(string(m_iTotalEfficiency), m_iIndex[5]);
		m_pTextTeamBar.ChangeTextLabel(string(m_iTotalRoundsFired), m_iIndex[6]);
		m_pTextTeamBar.ChangeTextLabel(string(m_iTotalRoundsTaken), m_iIndex[7]);
	}
	return;
}

//===============================================================================
// Refresh: The fix team bar parameters are refresh (because we change the window size)
//===============================================================================
function Refresh()
{
	local float fXOffset, fYOffset, fYStep, fWidth;

	m_pTextTeamBar.Clear();
	fYOffset = 2.0000000;
	fXOffset = m_stMenuCoord[int(2)].fXPos;
	fWidth = m_stMenuCoord[int(2)].fWidth;
	m_iIndex[1] = m_pTextTeamBar.AddTextLabel(m_szTeamName, fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = 4.0000000;
	fYOffset = ((WinHeight - float(12)) + float(1));
	m_iIndex[8] = m_pTextTeamBar.AddTextLabel("", fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = m_stMenuCoord[int(4)].fXPos;
	fWidth = m_stMenuCoord[int(4)].fWidth;
	m_iIndex[3] = m_pTextTeamBar.AddTextLabel("00", fXOffset, fYOffset, fWidth, 2, false);
	fXOffset = m_stMenuCoord[int(5)].fXPos;
	fWidth = m_stMenuCoord[int(5)].fWidth;
	m_iIndex[4] = m_pTextTeamBar.AddTextLabel("00", fXOffset, fYOffset, fWidth, 2, false);
	fXOffset = m_stMenuCoord[int(6)].fXPos;
	fWidth = m_stMenuCoord[int(6)].fWidth;
	m_iIndex[5] = m_pTextTeamBar.AddTextLabel("00", fXOffset, fYOffset, fWidth, 2, false);
	fXOffset = m_stMenuCoord[int(7)].fXPos;
	fWidth = m_stMenuCoord[int(7)].fWidth;
	m_iIndex[6] = m_pTextTeamBar.AddTextLabel("00", fXOffset, fYOffset, fWidth, 2, false);
	fXOffset = m_stMenuCoord[int(8)].fXPos;
	fWidth = m_stMenuCoord[int(8)].fWidth;
	m_iIndex[7] = m_pTextTeamBar.AddTextLabel("00", fXOffset, fYOffset, fWidth, 2, false);
	return;
}

function AddItems(int _iTeam, int _iTotalOfPlayers)
{
	local R6WindowListIGPlayerInfoItem NewItem;
	local UWindowList CurItem, ParseItem;
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local R6WindowIGPlayerInfoListBox pListTemp;
	local int i, iIndex, j;
	local bool bAddItem;
	local PlayerMenuInfo _PlayerMenuInfo;
	local R6MenuMPInterWidget MpInter;
	local int iTeamPlayerCount;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x96D
	if((r6Root.m_R6GameMenuCom != none))
	{
		MpInter = R6MenuMPInterWidget(OwnerWindow);
		CurItem = m_IGPlayerInfoListBox.Items.Next;
		iTeamPlayerCount = 0;
		i = 0;
		J0x5F:

		// End:0x950 [Loop If]
		if((i < r6Root.m_R6GameMenuCom.m_iLastValidIndex))
		{
			bAddItem = true;
			iIndex = r6Root.m_R6GameMenuCom.GeTTeamSelection(i);
			GetLevel().GetFPlayerMenuInfo(i, _PlayerMenuInfo);
			// End:0x1FB
			if((iIndex != _iTeam))
			{
				bAddItem = false;
				// End:0x1FB
				if((iIndex == int(r6Root.m_R6GameMenuCom.4)))
				{
					// End:0x133
					if((_iTeam == int(r6Root.m_R6GameMenuCom.2)))
					{
						// End:0x130
						if((m_iTotalRoomTake < _iTotalOfPlayers))
						{
							bAddItem = true;
						}						
					}
					else
					{
						// End:0x1FB
						if((MpInter.m_pR6AlphaTeam.m_iTotalRoomTake == _iTotalOfPlayers))
						{
							bAddItem = true;
							pListTemp = MpInter.m_pR6AlphaTeam.m_IGPlayerInfoListBox;
							ParseItem = pListTemp.Items.Next;
							j = 0;
							J0x19D:

							// End:0x1FB [Loop If]
							if((j < _iTotalOfPlayers))
							{
								// End:0x1DD
								if((Left(_PlayerMenuInfo.szPlayerName, 15) ~= R6WindowListIGPlayerInfoItem(ParseItem).szPlName))
								{
									bAddItem = false;
									// [Explicit Break]
									goto J0x1FB;
								}
								ParseItem = ParseItem.Next;
								(j++);
								// [Loop Continue]
								goto J0x19D;
							}
						}
					}
				}
			}
			J0x1FB:

			// End:0x946
			if(bAddItem)
			{
				NewItem = R6WindowListIGPlayerInfoItem(CurItem);
				iIndex = int(NewItem.0);
				NewItem.bReady = _PlayerMenuInfo.bPlayerReady;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(0)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(0)].fWidth;
				iIndex = int(NewItem.1);
				// End:0x2D2
				if(_PlayerMenuInfo.bSpectator)
				{
					NewItem.eStatus = NewItem.4;					
				}
				else
				{
					// End:0x2FD
					if(_PlayerMenuInfo.bJoinedTeamLate)
					{
						NewItem.eStatus = NewItem.5;						
					}
					else
					{
						switch(_PlayerMenuInfo.iHealth)
						{
							// End:0x32A
							case 0:
								NewItem.eStatus = NewItem.0;
								// End:0x370
								break;
							// End:0x34B
							case 1:
								NewItem.eStatus = NewItem.1;
								// End:0x370
								break;
							// End:0x350
							case 2:
							// End:0xFFFF
							default:
								NewItem.eStatus = NewItem.3;
								// End:0x370
								break;
								break;
						}
					}
				}
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(1)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(1)].fWidth;
				iIndex = int(NewItem.2);
				NewItem.szPlName = Left(_PlayerMenuInfo.szPlayerName, 15);
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(2)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(2)].fWidth;
				iIndex = int(NewItem.3);
				NewItem.stTagCoord[iIndex].bDisplay = (!m_bTeamMenuLayout);
				NewItem.szRoundsWon = ((string(_PlayerMenuInfo.iRoundsWon) $ "/") $ string(_PlayerMenuInfo.iRoundsPlayed));
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(3)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(3)].fWidth;
				iIndex = int(NewItem.4);
				NewItem.iKills = _PlayerMenuInfo.iKills;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(4)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(4)].fWidth;
				iIndex = int(NewItem.5);
				NewItem.iMyDeadCounter = _PlayerMenuInfo.iDeathCount;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(5)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(5)].fWidth;
				iIndex = int(NewItem.6);
				NewItem.iEfficiency = _PlayerMenuInfo.iEfficiency;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(6)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(6)].fWidth;
				iIndex = int(NewItem.7);
				NewItem.iRoundsFired = _PlayerMenuInfo.iRoundsFired;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(7)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(7)].fWidth;
				iIndex = int(NewItem.8);
				NewItem.iRoundsHit = _PlayerMenuInfo.iRoundsHit;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(8)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(8)].fWidth;
				iIndex = int(NewItem.9);
				NewItem.szKillBy = _PlayerMenuInfo.szKilledBy;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(9)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(9)].fWidth;
				iIndex = int(NewItem.10);
				NewItem.iPingTime = _PlayerMenuInfo.iPingTime;
				NewItem.stTagCoord[iIndex].fXPos = m_stMenuCoord[int(10)].fXPos;
				NewItem.stTagCoord[iIndex].fWidth = m_stMenuCoord[int(10)].fWidth;
				NewItem.bOwnPlayer = _PlayerMenuInfo.bOwnPlayer;
				(m_iTotalKills += NewItem.iKills);
				(m_iTotalNbOfDead += NewItem.iMyDeadCounter);
				(m_iTotalEfficiency += NewItem.iEfficiency);
				(m_iTotalRoundsFired += NewItem.iRoundsFired);
				(m_iTotalRoundsTaken += NewItem.iRoundsHit);
				(m_iTotalRoomTake += 1);
				// End:0x921
				if(((!_PlayerMenuInfo.bSpectator) && (!_PlayerMenuInfo.bJoinedTeamLate)))
				{
					(iTeamPlayerCount++);
				}
				NewItem.m_bShowThisItem = true;
				CurItem = CurItem.Next;
			}
			(i++);
			// [Loop Continue]
			goto J0x5F;
		}
		// End:0x96D
		if((iTeamPlayerCount > 0))
		{
			m_iTotalEfficiency = (m_iTotalEfficiency / iTeamPlayerCount);
		}
	}
	return;
}

function ClearListOfItem()
{
	local R6WindowListIGPlayerInfoItem NewItem;
	local UWindowList CurItem;
	local int i;
	local bool bAlreadyCreate;

	// End:0x42
	if((m_IGPlayerInfoListBox.Items.Next != none))
	{
		bAlreadyCreate = true;
		CurItem = m_IGPlayerInfoListBox.Items.Next;
	}
	i = 0;
	J0x49:

	// End:0xD2 [Loop If]
	if((i < 16))
	{
		// End:0x86
		if(bAlreadyCreate)
		{
			CurItem.m_bShowThisItem = false;
			CurItem = CurItem.Next;
			// [Explicit Continue]
			goto J0xC8;
		}
		NewItem = R6WindowListIGPlayerInfoItem(m_IGPlayerInfoListBox.Items.Append(m_IGPlayerInfoListBox.ListClass));
		NewItem.m_bShowThisItem = false;
		J0xC8:

		(i++);
		// [Loop Continue]
		goto J0x49;
	}
	return;
}

//===============================================================================
// Get the total height of the header ALPHA TEAM and TOTAL TEAM STATUS
//===============================================================================
function float GetPlayerListBorderHeight()
{
	return (15.0000000 + float(12));
	return;
}

//=================================================================================================
// DrawInGameTeamBar: This function draw the in-game team bar, icons and lines
//=================================================================================================
function DrawInGameTeamBar(Canvas C, float _fY, float _fHeight)
{
	local float fXOffset, fWidth;

	fXOffset = m_stMenuCoord[int(0)].fXPos;
	fWidth = m_stMenuCoord[int(0)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 0);
	fXOffset = m_stMenuCoord[int(1)].fXPos;
	fWidth = m_stMenuCoord[int(1)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 1);
	fXOffset = m_stMenuCoord[int(2)].fXPos;
	fWidth = m_stMenuCoord[int(2)].fWidth;
	fXOffset = (fXOffset + fWidth);
	AddVerticalLine(C, fXOffset, _fY, float(m_BorderTextureRegion.W), WinHeight);
	// End:0x186
	if((!m_bTeamMenuLayout))
	{
		fXOffset = m_stMenuCoord[int(3)].fXPos;
		fWidth = m_stMenuCoord[int(3)].fWidth;
		AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 2);
		fXOffset = (fXOffset + fWidth);
		AddVerticalLine(C, fXOffset, _fY, float(m_BorderTextureRegion.W), WinHeight);
	}
	fXOffset = m_stMenuCoord[int(4)].fXPos;
	fWidth = m_stMenuCoord[int(4)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 3);
	fXOffset = m_stMenuCoord[int(5)].fXPos;
	fWidth = m_stMenuCoord[int(5)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 4);
	fXOffset = (fXOffset + fWidth);
	AddVerticalLine(C, fXOffset, _fY, float(m_BorderTextureRegion.W), WinHeight);
	fXOffset = m_stMenuCoord[int(6)].fXPos;
	fWidth = m_stMenuCoord[int(6)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 5);
	fXOffset = m_stMenuCoord[int(7)].fXPos;
	fWidth = m_stMenuCoord[int(7)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 6);
	fXOffset = m_stMenuCoord[int(8)].fXPos;
	fWidth = m_stMenuCoord[int(8)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 7);
	fXOffset = (fXOffset + fWidth);
	AddVerticalLine(C, fXOffset, _fY, float(m_BorderTextureRegion.W), WinHeight);
	fXOffset = m_stMenuCoord[int(9)].fXPos;
	fWidth = m_stMenuCoord[int(9)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 8);
	fXOffset = (fXOffset + fWidth);
	AddVerticalLine(C, fXOffset, _fY, float(m_BorderTextureRegion.W), WinHeight);
	fXOffset = m_stMenuCoord[int(10)].fXPos;
	fWidth = m_stMenuCoord[int(10)].fWidth;
	AddIcon(C, fXOffset, _fY, fWidth, _fHeight, 9);
	return;
}

function AddVerticalLine(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight)
{
	DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, _fHeight, float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

function AddIcon(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight, R6MenuMPTeamBar.eIconType _eIconType)
{
	local Region RIconRegion, RIconToDraw;
	local R6MenuRSLookAndFeel R6LAF;
	local float fY;

	R6LAF = R6MenuRSLookAndFeel(LookAndFeel);
	fY = _fY;
	switch(_eIconType)
	{
		// End:0x5E
		case 0:
			RIconToDraw.X = 18;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 8;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x99
		case 1:
			RIconToDraw.X = 0;
			RIconToDraw.Y = 28;
			RIconToDraw.W = 13;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0xD5
		case 2:
			RIconToDraw.X = 27;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 8;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x111
		case 3:
			RIconToDraw.X = 36;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 12;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x14C
		case 4:
			RIconToDraw.X = 14;
			RIconToDraw.Y = 0;
			RIconToDraw.W = 13;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x187
		case 5:
			RIconToDraw.X = 28;
			RIconToDraw.Y = 0;
			RIconToDraw.W = 14;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x1C3
		case 6:
			RIconToDraw.X = 49;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 7;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x1FF
		case 7:
			RIconToDraw.X = 14;
			RIconToDraw.Y = 28;
			RIconToDraw.W = 16;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x23A
		case 8:
			RIconToDraw.X = 0;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 17;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0x275
		case 9:
			RIconToDraw.X = 46;
			RIconToDraw.Y = 0;
			RIconToDraw.W = 13;
			RIconToDraw.H = 14;
			// End:0x278
			break;
		// End:0xFFFF
		default:
			break;
	}
	RIconRegion = R6LAF.CenterIconInBox(_fX, fY, _fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	return;
}

//=======================================================================================================
// Draw in game team bar up border. This function is right now call by DrawInGameTeamBar
//=======================================================================================================
function DrawInGameTeamBarUpBorder(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight)
{
	C.SetDrawColor(m_vTeamColor.R, m_vTeamColor.G, m_vTeamColor.B);
	DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, _fX, (_fY + _fHeight), _fWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

//=======================================================================================================
// Draw in game team bar down border. This function is right now call by DrawInGameTeamBar
//=======================================================================================================
function DrawInGameTeamBarDownBorder(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight)
{
	C.SetDrawColor(m_vTeamColor.R, m_vTeamColor.G, m_vTeamColor.B);
	DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

//===============================================================================
// Init text header
//===============================================================================
function InitTeamBar()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;

	// End:0x96
	if((m_pTextTeamBar == none))
	{
		m_pTextTeamBar = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, WinWidth, WinHeight, self));
		m_pTextTeamBar.bAlwaysBehind = true;
		m_pTextTeamBar.SetNoBorder();
		m_pTextTeamBar.m_Font = Root.Fonts[6];
		m_pTextTeamBar.m_vTextColor = m_vTeamColor;
		Refresh();
		InitIGPlayerInfoList();
	}
	return;
}

function InitIGPlayerInfoList()
{
	m_IGPlayerInfoListBox = R6WindowIGPlayerInfoListBox(CreateWindow(Class'R6Window.R6WindowIGPlayerInfoListBox', 0.0000000, 15.0000000, WinWidth, (WinHeight - GetPlayerListBorderHeight()), self));
	m_IGPlayerInfoListBox.SetCornerType(1);
	m_IGPlayerInfoListBox.m_Font = Root.Fonts[6];
	return;
}

function InitMissionWindows()
{
	m_pTitleCoop = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, 20.0000000, self));
	m_pTitleCoop.Text = Localize("MPInGame", "Coop_MissionDebr", "R6Menu");
	m_pTitleCoop.Align = 2;
	m_pTitleCoop.m_Font = Root.Fonts[8];
	m_pTitleCoop.TextColor = Root.Colors.White;
	m_pTitleCoop.m_fHBorderPadding = 2.0000000;
	m_pTitleCoop.m_VBorderTexture = none;
	m_pMissionObj = R6MenuMPInGameObj(CreateWindow(Root.MenuClassDefines.ClassInGameObjectives, 0.0000000, 20.0000000, WinWidth, (WinHeight - float(20)), self));
	return;
}

//===================================================================================
// InitMenuLayout: init menu layout (the size of the winwidth is 590)
//===================================================================================
function InitMenuLayout(int _MenuToDisplay)
{
	m_bTeamMenuLayout = false;
	// End:0x2E9
	if((_MenuToDisplay == 1))
	{
		m_bTeamMenuLayout = true;
		m_stMenuCoord[int(0)].fXPos = 4.0000000;
		m_stMenuCoord[int(0)].fWidth = 15.0000000;
		m_stMenuCoord[int(1)].fXPos = (m_stMenuCoord[int(0)].fXPos + m_stMenuCoord[int(0)].fWidth);
		m_stMenuCoord[int(1)].fWidth = 21.0000000;
		m_stMenuCoord[int(2)].fXPos = (m_stMenuCoord[int(1)].fXPos + m_stMenuCoord[int(1)].fWidth);
		m_stMenuCoord[int(2)].fWidth = 153.0000000;
		m_stMenuCoord[int(3)].fXPos = 0.0000000;
		m_stMenuCoord[int(3)].fWidth = 0.0000000;
		m_stMenuCoord[int(4)].fXPos = (m_stMenuCoord[int(2)].fXPos + m_stMenuCoord[int(2)].fWidth);
		m_stMenuCoord[int(4)].fWidth = 42.0000000;
		m_stMenuCoord[int(5)].fXPos = (m_stMenuCoord[int(4)].fXPos + m_stMenuCoord[int(4)].fWidth);
		m_stMenuCoord[int(5)].fWidth = 41.0000000;
		m_stMenuCoord[int(6)].fXPos = (m_stMenuCoord[int(5)].fXPos + m_stMenuCoord[int(5)].fWidth);
		m_stMenuCoord[int(6)].fWidth = 40.0000000;
		m_stMenuCoord[int(7)].fXPos = (m_stMenuCoord[int(6)].fXPos + m_stMenuCoord[int(6)].fWidth);
		m_stMenuCoord[int(7)].fWidth = 40.0000000;
		m_stMenuCoord[int(8)].fXPos = (m_stMenuCoord[int(7)].fXPos + m_stMenuCoord[int(7)].fWidth);
		m_stMenuCoord[int(8)].fWidth = 40.0000000;
		m_stMenuCoord[int(9)].fXPos = (m_stMenuCoord[int(8)].fXPos + m_stMenuCoord[int(8)].fWidth);
		m_stMenuCoord[int(9)].fWidth = m_stMenuCoord[int(2)].fWidth;
		m_stMenuCoord[int(10)].fXPos = (m_stMenuCoord[int(9)].fXPos + m_stMenuCoord[int(9)].fWidth);
		m_stMenuCoord[int(10)].fWidth = 41.0000000;		
	}
	else
	{
		m_stMenuCoord[int(0)].fXPos = 2.0000000;
		m_stMenuCoord[int(0)].fWidth = 15.0000000;
		m_stMenuCoord[int(1)].fXPos = (m_stMenuCoord[int(0)].fXPos + m_stMenuCoord[int(0)].fWidth);
		m_stMenuCoord[int(1)].fWidth = 15.0000000;
		m_stMenuCoord[int(2)].fXPos = (m_stMenuCoord[int(1)].fXPos + m_stMenuCoord[int(1)].fWidth);
		m_stMenuCoord[int(2)].fWidth = 153.0000000;
		m_stMenuCoord[int(3)].fXPos = (m_stMenuCoord[int(2)].fXPos + m_stMenuCoord[int(2)].fWidth);
		m_stMenuCoord[int(3)].fWidth = 37.0000000;
		m_stMenuCoord[int(4)].fXPos = (m_stMenuCoord[int(3)].fXPos + m_stMenuCoord[int(3)].fWidth);
		m_stMenuCoord[int(4)].fWidth = 36.0000000;
		m_stMenuCoord[int(5)].fXPos = (m_stMenuCoord[int(4)].fXPos + m_stMenuCoord[int(4)].fWidth);
		m_stMenuCoord[int(5)].fWidth = 36.0000000;
		m_stMenuCoord[int(6)].fXPos = (m_stMenuCoord[int(5)].fXPos + m_stMenuCoord[int(5)].fWidth);
		m_stMenuCoord[int(6)].fWidth = 36.0000000;
		m_stMenuCoord[int(7)].fXPos = (m_stMenuCoord[int(6)].fXPos + m_stMenuCoord[int(6)].fWidth);
		m_stMenuCoord[int(7)].fWidth = 36.0000000;
		m_stMenuCoord[int(8)].fXPos = (m_stMenuCoord[int(7)].fXPos + m_stMenuCoord[int(7)].fWidth);
		m_stMenuCoord[int(8)].fWidth = 36.0000000;
		m_stMenuCoord[int(9)].fXPos = (m_stMenuCoord[int(8)].fXPos + m_stMenuCoord[int(8)].fWidth);
		m_stMenuCoord[int(9)].fWidth = m_stMenuCoord[int(2)].fWidth;
		m_stMenuCoord[int(10)].fXPos = (m_stMenuCoord[int(9)].fXPos + m_stMenuCoord[int(9)].fWidth);
		m_stMenuCoord[int(10)].fWidth = 35.0000000;
	}
	return;
}

defaultproperties
{
	m_TIcon=Texture'R6MenuTextures.Credits.TeamBarIcon'
}
