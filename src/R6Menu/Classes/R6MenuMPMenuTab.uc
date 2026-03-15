//=============================================================================
// R6MenuMPMenuTab - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPMenuTab.uc : All the tab menu were define overhere
//                       You can choose only one of the 3 possible settings!!!!
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/5  * Create by Yannick Joly
//=============================================================================
class R6MenuMPMenuTab extends UWindowDialogClientWindow;

const K_HALFWINDOWWIDTH = 310;
const K_FSECOND_WINDOWHEIGHT = 90;
const C_fGM_COLUMNSWIDTH = 155;
const C_fXPOS_LASTPOS = 419;

// GAME MODE TAB
var R6WindowTextLabelExt m_pGameModeText;
var R6WindowButtonBox m_pGameTypeDeadMatch;
var R6WindowButtonBox m_pGameTypeTDeadMatch;
var R6WindowButtonBox m_pGameTypeDisarmBomb;
var R6WindowButtonBox m_pGameTypeHostageAdv;
var R6WindowButtonBox m_pGameTypeEscort;
var R6WindowButtonBox m_pGameTypeMission;
var R6WindowButtonBox m_pGameTypeTerroHunt;
var R6WindowButtonBox m_pGameTypeHostageCoop;
// FILTER TAB
var R6WindowTextLabelExt m_pFilterText;
var R6WindowButtonBox m_pFilterUnlock;
var R6WindowButtonBox m_pFilterFavorites;
var R6WindowButtonBox m_pFilterDedicated;
//#ifdefR6PUNKBUSTER
var R6WindowButtonBox m_pFilterPunkBuster;
//#endif
var R6WindowButtonBox m_pFilterNotEmpty;
var R6WindowButtonBox m_pFilterNotFull;
var R6WindowButtonBox m_pFilterResponding;
var R6WindowButtonBox m_pFilterSameVersion;
var R6WindowComboControl m_pFilterFasterThan;
// SERVER INFO TAB
var R6WindowTextLabelExt m_pServerInfo;

//*******************************************************************************************
// GAME MODE TAB
//*******************************************************************************************
function UpdateGameTypeFilter()
{
	local R6MenuMultiPlayerWidget Menu;

	Menu = R6MenuMultiPlayerWidget(OwnerWindow);
	// End:0x113
	if((m_pGameTypeDeadMatch != none))
	{
		m_pGameTypeDeadMatch.m_bSelected = Menu.m_bFilterDeathMatch;
		m_pGameTypeTDeadMatch.m_bSelected = Menu.m_bFilterTeamDeathMatch;
		m_pGameTypeDisarmBomb.m_bSelected = Menu.m_bFilterDisarmBomb;
		m_pGameTypeHostageAdv.m_bSelected = Menu.m_bFilterHostageRescueAdv;
		m_pGameTypeEscort.m_bSelected = Menu.m_bFilterEscortPilot;
		m_pGameTypeMission.m_bSelected = Menu.m_bFilterMission;
		m_pGameTypeTerroHunt.m_bSelected = Menu.m_bFilterTerroristHunt;
		m_pGameTypeHostageCoop.m_bSelected = Menu.m_bFilterHostageRescueCoop;
	}
	// End:0x216
	if((m_pFilterResponding != none))
	{
		m_pFilterResponding.m_bSelected = Menu.m_bFilterResponding;
		m_pFilterUnlock.m_bSelected = Menu.m_bFilterUnlockedOnly;
		m_pFilterFavorites.m_bSelected = Menu.m_bFilterFavoritesOnly;
		m_pFilterDedicated.m_bSelected = Menu.m_bFilterDedicatedServersOnly;
		m_pFilterPunkBuster.m_bSelected = Menu.m_bFilterPunkBusterServerOnly;
		m_pFilterNotEmpty.m_bSelected = Menu.m_bFilterServersNotEmpty;
		m_pFilterNotFull.m_bSelected = Menu.m_bFilterServersNotFull;
		m_pFilterSameVersion.m_bSelected = Menu.m_bFilterSameVersion;
	}
	return;
}

function InitGameModeTab()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;

	m_pGameModeText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, (2.0000000 * float(310)), 90.0000000, self));
	m_pGameModeText.bAlwaysBehind = true;
	m_pGameModeText.ActiveBorder(0, false);
	m_pGameModeText.ActiveBorder(1, false);
	m_pGameModeText.SetBorderParam(2, (155.0000000 * float(2)), 1.0000000, 1.0000000, Root.Colors.White);
	m_pGameModeText.m_Font = Root.Fonts[5];
	m_pGameModeText.m_vTextColor = Root.Colors.BlueLight;
	m_pGameModeText.AddTextLabel(Caps(Localize("MultiPlayer", "GameMode_Adversarial", "R6Menu")), 5.0000000, 3.0000000, (155.0000000 * float(2)), 0, false);
	m_pGameModeText.AddTextLabel(Caps(Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu")), (5.0000000 + float((155 * 2))), 3.0000000, (155.0000000 * float(2)), 0, false);
	fXOffset = 5.0000000;
	fYOffset = 20.0000000;
	fYStep = 25.0000000;
	fWidth = 155.0000000;
	fHeight = 14.0000000;
	ButtonFont = Root.Fonts[17];
	m_pGameTypeDeadMatch = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeDeadMatch.m_TextFont = ButtonFont;
	m_pGameTypeDeadMatch.m_vTextColor = Root.Colors.White;
	m_pGameTypeDeadMatch.m_vBorder = Root.Colors.White;
	m_pGameTypeDeadMatch.CreateTextAndBox(Localize("MultiPlayer", "GameType_Death", "R6Menu"), Localize("Tip", "SrvGameType_Death", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).0));
	(fYOffset += fYStep);
	m_pGameTypeTDeadMatch = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeTDeadMatch.m_TextFont = ButtonFont;
	m_pGameTypeTDeadMatch.m_vTextColor = Root.Colors.White;
	m_pGameTypeTDeadMatch.m_vBorder = Root.Colors.White;
	m_pGameTypeTDeadMatch.CreateTextAndBox(Localize("MultiPlayer", "GameType_TeamDeath", "R6Menu"), Localize("Tip", "SrvGameType_TeamDeath", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).1));
	(fYOffset += fYStep);
	m_pGameTypeDisarmBomb = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeDisarmBomb.m_TextFont = ButtonFont;
	m_pGameTypeDisarmBomb.m_vTextColor = Root.Colors.White;
	m_pGameTypeDisarmBomb.m_vBorder = Root.Colors.White;
	m_pGameTypeDisarmBomb.CreateTextAndBox(Localize("MultiPlayer", "GameType_DisarmBomb", "R6Menu"), Localize("Tip", "SrvGameType_DisarmBomb", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).2));
	fXOffset = (10.0000000 + float(155));
	fYOffset = 20.0000000;
	(fWidth -= float(20));
	m_pGameTypeHostageAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeHostageAdv.m_TextFont = ButtonFont;
	m_pGameTypeHostageAdv.m_vTextColor = Root.Colors.White;
	m_pGameTypeHostageAdv.m_vBorder = Root.Colors.White;
	m_pGameTypeHostageAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_HostageAdv", "R6Menu"), Localize("Tip", "SrvGameType_HostageAdv", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).3));
	(fYOffset += fYStep);
	m_pGameTypeEscort = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeEscort.m_TextFont = ButtonFont;
	m_pGameTypeEscort.m_vTextColor = Root.Colors.White;
	m_pGameTypeEscort.m_vBorder = Root.Colors.White;
	m_pGameTypeEscort.CreateTextAndBox(Localize("MultiPlayer", "GameType_EscortGeneral", "R6Menu"), Localize("Tip", "SrvGameType_EscortGeneral", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).4));
	fXOffset = (5.0000000 + float((155 * 2)));
	fYOffset = 20.0000000;
	m_pGameTypeMission = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeMission.m_TextFont = ButtonFont;
	m_pGameTypeMission.m_vTextColor = Root.Colors.White;
	m_pGameTypeMission.m_vBorder = Root.Colors.White;
	m_pGameTypeMission.CreateTextAndBox(Localize("MultiPlayer", "GameType_Mission", "R6Menu"), Localize("Tip", "SrvGameType_Mission", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).5));
	(fYOffset += fYStep);
	m_pGameTypeTerroHunt = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeTerroHunt.m_TextFont = ButtonFont;
	m_pGameTypeTerroHunt.m_vTextColor = Root.Colors.White;
	m_pGameTypeTerroHunt.m_vBorder = Root.Colors.White;
	m_pGameTypeTerroHunt.CreateTextAndBox(Localize("MultiPlayer", "GameType_Terrorist", "R6Menu"), Localize("Tip", "SrvGameType_Terrorist", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).6));
	fXOffset = (5.0000000 + float((155 * 3)));
	fYOffset = 20.0000000;
	m_pGameTypeHostageCoop = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pGameTypeHostageCoop.m_TextFont = ButtonFont;
	m_pGameTypeHostageCoop.m_vTextColor = Root.Colors.White;
	m_pGameTypeHostageCoop.m_vBorder = Root.Colors.White;
	m_pGameTypeHostageCoop.CreateTextAndBox(Localize("MultiPlayer", "GameType_HostageCoop", "R6Menu"), Localize("Tip", "SrvGameType_HostageCoop", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).7));
	UpdateGameTypeFilter();
	return;
}

//*******************************************************************************************
// FILTER TAB
//*******************************************************************************************
function InitFilterTab()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

	local Font ButtonFont;

	m_pFilterText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, (2.0000000 * float(310)), 90.0000000, self));
	m_pFilterText.bAlwaysBehind = true;
	m_pFilterText.ActiveBorder(0, false);
	m_pFilterText.ActiveBorder(1, false);
	m_pFilterText.SetBorderParam(2, 310.0000000, 1.0000000, 1.0000000, Root.Colors.GrayLight);
	m_pFilterText.ActiveBorder(3, false);
	fXOffset = 5.0000000;
	fYOffset = 7.0000000;
	fYStep = 16.0000000;
	fWidth = ((310.0000000 - fXOffset) - float(30));
	fHeight = 14.0000000;
	ButtonFont = Root.Fonts[17];
	m_pFilterText.m_Font = ButtonFont;
	m_pFilterText.m_vTextColor = Root.Colors.White;
	m_pFilterFavorites = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterFavorites.m_TextFont = ButtonFont;
	m_pFilterFavorites.m_vTextColor = Root.Colors.White;
	m_pFilterFavorites.m_vBorder = Root.Colors.White;
	m_pFilterFavorites.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Favorites", "R6Menu"), Localize("Tip", "FilterMode_Favorites", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).11));
	(fYOffset += fYStep);
	m_pFilterUnlock = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterUnlock.m_TextFont = ButtonFont;
	m_pFilterUnlock.m_vTextColor = Root.Colors.White;
	m_pFilterUnlock.m_vBorder = Root.Colors.White;
	m_pFilterUnlock.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Unlocked", "R6Menu"), Localize("Tip", "FilterMode_Unlocked", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).10));
	(fYOffset += fYStep);
	m_pFilterDedicated = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterDedicated.m_TextFont = ButtonFont;
	m_pFilterDedicated.m_vTextColor = Root.Colors.White;
	m_pFilterDedicated.m_vBorder = Root.Colors.White;
	m_pFilterDedicated.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Dedicate", "R6Menu"), Localize("Tip", "FilterMode_Dedicate", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).12));
	(fYOffset += fYStep);
	m_pFilterPunkBuster = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterPunkBuster.m_TextFont = ButtonFont;
	m_pFilterPunkBuster.m_vTextColor = Root.Colors.White;
	m_pFilterPunkBuster.m_vBorder = Root.Colors.White;
	m_pFilterPunkBuster.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_PunkBuster", "R6Menu"), Localize("Tip", "FilterMode_PunkBuster", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).13));
	(fYOffset += fYStep);
	m_pFilterNotEmpty = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterNotEmpty.m_TextFont = ButtonFont;
	m_pFilterNotEmpty.m_vTextColor = Root.Colors.White;
	m_pFilterNotEmpty.m_vBorder = Root.Colors.White;
	m_pFilterNotEmpty.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_NotEmpty", "R6Menu"), Localize("Tip", "FilterMode_NotEmpty", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).14));
	fXOffset = (5.0000000 + float(310));
	fYOffset = 7.0000000;
	fYStep = 16.0000000;
	m_pFilterNotFull = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterNotFull.m_TextFont = ButtonFont;
	m_pFilterNotFull.m_vTextColor = Root.Colors.White;
	m_pFilterNotFull.m_vBorder = Root.Colors.White;
	m_pFilterNotFull.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_NotFull", "R6Menu"), Localize("Tip", "FilterMode_NotFull", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).15));
	(fYOffset += fYStep);
	m_pFilterSameVersion = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterSameVersion.m_TextFont = ButtonFont;
	m_pFilterSameVersion.m_vTextColor = Root.Colors.White;
	m_pFilterSameVersion.m_vBorder = Root.Colors.White;
	m_pFilterSameVersion.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_SameVersion", "R6Menu"), Localize("Tip", "FilterMode_SameVersion", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).18));
	(fYOffset += fYStep);
	m_pFilterResponding = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pFilterResponding.m_TextFont = ButtonFont;
	m_pFilterResponding.m_vTextColor = Root.Colors.White;
	m_pFilterResponding.m_vBorder = Root.Colors.White;
	m_pFilterResponding.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Respond", "R6Menu"), Localize("Tip", "FilterMode_Respond", "R6Menu"), 0.0000000, int(R6MenuMultiPlayerWidget(OwnerWindow).16));
	(fYOffset += fYStep);
	m_pFilterText.AddTextLabel(Localize("MultiPlayer", "FilterMode_FasterThan", "R6Menu"), fXOffset, (fYOffset + float(2)), 150.0000000, 0, false);
	fXOffset = (310.0000000 + float(115));
	fWidth = 165.0000000;
	m_pFilterFasterThan = R6WindowComboControl(CreateControl(Class'R6Window.R6WindowComboControl', fXOffset, fYOffset, fWidth, fHeight));
	m_pFilterFasterThan.SetEditBoxTip(Localize("Tip", "FilterMode_FasterThan", "R6Menu"));
	m_pFilterFasterThan.EditBoxWidth = m_pFilterFasterThan.WinWidth;
	m_pFilterFasterThan.SetFont(6);
	m_pFilterFasterThan.List.MaxVisible = 4;
	m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThanNone", "R6Menu")));
	m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan75", "R6Menu")));
	m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan100", "R6Menu")));
	m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan250", "R6Menu")));
	m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan350", "R6Menu")));
	m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan500", "R6Menu")));
	m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan1000", "R6Menu")));
	switch(R6MenuMultiPlayerWidget(OwnerWindow).m_iFilterFasterThan)
	{
		// End:0xD80
		case 75:
			m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan75", "R6Menu")));
			// End:0xF6F
			break;
		// End:0xDCE
		case 100:
			m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan100", "R6Menu")));
			// End:0xF6F
			break;
		// End:0xE1C
		case 250:
			m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan250", "R6Menu")));
			// End:0xF6F
			break;
		// End:0xE6D
		case 350:
			m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan350", "R6Menu")));
			// End:0xF6F
			break;
		// End:0xEBE
		case 500:
			m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan500", "R6Menu")));
			// End:0xF6F
			break;
		// End:0xF10
		case 1000:
			m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan1000", "R6Menu")));
			// End:0xF6F
			break;
		// End:0xFFFF
		default:
			R6MenuMultiPlayerWidget(OwnerWindow).m_iFilterFasterThan = 0;
			m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThanNone", "R6Menu")));
			break;
	}
	return;
}

//*******************************************************************************************
// SERVER INFO TAB
//*******************************************************************************************
function InitServerTab()
{
	local float fWidth, fPreviousPos;

	fWidth = 91.0000000;
	fPreviousPos = 0.0000000;
	m_pServerInfo = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, WinWidth, 12.0000000, self));
	m_pServerInfo.ActiveBorder(0, false);
	m_pServerInfo.SetBorderParam(1, 2.0000000, 0.0000000, 1.0000000, Root.Colors.White);
	m_pServerInfo.ActiveBorder(2, false);
	m_pServerInfo.ActiveBorder(3, false);
	m_pServerInfo.m_eCornerType = 0;
	m_pServerInfo.m_Font = Root.Fonts[6];
	m_pServerInfo.m_vTextColor = Root.Colors.BlueLight;
	m_pServerInfo.m_vLineColor = Root.Colors.White;
	m_pServerInfo.AddTextLabel(Localize("MultiPlayer", "InfoBar_Name", "R6Menu"), fPreviousPos, 0.0000000, fWidth, 2, true);
	(fPreviousPos += fWidth);
	fWidth = 40.0000000;
	m_pServerInfo.AddTextLabel(Localize("MultiPlayer", "InfoBar_Kills", "R6Menu"), fPreviousPos, 0.0000000, fWidth, 2, true);
	(fPreviousPos += fWidth);
	fWidth = 50.0000000;
	m_pServerInfo.AddTextLabel(Localize("MultiPlayer", "InfoBar_Time", "R6Menu"), fPreviousPos, 0.0000000, fWidth, 2, true);
	(fPreviousPos += fWidth);
	fWidth = 50.0000000;
	m_pServerInfo.AddTextLabel(Localize("MultiPlayer", "InfoBar_Ping", "R6Menu"), fPreviousPos, 0.0000000, fWidth, 2, true);
	(fPreviousPos += fWidth);
	fWidth = 82.0000000;
	m_pServerInfo.AddTextLabel(Localize("MultiPlayer", "InfoBar_MapList", "R6Menu"), fPreviousPos, 0.0000000, fWidth, 2, true);
	(fPreviousPos += fWidth);
	fWidth = 92.0000000;
	m_pServerInfo.AddTextLabel(Localize("MultiPlayer", "InfoBar_Type", "R6Menu"), fPreviousPos, 0.0000000, fWidth, 2, true);
	(fPreviousPos += fWidth);
	fWidth = 150.0000000;
	m_pServerInfo.AddTextLabel(Localize("MultiPlayer", "InfoBar_ServerOptions", "R6Menu"), fPreviousPos, 0.0000000, fWidth, 2, true);
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x27
	if(C.IsA('R6WindowComboControl'))
	{
		ManageR6ComboControlNotify(C, E);		
	}
	else
	{
		// End:0x4B
		if(C.__NFUN_303__('R6WindowButtonBox'))
		{
			ManageR6ButtonBoxNotify(C, E);
		}
	}
	return;
}

//-------------------------------------------------------------------------
// ManageR6ComboControlNotify - Notify function for classes of
// type 'R6WindowComboControl'
//-------------------------------------------------------------------------
function ManageR6ComboControlNotify(UWindowDialogControl C, byte E)
{
	// End:0x37
	if(__NFUN_154__(int(E), 1))
	{
		R6MenuMultiPlayerWidget(OwnerWindow).SetServerFilterFasterThan(int(R6WindowComboControl(C).GetValue()));
	}
	return;
}

//-------------------------------------------------------------------------
// ManageR6ButtonBoxNotify - Notify function for classes of
// type 'R6WindowButtonBox'
//-------------------------------------------------------------------------
function ManageR6ButtonBoxNotify(UWindowDialogControl C, byte E)
{
	// End:0x9B
	if(__NFUN_154__(int(E), 2))
	{
		// End:0x9B
		if(R6WindowButtonBox(C).GetSelectStatus())
		{
			R6WindowButtonBox(C).m_bSelected = __NFUN_129__(R6WindowButtonBox(C).m_bSelected);
			// End:0x9B
			if(__NFUN_119__(R6MenuMultiPlayerWidget(OwnerWindow), none))
			{
				R6MenuMultiPlayerWidget(OwnerWindow).SetServerFilterBooleans(R6WindowButtonBox(C).m_iButtonID, R6WindowButtonBox(C).m_bSelected);
			}
		}
	}
	return;
}

