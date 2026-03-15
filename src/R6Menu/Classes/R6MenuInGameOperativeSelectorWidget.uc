//=============================================================================
// R6MenuInGameOperativeSelectorWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuInGameWritableMapWidget.uc : Game Main Menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/04/05 * Created by Hugo Allaire
//=============================================================================
class R6MenuInGameOperativeSelectorWidget extends R6MenuWidget;

var const int c_OutsideMarginX;
var const int c_OutsideMarginY;
var const int c_InsideMarginX;
var const int c_InsideMarginY;
var const int c_ColumnWidth;
var const int c_RowHeight;
var bool m_bInitalized;
var bool m_bIsSinglePlayer;
var Sound m_OperativeOpenSnd;
var R6GameOptions m_pGameOptions;
var array<R6OperativeSelectorItem> aItems;

function UpdateOperativeItems()
{
	local R6GameReplicationInfo gameRepInfo;
	local int iOperative, iOperativeCount, iOperativePos, iPosX, iPosY, iTeam;

	local R6RainbowTeam MPTeam;
	local R6TeamMemberReplicationInfo pTeamMemberRepInfo;
	local R6Rainbow P;

	gameRepInfo = R6GameReplicationInfo(GetPlayerOwner().GameReplicationInfo);
	iOperativePos = 0;
	m_bIsSinglePlayer = (int(gameRepInfo.Level.NetMode) == int(NM_Standalone));
	// End:0x220
	if(m_bIsSinglePlayer)
	{
		iTeam = 0;
		J0x57:

		// End:0x21D [Loop If]
		if((iTeam < 3))
		{
			iPosX = ((c_OutsideMarginX + c_InsideMarginX) + (iTeam * (c_InsideMarginX + c_ColumnWidth)));
			// End:0x213
			if((gameRepInfo.m_RainbowTeam[iTeam] != none))
			{
				iOperativeCount = (gameRepInfo.m_RainbowTeam[iTeam].m_iMembersLost + gameRepInfo.m_RainbowTeam[iTeam].m_iMemberCount);
				iOperative = 0;
				J0xED:

				// End:0x213 [Loop If]
				if((iOperative < iOperativeCount))
				{
					iPosY = ((c_OutsideMarginY + c_InsideMarginY) + (iOperative * (c_InsideMarginY + c_RowHeight)));
					// End:0x166
					if((!m_bInitalized))
					{
						aItems[iOperativePos] = R6OperativeSelectorItem(CreateWindow(Class'R6Menu.R6OperativeSelectorItem', float(iPosX), float(iPosY), float(c_ColumnWidth), float(c_RowHeight)));
					}
					aItems[iOperativePos].SetCharacterInfo(gameRepInfo.m_RainbowTeam[iTeam].m_Team[iOperative]);
					aItems[iOperativePos].m_DarkColor = Root.Colors.TeamColorDark[iTeam];
					aItems[iOperativePos].m_NormalColor = Root.Colors.TeamColor[iTeam];
					(iOperativePos++);
					(iOperative++);
					// [Loop Continue]
					goto J0xED;
				}
			}
			(iTeam++);
			// [Loop Continue]
			goto J0x57;
		}		
	}
	else
	{
		m_pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
		P = R6Rainbow(GetPlayerOwner().Pawn);
		iPosX = ((c_OutsideMarginX + c_InsideMarginX) + (c_InsideMarginX + c_ColumnWidth));
		iOperative = 0;
		J0x273:

		// End:0x308 [Loop If]
		if((iOperative < 4))
		{
			// End:0x2E9
			if((!m_bInitalized))
			{
				iPosY = ((c_OutsideMarginY + c_InsideMarginY) + (iOperative * (c_InsideMarginY + c_RowHeight)));
				aItems[iOperative] = R6OperativeSelectorItem(CreateWindow(Class'R6Menu.R6OperativeSelectorItem', float(iPosX), float(iPosY), float(c_ColumnWidth), float(c_RowHeight)));
			}
			aItems[iOperative].HideWindow();
			(iOperative++);
			// [Loop Continue]
			goto J0x273;
		}
		// End:0x3ED
		foreach P.AllActors(Class'R6Engine.R6TeamMemberReplicationInfo', pTeamMemberRepInfo)
		{
			// End:0x3EC
			if((P.m_TeamMemberRepInfo.m_iTeamId == pTeamMemberRepInfo.m_iTeamId))
			{
				aItems[int(pTeamMemberRepInfo.m_iTeamPosition)].SetCharacterInfoMP(pTeamMemberRepInfo);
				aItems[int(pTeamMemberRepInfo.m_iTeamPosition)].m_DarkColor = m_pGameOptions.HUDMPDarkColor;
				aItems[int(pTeamMemberRepInfo.m_iTeamPosition)].m_NormalColor = m_pGameOptions.HUDMPColor;
				aItems[int(pTeamMemberRepInfo.m_iTeamPosition)].ShowWindow();
			}			
		}		
	}
	m_bInitalized = true;
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	UpdateOperativeItems();
	GetPlayerOwner().__NFUN_264__(m_OperativeOpenSnd, 9) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
	return;
}

function HideWindow()
{
	local int iOperativePos;

	super(UWindowWindow).HideWindow();
	iOperativePos = 0;
	J0x0D:

	// End:0x53 [Loop If]
	if(__NFUN_150__(iOperativePos, aItems.Length))
	{
		aItems[iOperativePos].m_Operative = none;
		aItems[iOperativePos].m_MemberRepInfo = none;
		__NFUN_165__(iOperativePos);
		// [Loop Continue]
		goto J0x0D;
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local int iOperative, iTeam, iPosX, iPosY;
	local string szTeam;
	local float fTeamPosX, fTeamPosY;
	local R6Rainbow P;
	local R6TeamMemberReplicationInfo pTeamMemberRepInfo;

	// End:0x36D
	if(m_bIsSinglePlayer)
	{
		iTeam = 0;
		J0x10:

		// End:0x36A [Loop If]
		if(__NFUN_150__(iTeam, 3))
		{
			C.Style = 5;
			iPosX = __NFUN_146__(__NFUN_146__(c_OutsideMarginX, c_InsideMarginX), __NFUN_144__(iTeam, __NFUN_146__(c_InsideMarginX, c_ColumnWidth)));
			iPosY = __NFUN_146__(63, c_InsideMarginY);
			C.DrawColor = Root.Colors.TeamColor[iTeam];
			C.DrawColor.A = 51;
			DrawStretchedTextureSegment(C, float(__NFUN_146__(iPosX, 1)), float(__NFUN_146__(iPosY, 1)), float(__NFUN_147__(c_ColumnWidth, 2)), 18.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
			C.DrawColor.A = byte(255);
			C.__NFUN_2623__(float(__NFUN_146__(iPosX, __NFUN_145__(c_ColumnWidth, 2))), float(__NFUN_146__(iPosY, 2)));
			switch(iTeam)
			{
				// End:0x163
				case 0:
					szTeam = __NFUN_235__(Localize("COLOR", "ID_RED", "R6COMMON"));
					// End:0x1C6
					break;
				// End:0x193
				case 1:
					szTeam = __NFUN_235__(Localize("COLOR", "ID_GREEN", "R6COMMON"));
					// End:0x1C6
					break;
				// End:0x1C3
				case 2:
					szTeam = __NFUN_235__(Localize("COLOR", "ID_GOLD", "R6COMMON"));
					// End:0x1C6
					break;
				// End:0xFFFF
				default:
					break;
			}
			TextSize(C, szTeam, fTeamPosX, fTeamPosY);
			C.__NFUN_2623__(__NFUN_174__(float(iPosX), __NFUN_172__(__NFUN_175__(float(c_ColumnWidth), fTeamPosX), float(2))), float(__NFUN_146__(iPosY, 1)));
			C.__NFUN_465__(szTeam);
			DrawStretchedTextureSegment(C, float(iPosX), float(iPosY), float(c_ColumnWidth), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
			DrawStretchedTextureSegment(C, float(iPosX), float(__NFUN_147__(__NFUN_146__(iPosY, 17), 1)), float(c_ColumnWidth), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
			DrawStretchedTextureSegment(C, float(iPosX), float(iPosY), 1.0000000, 17.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
			DrawStretchedTextureSegment(C, float(__NFUN_147__(__NFUN_146__(iPosX, c_ColumnWidth), 1)), float(iPosY), 1.0000000, 17.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
			iOperative = 0;
			J0x331:

			// End:0x360 [Loop If]
			if(__NFUN_150__(iOperative, aItems.Length))
			{
				aItems[iOperative].UpdatePosition();
				__NFUN_165__(iOperative);
				// [Loop Continue]
				goto J0x331;
			}
			__NFUN_165__(iTeam);
			// [Loop Continue]
			goto J0x10;
		}		
	}
	else
	{
		C.Style = 5;
		iPosX = __NFUN_146__(__NFUN_146__(c_OutsideMarginX, c_InsideMarginX), __NFUN_146__(c_InsideMarginX, c_ColumnWidth));
		iPosY = __NFUN_146__(63, c_InsideMarginY);
		C.DrawColor = m_pGameOptions.HUDMPColor;
		C.DrawColor.A = 51;
		DrawStretchedTextureSegment(C, float(__NFUN_146__(iPosX, 1)), float(__NFUN_146__(iPosY, 1)), float(__NFUN_147__(c_ColumnWidth, 2)), 18.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
		C.DrawColor.A = byte(255);
		C.__NFUN_2623__(float(__NFUN_146__(iPosX, __NFUN_145__(c_ColumnWidth, 2))), float(__NFUN_146__(iPosY, 2)));
		szTeam = __NFUN_235__(Localize("MISC", "Team", "R6Menu"));
		TextSize(C, szTeam, fTeamPosX, fTeamPosY);
		C.__NFUN_2623__(__NFUN_174__(float(iPosX), __NFUN_172__(__NFUN_175__(float(c_ColumnWidth), fTeamPosX), float(2))), float(__NFUN_146__(iPosY, 1)));
		C.__NFUN_465__(szTeam);
		DrawStretchedTextureSegment(C, float(iPosX), float(iPosY), float(c_ColumnWidth), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
		DrawStretchedTextureSegment(C, float(iPosX), float(__NFUN_147__(__NFUN_146__(iPosY, 17), 1)), float(c_ColumnWidth), 1.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
		DrawStretchedTextureSegment(C, float(iPosX), float(iPosY), 1.0000000, 17.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
		DrawStretchedTextureSegment(C, float(__NFUN_147__(__NFUN_146__(iPosX, c_ColumnWidth), 1)), float(iPosY), 1.0000000, 17.0000000, 0.0000000, 0.0000000, 1.0000000, 1.0000000, Texture'Color.Color.White');
		iOperative = 0;
		J0x5F6:

		// End:0x625 [Loop If]
		if(__NFUN_150__(iOperative, aItems.Length))
		{
			aItems[iOperative].UpdatePositionMP();
			__NFUN_165__(iOperative);
			// [Loop Continue]
			goto J0x5F6;
		}
	}
	return;
}

defaultproperties
{
	c_OutsideMarginX=19
	c_OutsideMarginY=83
	c_InsideMarginX=2
	c_InsideMarginY=3
	c_ColumnWidth=198
	c_RowHeight=89
	m_OperativeOpenSnd=Sound'SFX_Menus.Play_Rose_Open'
}
