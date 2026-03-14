//=============================================================================
// R6MenuSingleTeamBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuSingleTeamBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/18 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSingleTeamBar extends UWindowDialogControl;

const C_fTEAMBAR_ICON_HEIGHT = 16;
const C_fTEAMBAR_MISSIONTIME_HEIGHT = 14;
const C_fTEAMBAR_TOTALS_HEIGHT = 15;
const C_fXICONS_START_POS = 0;

var int m_IBorderVOffset;
var int m_iTotalNeutralized;  // Team total Number of kills
var int m_iTotalEfficiency;  // Team total Efficiency (hits/shot)
var int m_iTotalRoundsFired;  // Team total Rounds fired (Bullets shot by the player)
var int m_iTotalRoundsTaken;  // Team total Rounds taken (Rounds that hits the player)
var int m_INameTextPadding;  // Put some padding at the left of the player name
var int m_IFirstItempYOffset;
var bool m_bDrawBorders;
var bool m_bDrawTotalsShading;
var bool bShowLog;
var float m_fBottomTitleWidth;
var float m_fTeamcolorWidth;
// NEW IN 1.60
var float m_fRainbowWidth;
// NEW IN 1.60
var float m_fHealthWidth;
// NEW IN 1.60
var float m_fSkullWidth;
// NEW IN 1.60
var float m_fEfficiencyWidth;
// NEW IN 1.60
var float m_fShotsWidth;
// NEW IN 1.60
var float m_fHitsWidth;
var R6WindowTextLabel m_BottomTitle;
// NEW IN 1.60
var R6WindowTextLabel m_TimeMissionTitle;
// NEW IN 1.60
var R6WindowTextLabel m_TimeMissionValue;
// NEW IN 1.60
var R6WindowTextLabel m_KillLabel;
// NEW IN 1.60
var R6WindowTextLabel m_EfficiencyLabel;
// NEW IN 1.60
var R6WindowTextLabel m_RoundsFiredLabel;
// NEW IN 1.60
var R6WindowTextLabel m_RoundsTakenLabel;
var R6WindowSimpleIGPlayerListBox m_IGPlayerInfoListBox;  // List of players with scroll bar
var Texture m_TIcon;
var Texture m_TBorder;
// NEW IN 1.60
var Texture m_THighLight;
var Region m_RBorder;
// NEW IN 1.60
var Region m_RHighLight;

function Paint(Canvas C, float X, float Y)
{
	local int IDblOffset;

	IDblOffset = __NFUN_144__(2, m_IBorderVOffset);
	// End:0x4C
	if(m_bDrawTotalsShading)
	{
		R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, 0.0000000, 16.0000000, WinWidth, __NFUN_175__(WinHeight, float(16)));
	}
	C.Style = 5;
	DrawInGameSingleTeamBar(C, 0.0000000, 1.0000000, 16.0000000);
	DrawInGameSingleTeamBarUpBorder(C, float(m_IBorderVOffset), 0.0000000, __NFUN_175__(WinWidth, float(IDblOffset)), 16.0000000);
	DrawInGameSingleTeamBarMiddleBorder(C, float(m_IBorderVOffset), __NFUN_175__(__NFUN_175__(WinHeight, float(15)), float(14)), __NFUN_175__(WinWidth, float(IDblOffset)), 15.0000000);
	DrawInGameSingleTeamBarDownBorder(C, float(m_IBorderVOffset), __NFUN_175__(WinHeight, float(14)), __NFUN_175__(WinWidth, float(IDblOffset)), 14.0000000);
	// End:0x11B
	if(m_bDrawBorders)
	{
		DrawSimpleBorder(C);
	}
	return;
}

function Created()
{
	local float YLabelPos, fXOffset;

	m_BorderColor = Root.Colors.GrayLight;
	fXOffset = 4.0000000;
	YLabelPos = __NFUN_175__(WinHeight, float(14));
	m_TimeMissionTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, YLabelPos, m_fBottomTitleWidth, 14.0000000, self));
	m_TimeMissionTitle.Align = 2;
	m_TimeMissionTitle.m_Font = Root.Fonts[5];
	m_TimeMissionTitle.TextColor = Root.Colors.BlueLight;
	m_TimeMissionTitle.m_fLMarge = fXOffset;
	m_TimeMissionTitle.SetNewText(Localize("DebriefingMenu", "MissionTime", "R6Menu"), true);
	m_TimeMissionTitle.m_bDrawBorders = false;
	m_TimeMissionValue = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_TimeMissionTitle.WinWidth, YLabelPos, __NFUN_175__(WinWidth, m_TimeMissionTitle.WinWidth), 14.0000000, self));
	m_TimeMissionValue.Align = 2;
	m_TimeMissionValue.m_Font = Root.Fonts[5];
	m_TimeMissionValue.TextColor = Root.Colors.White;
	m_TimeMissionValue.m_bDrawBorders = false;
	__NFUN_185__(YLabelPos, float(15));
	m_BottomTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, YLabelPos, m_fBottomTitleWidth, 15.0000000, self));
	m_BottomTitle.Align = 2;
	m_BottomTitle.m_Font = Root.Fonts[5];
	m_BottomTitle.TextColor = Root.Colors.BlueLight;
	m_BottomTitle.m_fLMarge = fXOffset;
	m_BottomTitle.SetNewText(Localize("MPInGame", "TotalTeamStatus", "R6Menu"), true);
	m_BottomTitle.m_bDrawBorders = false;
	m_KillLabel = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fBottomTitleWidth, YLabelPos, m_fSkullWidth, 15.0000000, self));
	m_KillLabel.Text = "00";
	m_KillLabel.Align = 2;
	m_KillLabel.m_Font = Root.Fonts[5];
	m_KillLabel.TextColor = Root.Colors.White;
	m_KillLabel.m_bDrawBorders = false;
	m_EfficiencyLabel = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', __NFUN_174__(m_KillLabel.WinLeft, m_KillLabel.WinWidth), YLabelPos, m_fEfficiencyWidth, 15.0000000, self));
	m_EfficiencyLabel.Text = "00";
	m_EfficiencyLabel.Align = 2;
	m_EfficiencyLabel.m_Font = Root.Fonts[5];
	m_EfficiencyLabel.TextColor = Root.Colors.White;
	m_EfficiencyLabel.m_bDrawBorders = false;
	m_RoundsFiredLabel = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', __NFUN_174__(m_EfficiencyLabel.WinLeft, m_EfficiencyLabel.WinWidth), YLabelPos, m_fShotsWidth, 15.0000000, self));
	m_RoundsFiredLabel.Text = "00";
	m_RoundsFiredLabel.Align = 2;
	m_RoundsFiredLabel.m_Font = Root.Fonts[5];
	m_RoundsFiredLabel.TextColor = Root.Colors.White;
	m_RoundsFiredLabel.m_bDrawBorders = false;
	m_RoundsTakenLabel = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', __NFUN_174__(m_RoundsFiredLabel.WinLeft, m_RoundsFiredLabel.WinWidth), YLabelPos, m_fHitsWidth, 15.0000000, self));
	m_RoundsTakenLabel.Text = "00";
	m_RoundsTakenLabel.Align = 2;
	m_RoundsTakenLabel.m_Font = Root.Fonts[5];
	m_RoundsTakenLabel.TextColor = Root.Colors.White;
	m_RoundsTakenLabel.m_bDrawBorders = false;
	CreateIGPListBox();
	return;
}

function DrawInGameSingleTeamBarMiddleBorder(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight)
{
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, float(m_RBorder.H), float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	DrawStretchedTextureSegment(C, m_fBottomTitleWidth, _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	DrawStretchedTextureSegment(C, _fX, __NFUN_175__(__NFUN_174__(_fY, _fHeight), float(m_RBorder.H)), _fWidth, float(m_RBorder.H), float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	return;
}

function DrawInGameSingleTeamBarDownBorder(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight)
{
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, m_fBottomTitleWidth, _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	// End:0x100
	if(__NFUN_129__(m_bDrawBorders))
	{
		DrawStretchedTextureSegment(C, _fX, __NFUN_175__(__NFUN_174__(_fY, _fHeight), float(m_RBorder.H)), _fWidth, float(m_RBorder.H), float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	}
	return;
}

function DrawInGameSingleTeamBarUpBorder(Canvas C, float _fX, float _fY, float _fWidth, float _fHeight)
{
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	DrawStretchedTextureSegment(C, _fX, __NFUN_174__(_fY, _fHeight), _fWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

function DrawInGameSingleTeamBar(Canvas C, float _fX, float _fY, float _fHeight)
{
	local float fXOffset, fWidth;
	local Region RIconRegion, RIconToDraw;
	local R6MenuRSLookAndFeel R6LAF;

	R6LAF = R6MenuRSLookAndFeel(LookAndFeel);
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	RIconToDraw.X = 52;
	RIconToDraw.Y = 52;
	RIconToDraw.W = 12;
	RIconToDraw.H = 12;
	fXOffset = _fX;
	fWidth = m_fTeamcolorWidth;
	RIconRegion = R6LAF.CenterIconInBox(fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, __NFUN_174__(fXOffset, fWidth), _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	RIconToDraw.X = 0;
	RIconToDraw.Y = 0;
	RIconToDraw.W = 13;
	RIconToDraw.H = 14;
	fXOffset = __NFUN_174__(fXOffset, fWidth);
	fWidth = m_fRainbowWidth;
	RIconRegion = R6LAF.CenterIconInBox(fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, __NFUN_174__(fXOffset, fWidth), _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	RIconToDraw.X = 0;
	RIconToDraw.Y = 28;
	RIconToDraw.W = 13;
	RIconToDraw.H = 14;
	fXOffset = __NFUN_174__(fXOffset, fWidth);
	fWidth = m_fHealthWidth;
	RIconRegion = R6LAF.CenterIconInBox(fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, __NFUN_174__(fXOffset, fWidth), _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	RIconToDraw.X = 14;
	RIconToDraw.Y = 0;
	RIconToDraw.W = 13;
	RIconToDraw.H = 14;
	fXOffset = __NFUN_174__(fXOffset, fWidth);
	fWidth = m_fSkullWidth;
	RIconRegion = R6LAF.CenterIconInBox(fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, __NFUN_174__(fXOffset, fWidth), _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	RIconToDraw.X = 28;
	RIconToDraw.Y = 0;
	RIconToDraw.W = 14;
	RIconToDraw.H = 14;
	fXOffset = __NFUN_174__(fXOffset, fWidth);
	fWidth = m_fEfficiencyWidth;
	RIconRegion = R6LAF.CenterIconInBox(fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, __NFUN_174__(fXOffset, fWidth), _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	RIconToDraw.X = 49;
	RIconToDraw.Y = 14;
	RIconToDraw.W = 7;
	RIconToDraw.H = 14;
	fXOffset = __NFUN_174__(fXOffset, fWidth);
	fWidth = m_fShotsWidth;
	RIconRegion = R6LAF.CenterIconInBox(fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTextureSegment(C, __NFUN_174__(fXOffset, fWidth), _fY, float(m_RBorder.W), _fHeight, float(m_RBorder.X), float(m_RBorder.Y), float(m_RBorder.W), float(m_RBorder.H), m_TBorder);
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	RIconToDraw.X = 14;
	RIconToDraw.Y = 28;
	RIconToDraw.W = 16;
	RIconToDraw.H = 14;
	fXOffset = __NFUN_174__(fXOffset, fWidth);
	fWidth = m_fHitsWidth;
	RIconRegion = R6LAF.CenterIconInBox(fXOffset, _fY, fWidth, _fHeight, RIconToDraw);
	DrawStretchedTextureSegment(C, float(RIconRegion.X), float(RIconRegion.Y), float(RIconToDraw.W), float(RIconToDraw.H), float(RIconToDraw.X), float(RIconToDraw.Y), float(RIconToDraw.W), float(RIconToDraw.H), m_TIcon);
	return;
}

//===============================================================================
// Refresh server info
//===============================================================================
function RefreshTeamBarInfo()
{
	local R6MissionObjectiveMgr moMgr;
	local float fMissionTime;
	local bool bPlayTestLog;
	local int i, iRainbowDead, iTerroNeutralized;
	local R6RainbowTeam CurrentTeam;
	local R6GameInfo GameInfo;

	m_iTotalNeutralized = 0;
	m_iTotalEfficiency = 0;
	m_iTotalRoundsFired = 0;
	m_iTotalRoundsTaken = 0;
	ClearListOfItem();
	AddItems();
	moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
	// End:0xC7
	if(__NFUN_154__(int(moMgr.m_eMissionObjectiveStatus), int(0)))
	{
		fMissionTime = __NFUN_175__(GetLevel().Level.TimeSeconds, R6GameInfo(GetLevel().Game).m_fRoundStartTime);		
	}
	else
	{
		bPlayTestLog = true;
		fMissionTime = __NFUN_175__(R6GameInfo(GetLevel().Game).m_fRoundEndTime, R6GameInfo(GetLevel().Game).m_fRoundStartTime);
	}
	m_TimeMissionValue.SetNewText(Class'Engine.Actor'.static.__NFUN_1520__(int(fMissionTime)), true);
	m_KillLabel.SetNewText(string(m_iTotalNeutralized), true);
	m_EfficiencyLabel.SetNewText(string(m_iTotalEfficiency), true);
	m_RoundsFiredLabel.SetNewText(string(m_iTotalRoundsFired), true);
	m_RoundsTakenLabel.SetNewText(string(m_iTotalRoundsTaken), true);
	// End:0x3E7
	if(bPlayTestLog)
	{
		GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);
		i = 0;
		J0x1DD:

		// End:0x232 [Loop If]
		if(__NFUN_150__(i, 3))
		{
			CurrentTeam = R6RainbowTeam(GameInfo.GetRainbowTeam(i));
			// End:0x228
			if(__NFUN_119__(CurrentTeam, none))
			{
				__NFUN_161__(iRainbowDead, CurrentTeam.m_iMembersLost);
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x1DD;
		}
		__NFUN_231__(__NFUN_112__("-PLAYTEST- ", R6Console(Root.Console).Master.m_StartGameInfo.m_MapName));
		__NFUN_231__(__NFUN_112__("-PLAYTEST- mode                 =", Root.Console.ViewportOwner.Actor.Level.GetGameTypeClassName(GameInfo.m_szGameTypeFlag)));
		__NFUN_231__(__NFUN_112__("-PLAYTEST- difficulty level     =", string(GameInfo.m_iDiffLevel)));
		__NFUN_231__(__NFUN_112__("-PLAYTEST- mission time length  =", m_TimeMissionValue.Text));
		__NFUN_231__(__NFUN_112__("-PLAYTEST- terro neutralized    =", string(m_iTotalNeutralized)));
		__NFUN_231__(__NFUN_112__("-PLAYTEST- rainbow killed       =", string(iRainbowDead)));
		__NFUN_231__(__NFUN_112__("-PLAYTEST- nb of retries        =", string(R6GameInfo(GetLevel().Game).m_iNbOfRestart)));
	}
	return;
}

function AddItems()
{
	local R6WindowListIGPlayerInfoItem NewItem;
	local int i, Y;
	local R6RainbowTeam CurrentTeam;
	local R6GameInfo GameInfo;

	GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);
	m_iTotalNeutralized = GameInfo.GetNbTerroNeutralized();
	i = 0;
	J0x59:

	// End:0x7A1 [Loop If]
	if(__NFUN_150__(i, 3))
	{
		CurrentTeam = R6RainbowTeam(GameInfo.GetRainbowTeam(i));
		// End:0x797
		if(__NFUN_119__(CurrentTeam, none))
		{
			Y = 0;
			J0x96:

			// End:0x797 [Loop If]
			if(__NFUN_150__(Y, __NFUN_146__(CurrentTeam.m_iMemberCount, CurrentTeam.m_iMembersLost)))
			{
				NewItem = R6WindowListIGPlayerInfoItem(m_IGPlayerInfoListBox.Items.Append(m_IGPlayerInfoListBox.ListClass));
				NewItem.m_iRainbowTeam = i;
				NewItem.stTagCoord[0].fXPos = 0.0000000;
				NewItem.stTagCoord[0].fWidth = m_fTeamcolorWidth;
				NewItem.szPlName = CurrentTeam.m_Team[Y].m_CharacterName;
				NewItem.stTagCoord[1].fXPos = __NFUN_174__(__NFUN_174__(NewItem.stTagCoord[0].fXPos, NewItem.stTagCoord[0].fWidth), float(m_INameTextPadding));
				NewItem.stTagCoord[1].fWidth = __NFUN_175__(m_fRainbowWidth, float(m_INameTextPadding));
				switch(CurrentTeam.m_Team[Y].m_eHealth)
				{
					// End:0x215
					case 0:
						NewItem.eStatus = NewItem.0;
						// End:0x27E
						break;
					// End:0x237
					case 1:
						NewItem.eStatus = NewItem.1;
						// End:0x27E
						break;
					// End:0x259
					case 2:
						NewItem.eStatus = NewItem.2;
						// End:0x27E
						break;
					// End:0x27B
					case 3:
						NewItem.eStatus = NewItem.3;
						// End:0x27E
						break;
					// End:0xFFFF
					default:
						break;
				}
				NewItem.stTagCoord[2].fXPos = __NFUN_174__(NewItem.stTagCoord[1].fXPos, NewItem.stTagCoord[1].fWidth);
				NewItem.stTagCoord[2].fWidth = m_fHealthWidth;
				NewItem.iKills = CurrentTeam.m_Team[Y].m_iKills;
				NewItem.stTagCoord[3].fXPos = __NFUN_174__(NewItem.stTagCoord[2].fXPos, NewItem.stTagCoord[2].fWidth);
				NewItem.stTagCoord[3].fWidth = m_fSkullWidth;
				// End:0x3EB
				if(__NFUN_151__(CurrentTeam.m_Team[Y].m_iBulletsFired, 0))
				{
					NewItem.iEfficiency = __NFUN_249__(int(__NFUN_171__(__NFUN_172__(float(CurrentTeam.m_Team[Y].m_iBulletsHit), float(CurrentTeam.m_Team[Y].m_iBulletsFired)), float(100))), 100);					
				}
				else
				{
					NewItem.iEfficiency = 0;
				}
				NewItem.stTagCoord[4].fXPos = __NFUN_174__(NewItem.stTagCoord[3].fXPos, NewItem.stTagCoord[3].fWidth);
				NewItem.stTagCoord[4].fWidth = m_fEfficiencyWidth;
				NewItem.iRoundsFired = CurrentTeam.m_Team[Y].m_iBulletsFired;
				NewItem.stTagCoord[5].fXPos = __NFUN_174__(NewItem.stTagCoord[4].fXPos, NewItem.stTagCoord[4].fWidth);
				NewItem.stTagCoord[5].fWidth = m_fShotsWidth;
				NewItem.iRoundsHit = CurrentTeam.m_Team[Y].m_iBulletsHit;
				NewItem.stTagCoord[6].fXPos = __NFUN_174__(NewItem.stTagCoord[5].fXPos, NewItem.stTagCoord[5].fWidth);
				NewItem.stTagCoord[6].fWidth = m_fHitsWidth;
				NewItem.m_iOperativeID = CurrentTeam.m_Team[Y].m_iOperativeID;
				__NFUN_161__(m_iTotalRoundsFired, NewItem.iRoundsFired);
				__NFUN_161__(m_iTotalRoundsTaken, NewItem.iRoundsHit);
				// End:0x78D
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("CurrentTeam = ", string(CurrentTeam)), " y = "), string(Y)));
					__NFUN_231__(__NFUN_168__("currentTeam.m_Team[y].m_CharacterName", CurrentTeam.m_Team[Y].m_CharacterName));
					__NFUN_231__(__NFUN_168__("currentTeam.m_Team[y].m_eHealth", string(CurrentTeam.m_Team[Y].m_eHealth)));
					__NFUN_231__(__NFUN_168__("currentTeam.m_Team[y]. m_iKills", string(CurrentTeam.m_Team[Y].m_iKills)));
					__NFUN_231__(__NFUN_168__("currentTeam.m_Team[y].m_iBulletsFired", string(CurrentTeam.m_Team[Y].m_iBulletsFired)));
					__NFUN_231__(__NFUN_168__("currentTeam.m_Team[y].m_iBulletsHit", string(CurrentTeam.m_Team[Y].m_iBulletsHit)));
					__NFUN_231__(__NFUN_168__("NewItem.iEfficiency", string(NewItem.iEfficiency)));
				}
				__NFUN_165__(Y);
				// [Loop Continue]
				goto J0x96;
			}
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x59;
	}
	// End:0x7B6
	if(__NFUN_154__(m_iTotalRoundsFired, 0))
	{
		m_iTotalEfficiency = 0;		
	}
	else
	{
		m_iTotalEfficiency = __NFUN_249__(int(__NFUN_171__(__NFUN_172__(float(m_iTotalRoundsTaken), float(m_iTotalRoundsFired)), float(100))), 100);
	}
	return;
}

function Register(UWindowDialogClientWindow W)
{
	NotifyWindow = W;
	Notify(0);
	m_IGPlayerInfoListBox.Register(W);
	return;
}

function ClearListOfItem()
{
	m_IGPlayerInfoListBox.Items.Clear();
	return;
}

//===============================================================================
// Get the total height of the header ALPHA TEAM and TOTAL TEAM STATUS
//===============================================================================
function float GetPlayerListBorderHeight()
{
	return __NFUN_174__(__NFUN_174__(__NFUN_174__(16.0000000, float(m_IFirstItempYOffset)), float(14)), float(15));
	return;
}

function CreateIGPListBox()
{
	m_IGPlayerInfoListBox = R6WindowSimpleIGPlayerListBox(CreateWindow(Class'R6Window.R6WindowSimpleIGPlayerListBox', 0.0000000, __NFUN_174__(16.0000000, float(m_IFirstItempYOffset)), WinWidth, __NFUN_175__(WinHeight, GetPlayerListBorderHeight()), self));
	m_IGPlayerInfoListBox.SetCornerType(1);
	m_IGPlayerInfoListBox.m_Font = Root.Fonts[11];
	return;
}

function Resize()
{
	m_IGPlayerInfoListBox.WinTop = __NFUN_174__(16.0000000, float(m_IFirstItempYOffset));
	m_IGPlayerInfoListBox.SetSize(WinWidth, __NFUN_175__(WinHeight, GetPlayerListBorderHeight()));
	m_TimeMissionTitle.WinWidth = m_fBottomTitleWidth;
	m_TimeMissionValue.WinLeft = m_TimeMissionTitle.WinWidth;
	m_TimeMissionValue.WinWidth = __NFUN_175__(WinWidth, m_TimeMissionTitle.WinWidth);
	m_BottomTitle.WinWidth = m_fBottomTitleWidth;
	m_KillLabel.WinWidth = m_fSkullWidth;
	m_KillLabel.WinLeft = __NFUN_174__(m_BottomTitle.WinLeft, m_BottomTitle.WinWidth);
	m_EfficiencyLabel.WinWidth = m_fEfficiencyWidth;
	m_EfficiencyLabel.WinLeft = __NFUN_174__(m_KillLabel.WinLeft, m_KillLabel.WinWidth);
	m_RoundsFiredLabel.WinWidth = m_fShotsWidth;
	m_RoundsFiredLabel.WinLeft = __NFUN_174__(m_EfficiencyLabel.WinLeft, m_EfficiencyLabel.WinWidth);
	m_RoundsTakenLabel.WinWidth = m_fHitsWidth;
	m_RoundsTakenLabel.WinLeft = __NFUN_174__(m_RoundsFiredLabel.WinLeft, m_RoundsFiredLabel.WinWidth);
	m_TimeMissionTitle.WinWidth = m_fBottomTitleWidth;
	m_TimeMissionTitle.m_bRefresh = true;
	m_BottomTitle.WinWidth = m_fBottomTitleWidth;
	m_BottomTitle.m_bRefresh = true;
	return;
}

defaultproperties
{
	m_IBorderVOffset=2
	m_INameTextPadding=2
	m_fBottomTitleWidth=210.0000000
	m_fTeamcolorWidth=30.0000000
	m_fRainbowWidth=145.0000000
	m_fHealthWidth=35.0000000
	m_fSkullWidth=50.0000000
	m_fEfficiencyWidth=50.0000000
	m_fShotsWidth=50.0000000
	m_fHitsWidth=50.0000000
	m_TIcon=Texture'R6MenuTextures.Credits.TeamBarIcon'
	m_TBorder=Texture'UWindow.WhiteTexture'
	m_THighLight=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RBorder=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=290,ZoneNumber=0)
	m_RHighLight=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19234,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var l
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var h
