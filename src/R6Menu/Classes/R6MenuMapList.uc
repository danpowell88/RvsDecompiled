//=============================================================================
// R6MenuMapList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMapList.uc : This menu display the map and the map list window and manage
//                     all the operations between the two window (+ the button in center)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/02  * Create by Yannick Joly
//=============================================================================
class R6MenuMapList extends UWindowDialogClientWindow;

const C_fX_START_TEXT = 5;
const C_fX_START_MAPLIST = 7;
const C_fY_START_MAPLIST = 16;
const C_fWIDTH_OF_MAPLIST = 135;
const C_fHEIGHT_OF_MAPLIST = 115;
const C_fX_ButPos = 148;
const C_fY_ButPos = 67;
const C_iMAX_MAPLIST_SIZE = 32;

var Actor.EGameModeInfo m_eMyGameMode;  // the game mode of the map list
var int m_iTextIndex;  // only to refresh game mode
var bool m_bFromStartList;  // you come from Start list -- for color effect window!
var bool m_bInGame;
var R6WindowTextLabelExt m_pTextInfo;  // the text info in background
var R6WindowTextListBoxExt m_pStartMapList;
var R6WindowTextListBoxExt m_pFinalMapList;
var R6WindowComboControl m_pGameTypeCombo;  // the combo control for game type
var Texture m_pButtonTexture;
var UWindowButton m_pSelectButton;
var UWindowButton m_pSubButton;  // the substract button
var UWindowButton m_pPlusButton;  // the adding button
var Region m_RArrowUp;  // the region of the arrow button for map list
var Region m_RArrowDown;  // the region of the arrow button for map list
var Region m_RArrowDisabled;  // the region of the arrow button for map list
var Region m_RArrowOver;  // the region of the arrow button for map list
var string m_szLocGameMode;  // the game mode selected (Adversarial, Cooperative, etc)v

function Created()
{
	local UWindowListBoxItem CurItem;
	local float fXOffset, fYOffset, fWidth, fXSecondWindow;

	fXSecondWindow = ((WinWidth - float(7)) - float(135));
	m_pTextInfo = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, WinWidth, WinHeight, self));
	m_pTextInfo.bAlwaysBehind = true;
	m_pTextInfo.SetNoBorder();
	m_pTextInfo.m_Font = Root.Fonts[5];
	m_pTextInfo.m_vTextColor = Root.Colors.White;
	fXOffset = 5.0000000;
	fYOffset = 0.0000000;
	fWidth = 135.0000000;
	m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_Map", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = fXSecondWindow;
	m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_MapList", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = 5.0000000;
	fYOffset = ((16.0000000 + float(115)) + float(5));
	m_pTextInfo.m_Font = Root.Fonts[6];
	m_iTextIndex = m_pTextInfo.AddTextLabel(((m_szLocGameMode $ " ") $ Localize("MPCreateGame", "Options_GameType", "R6Menu")), fXOffset, fYOffset, (fXSecondWindow - fXOffset), 0, false);
	m_pStartMapList = R6WindowTextListBoxTest(CreateControl(Class'R6Window.R6WindowTextListBoxTest', 7.0000000, 16.0000000, 135.0000000, 115.0000000, self));
	m_pStartMapList.TextColor = Root.Colors.BlueLight;
	m_pStartMapList.SetCornerType(0);
	m_pStartMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
	m_pStartMapList.ToolTipString = Localize("Tip", "Options_Map", "R6Menu");
	m_pFinalMapList = R6WindowTextListBoxTest(CreateControl(Class'R6Window.R6WindowTextListBoxTest', fXSecondWindow, 16.0000000, 135.0000000, 115.0000000, self));
	m_pFinalMapList.TextColor = Root.Colors.BlueLight;
	m_pFinalMapList.SetCornerType(0);
	m_pFinalMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
	m_pFinalMapList.ToolTipString = Localize("Tip", "Options_MapList", "R6Menu");
	m_pSelectButton = UWindowButton(CreateControl(Class'UWindow.UWindowButton', 148.0000000, 67.0000000, 13.0000000, 13.0000000, self));
	m_pSelectButton.m_bDrawButtonBorders = true;
	SetButtonRegion(true);
	m_pSelectButton.ToolTipString = Localize("Tip", "Options_MapListAddRemove", "R6Menu");
	fYOffset = ((16.0000000 + float(115)) + float(5));
	m_pGameTypeCombo = R6WindowComboControl(CreateControl(Class'R6Window.R6WindowComboControl', fXSecondWindow, fYOffset, fWidth, LookAndFeel.Size_ComboHeight));
	m_pGameTypeCombo.SetFont(6);
	m_pGameTypeCombo.SetEditBoxTip(Localize("Tip", "Options_MapListGameType", "R6Menu"));
	CreateButtons();
	return;
}

function CreateButtons()
{
	local Region RDisableRegion, RNormalRegion, ROverRegion;
	local float fHeight, fButtonWidth, fButtonHeight;

	RNormalRegion.X = 0;
	RNormalRegion.Y = 0;
	RNormalRegion.W = 11;
	RNormalRegion.H = 8;
	RDisableRegion.X = 0;
	RDisableRegion.Y = 16;
	RDisableRegion.W = 11;
	RDisableRegion.H = 8;
	ROverRegion.X = 0;
	ROverRegion.Y = 8;
	ROverRegion.W = 11;
	ROverRegion.H = 8;
	fButtonWidth = 13.0000000;
	fButtonHeight = 12.0000000;
	fHeight = ((m_pSelectButton.WinTop - fButtonHeight) - float(10));
	m_pSubButton = UWindowButton(CreateControl(Class'UWindow.UWindowButton', 148.0000000, fHeight, fButtonWidth, fButtonHeight, self));
	m_pSubButton.m_bDrawButtonBorders = true;
	m_pSubButton.bUseRegion = true;
	m_pSubButton.DownTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.DownRegion = RDisableRegion;
	m_pSubButton.OverTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.OverRegion = ROverRegion;
	m_pSubButton.UpTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.UpRegion = RNormalRegion;
	m_pSubButton.DisabledTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.DisabledRegion = RDisableRegion;
	m_pSubButton.ImageX = 1.0000000;
	m_pSubButton.ImageY = 2.0000000;
	RNormalRegion.X = 0;
	RNormalRegion.Y = 8;
	RNormalRegion.W = 11;
	RNormalRegion.H = -8;
	RDisableRegion.X = 0;
	RDisableRegion.Y = 24;
	RDisableRegion.W = 11;
	RDisableRegion.H = -8;
	ROverRegion.X = 0;
	ROverRegion.Y = 16;
	ROverRegion.W = 11;
	ROverRegion.H = -8;
	fHeight = ((m_pSelectButton.WinTop + m_pSelectButton.WinHeight) + float(10));
	m_pPlusButton = UWindowButton(CreateControl(Class'UWindow.UWindowButton', 148.0000000, fHeight, fButtonWidth, fButtonHeight, self));
	m_pPlusButton.m_bDrawButtonBorders = true;
	m_pPlusButton.bUseRegion = true;
	m_pPlusButton.DownTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.DownRegion = RDisableRegion;
	m_pPlusButton.OverTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.OverRegion = ROverRegion;
	m_pPlusButton.UpTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.UpRegion = RNormalRegion;
	m_pPlusButton.DisabledTexture = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.DisabledRegion = RDisableRegion;
	m_pPlusButton.ImageX = 1.0000000;
	m_pPlusButton.ImageY = 2.0000000;
	SetOrderButtons(true);
	return;
}

/////////////////////////////////////////////////////////////////
// Fill the map window text list box
/////////////////////////////////////////////////////////////////
function FillMapListItem()
{
	local R6WindowListBoxItem NewItem;
	local int i, j;
	local string szLocMapName;
	local R6Console R6Console;
	local R6MissionDescription mission;
	local LevelInfo pLevel;
	local string szMod, szRavenShieldMod;
	local bool bLoadMap;

	pLevel = GetLevel();
	R6Console = R6Console(Root.Console);
	m_pStartMapList.Items.Clear();
	szMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
	szRavenShieldMod = Class'Engine.Actor'.static.GetModMgr().m_pRVS.m_szKeyWord;
	i = 0;
	J0x8C:

	// End:0x225 [Loop If]
	if((i < R6Console.m_aMissionDescriptions.Length))
	{
		mission = R6Console.m_aMissionDescriptions[i];
		// End:0x21B
		if((mission.m_MapName != ""))
		{
			j = 0;
			J0xDB:

			// End:0x21B [Loop If]
			if((j < mission.m_szGameTypes.Length))
			{
				bLoadMap = false;
				// End:0x11F
				if((szMod ~= mission.mod))
				{
					bLoadMap = true;					
				}
				else
				{
					// End:0x13F
					if((mission.mod ~= szRavenShieldMod))
					{
						bLoadMap = true;
					}
				}
				// End:0x211
				if((bLoadMap && pLevel.IsGameTypeMultiplayer(mission.m_szGameTypes[j], true)))
				{
					NewItem = R6WindowListBoxItem(m_pStartMapList.Items.Append(m_pStartMapList.ListClass));
					// End:0x1DD
					if((!Root.GetMapNameLocalisation(mission.m_MapName, szLocMapName)))
					{
						szLocMapName = mission.m_MapName;
					}
					NewItem.HelpText = szLocMapName;
					NewItem.m_szMisc = mission.m_MapName;
					// [Explicit Break]
					goto J0x21B;
				}
				(j++);
				// [Loop Continue]
				goto J0xDB;
			}
		}
		J0x21B:

		(++i);
		// [Loop Continue]
		goto J0x8C;
	}
	m_pStartMapList.Items.Sort();
	return;
}

//===================================================================================================
// GetNewServerProfileGameMode: 
//===================================================================================================
function string GetNewServerProfileGameMode(optional bool _bInGame)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local string szResult;
	local R6ServerInfo pServerOpt;
	local R6GameReplicationInfo _GRI;

	szResult = string(GetPlayerOwner().3);
	// End:0x89
	if(_bInGame)
	{
		r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
		_GRI = R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo);
		// End:0x86
		if((_GRI != none))
		{
			szResult = GetGameModeFromList(GetLevel().GetGameTypeFromClassName(_GRI.m_gameModeArray[0]));
		}		
	}
	else
	{
		pServerOpt = Class'Engine.Actor'.static.GetServerOptions();
		// End:0xE4
		if((pServerOpt.m_ServerMapList != none))
		{
			szResult = GetGameModeFromList(GetLevel().GetGameTypeFromClassName(pServerOpt.m_ServerMapList.GameType[0]));
		}
	}
	return szResult;
	return;
}

function string GetGameModeFromList(string _szGameType)
{
	local string szResult;

	szResult = string(GetPlayerOwner().3);
	// End:0x40
	if(GetLevel().IsGameTypeCooperative(_szGameType))
	{
		szResult = string(GetPlayerOwner().2);
	}
	return szResult;
	return;
}

// NEW IN 1.60
function bool IsFinalMapListEmpty()
{
	// End:0x0D
	if((m_pFinalMapList == none))
	{
		return false;
	}
	return (m_pFinalMapList.Items.Count() == 0);
	return;
}

//===================================================================================================
// FillFinalMapList: Fill the map list according the list give by the serveroptions --> from "server".ini
//===================================================================================================
function string FillFinalMapList()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local UWindowListBoxItem NewItem;
	local int i;
	local string szGameType, szResult, szTemp;
	local R6ServerInfo pServerOpt;
	local LevelInfo pLevel;

	pServerOpt = Class'Engine.Actor'.static.GetServerOptions();
	pLevel = GetLevel();
	m_pFinalMapList.Items.Clear();
	// End:0x6B
	if((pServerOpt.m_ServerMapList == none))
	{
		pServerOpt.m_ServerMapList = GetPlayerOwner().Spawn(Class'Engine.R6MapList');
	}
	i = 0;
	J0x72:

	// End:0x334 [Loop If]
	if(((i < 32) && (pServerOpt.m_ServerMapList.Maps[i] != "")))
	{
		szGameType = pLevel.GetGameTypeFromClassName(pServerOpt.m_ServerMapList.GameType[i]);
		szTemp = GetGameModeFromList(szGameType);
		// End:0x142
		if((int(m_eMyGameMode) == int(GetPlayerOwner().3)))
		{
			// End:0x134
			if((!pLevel.IsGameTypeAdversarial(szGameType)))
			{
				// End:0x131
				if((szResult == ""))
				{
					szResult = szTemp;
				}
				// [Explicit Continue]
				goto J0x32A;
			}
			szResult = szTemp;			
		}
		else
		{
			// End:0x19D
			if((int(m_eMyGameMode) == int(GetPlayerOwner().2)))
			{
				// End:0x18F
				if((!pLevel.IsGameTypeCooperative(szGameType)))
				{
					// End:0x18C
					if((szResult == ""))
					{
						szResult = szTemp;
					}
					// [Explicit Continue]
					goto J0x32A;
				}
				szResult = szTemp;				
			}
			else
			{
				// [Explicit Continue]
				goto J0x32A;
			}
		}
		// End:0x224
		if((!Root.GetMapNameLocalisation(pServerOpt.m_ServerMapList.Maps[i], szTemp)))
		{
			// End:0x201
			if((!FindMapInStartMapList(pServerOpt.m_ServerMapList.Maps[i])))
			{
				// [Explicit Continue]
				goto J0x32A;
			}
			szTemp = pServerOpt.m_ServerMapList.Maps[i];
		}
		NewItem = UWindowListBoxItem(m_pFinalMapList.Items.Append(m_pFinalMapList.ListClass));
		NewItem.HelpText = szTemp;
		R6WindowListBoxItem(NewItem).m_szMisc = pServerOpt.m_ServerMapList.Maps[i];
		NewItem.m_bUseSubText = true;
		NewItem.m_stSubText.FontSubText = Root.Fonts[10];
		NewItem.m_stSubText.fHeight = 10.0000000;
		NewItem.m_stSubText.fXOffset = 10.0000000;
		NewItem.m_stSubText.szGameTypeSelect = pLevel.GetGameNameLocalization(szGameType);
		J0x32A:

		(i++);
		// [Loop Continue]
		goto J0x72;
	}
	// End:0x34D
	if((szResult == ""))
	{
		szResult = string(m_eMyGameMode);
	}
	return szResult;
	return;
}

//===================================================================================================
// FillFinalMapListInGame: Fill the map list according the list give by the server -- in-game only 
//===================================================================================================
function string FillFinalMapListInGame()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local UWindowListBoxItem NewItem;
	local int i;
	local string szGameType, szResult, szTemp;
	local R6GameReplicationInfo _GRI;
	local LevelInfo pLevel;

	pLevel = GetLevel();
	m_pFinalMapList.Items.Clear();
	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	_GRI = R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo);
	i = 0;
	J0x5D:

	// End:0x31A [Loop If]
	if(((i < _GRI.32) && (_GRI.m_mapArray[i] != "")))
	{
		szGameType = pLevel.GetGameTypeFromClassName(_GRI.m_gameModeArray[i]);
		szTemp = GetGameModeFromList(szGameType);
		// End:0x124
		if((int(m_eMyGameMode) == int(GetPlayerOwner().3)))
		{
			// End:0x116
			if((!pLevel.IsGameTypeAdversarial(szGameType)))
			{
				// End:0x113
				if((szResult == ""))
				{
					szResult = szTemp;
				}
				// [Explicit Continue]
				goto J0x310;
			}
			szResult = szTemp;			
		}
		else
		{
			// End:0x17F
			if((int(m_eMyGameMode) == int(GetPlayerOwner().2)))
			{
				// End:0x171
				if((!pLevel.IsGameTypeCooperative(szGameType)))
				{
					// End:0x16E
					if((szResult == ""))
					{
						szResult = szTemp;
					}
					// [Explicit Continue]
					goto J0x310;
				}
				szResult = szTemp;				
			}
			else
			{
				// [Explicit Continue]
				goto J0x310;
			}
		}
		NewItem = UWindowListBoxItem(m_pFinalMapList.Items.Append(m_pFinalMapList.ListClass));
		// End:0x258
		if((!Root.GetMapNameLocalisation(_GRI.m_mapArray[i], NewItem.HelpText)))
		{
			// End:0x22C
			if(FindMapInStartMapList(_GRI.m_mapArray[i]))
			{
				NewItem.HelpText = _GRI.m_mapArray[i];				
			}
			else
			{
				NewItem.HelpText = Localize("General", "None", "R6Menu");
			}
		}
		R6WindowListBoxItem(NewItem).m_szMisc = _GRI.m_mapArray[i];
		NewItem.m_bUseSubText = true;
		NewItem.m_stSubText.FontSubText = Root.Fonts[10];
		NewItem.m_stSubText.fHeight = 10.0000000;
		NewItem.m_stSubText.fXOffset = 10.0000000;
		NewItem.m_stSubText.szGameTypeSelect = pLevel.GetGameNameLocalization(szGameType);
		J0x310:

		(i++);
		// [Loop Continue]
		goto J0x5D;
	}
	// End:0x333
	if((szResult == ""))
	{
		szResult = string(m_eMyGameMode);
	}
	return szResult;
	return;
}

//===================================================================================================
//
//===================================================================================================
function SetGameModeToDisplay(string _szIndex)
{
	m_pTextInfo.ChangeTextLabel(((m_szLocGameMode $ " ") $ Localize("MPCreateGame", "Options_GameType", "R6Menu")), m_iTextIndex);
	m_pGameTypeCombo.Clear();
	InitMode(_szIndex);
	return;
}

//===================================================================================================
//
//===================================================================================================
function InitMode(string _szIndex)
{
	local string szGameTypeFind, szFirstGameType;
	local int i;
	local bool bFindGameType, bFirstValue;
	local LevelInfo pLevel;

	pLevel = GetLevel();
	i = 0;
	J0x13:

	// End:0x197 [Loop If]
	if((i < pLevel.m_aGameTypeInfo.Length))
	{
		szGameTypeFind = pLevel.m_aGameTypeInfo[i].m_szGameType;
		// End:0x18D
		if(((szGameTypeFind != "RGM_NoRulesMode") && pLevel.IsGameTypeMultiplayer(szGameTypeFind)))
		{
			switch(_szIndex)
			{
				// End:0xB9
				case string(GetPlayerOwner().3):
					// End:0xB6
					if(pLevel.IsGameTypeAdversarial(szGameTypeFind))
					{
						bFindGameType = true;
					}
					// End:0x10B
					break;
				// End:0xEC
				case string(GetPlayerOwner().2):
					// End:0xE9
					if(pLevel.IsGameTypeCooperative(szGameTypeFind))
					{
						bFindGameType = true;
					}
					// End:0x10B
					break;
				// End:0xFFFF
				default:
					__NFUN_231__("GAME MODE NOT DEFINED");
					// End:0x10B
					break;
					break;
			}
			// End:0x136
			if(bFindGameType)
			{
				bFindGameType = Class'Engine.Actor'.static.__NFUN_1524__().IsGameTypeAvailable(szGameTypeFind);
			}
			// End:0x185
			if(bFindGameType)
			{
				m_pGameTypeCombo.AddItem(pLevel.GetGameNameLocalization(szGameTypeFind), szGameTypeFind);
				// End:0x185
				if(__NFUN_129__(bFirstValue))
				{
					bFirstValue = true;
					szFirstGameType = szGameTypeFind;
				}
			}
			bFindGameType = false;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x13;
	}
	ManageAvailableGameTypes(m_pStartMapList.GetSelectedItem());
	// End:0x1EC
	if(__NFUN_114__(m_pFinalMapList.GetSelectedItem(), none))
	{
		m_pGameTypeCombo.SetValue(pLevel.GetGameNameLocalization(szFirstGameType), szFirstGameType);		
	}
	else
	{
		ManageAvailableGameTypes(m_pFinalMapList.GetSelectedItem(), true);
	}
	return;
}

function ManageAvailableGameTypes(UWindowList _pSelectItem, optional bool _bKeepItemGameType)
{
	local UWindowComboListItem pComboListItem;
	local R6MissionDescription pCurMissionDesc;
	local string szGameTypeFind, szFirstGameTypeFound, szItemGameType;
	local R6Console R6Console;
	local string szMapName, szEditBoxValue;
	local int i;
	local bool bUseSameGameType;
	local LevelInfo pLevel;

	pLevel = GetLevel();
	R6Console = R6Console(Root.Console);
	// End:0x32
	if(__NFUN_114__(_pSelectItem, none))
	{
		return;
	}
	szMapName = R6WindowListBoxItem(_pSelectItem).m_szMisc;
	szItemGameType = pLevel.GetGameTypeFromLocName(UWindowListBoxItem(_pSelectItem).m_stSubText.szGameTypeSelect);
	i = 0;
	J0x7F:

	// End:0xE6 [Loop If]
	if(__NFUN_150__(i, R6Console.m_aMissionDescriptions.Length))
	{
		// End:0xDC
		if(__NFUN_122__(szMapName, R6Console.m_aMissionDescriptions[i].m_MapName))
		{
			pCurMissionDesc = R6Console.m_aMissionDescriptions[i];
			// [Explicit Break]
			goto J0xE6;
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x7F;
	}
	J0xE6:

	// End:0x229
	if(__NFUN_119__(pCurMissionDesc, none))
	{
		m_pGameTypeCombo.DisableAllItems();
		szEditBoxValue = m_pGameTypeCombo.GetValue();
		szFirstGameTypeFound = "RGM_NoRulesMode";
		i = 0;
		J0x133:

		// End:0x229 [Loop If]
		if(__NFUN_150__(i, pCurMissionDesc.m_szGameTypes.Length))
		{
			szGameTypeFind = pCurMissionDesc.m_szGameTypes[i];
			pComboListItem = m_pGameTypeCombo.GetItem(pLevel.GetGameNameLocalization(szGameTypeFind));
			// End:0x21F
			if(__NFUN_119__(pComboListItem, none))
			{
				pComboListItem.bDisabled = false;
				// End:0x1D1
				if(__NFUN_122__(szFirstGameTypeFound, "RGM_NoRulesMode"))
				{
					szFirstGameTypeFound = szGameTypeFind;
				}
				// End:0x1F9
				if(__NFUN_130__(_bKeepItemGameType, __NFUN_122__(szItemGameType, szGameTypeFind)))
				{
					szFirstGameTypeFound = szGameTypeFind;
					// [Explicit Continue]
					goto J0x21F;
				}
				// End:0x21F
				if(__NFUN_122__(szEditBoxValue, pLevel.GetGameNameLocalization(szGameTypeFind)))
				{
					bUseSameGameType = true;
				}
			}
			J0x21F:

			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x133;
		}
	}
	// End:0x279
	if(__NFUN_130__(__NFUN_129__(bUseSameGameType), __NFUN_123__(szFirstGameTypeFound, "RGM_NoRulesMode")))
	{
		m_pGameTypeCombo.SetValue(pLevel.GetGameNameLocalization(szFirstGameTypeFound), szFirstGameTypeFound);
	}
	return;
}

//===================================================================================
// Copy an item and add it in a specfic list
//===================================================================================
function CopyAndAddItemInList(UWindowListBoxItem _ItemToAdd, UWindowListControl _ListAddItem)
{
	local UWindowListBoxItem NewItem;

	// End:0x11F
	if(__NFUN_150__(_ListAddItem.Items.Count(), 32))
	{
		NewItem = UWindowListBoxItem(_ListAddItem.Items.Append(_ListAddItem.ListClass));
		NewItem.HelpText = _ItemToAdd.HelpText;
		R6WindowListBoxItem(NewItem).m_szMisc = R6WindowListBoxItem(_ItemToAdd).m_szMisc;
		NewItem.m_bUseSubText = true;
		NewItem.m_stSubText.FontSubText = Root.Fonts[10];
		NewItem.m_stSubText.fHeight = 10.0000000;
		NewItem.m_stSubText.fXOffset = 10.0000000;
		NewItem.m_stSubText.szGameTypeSelect = m_pGameTypeCombo.GetValue();
	}
	return;
}

function bool FindMapInStartMapList(string _szMapName)
{
	local UWindowListBoxItem CurItem;

	CurItem = UWindowListBoxItem(m_pStartMapList.Items.Next);
	J0x22:

	// End:0x68 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		// End:0x4C
		if(__NFUN_122__(R6WindowListBoxItem(CurItem).m_szMisc, _szMapName))
		{
			return true;
		}
		CurItem = UWindowListBoxItem(CurItem.Next);
		// [Loop Continue]
		goto J0x22;
	}
	return false;
	return;
}

// NEW IN 1.60
function byte FillGameTypeMapArray(out array<string> _SelectedMapList, out array<string> _SelectedGameTypeList)
{
	local UWindowListBoxItem CurItem;
	local int i;

	_SelectedMapList.Remove(0, _SelectedMapList.Length);
	// End:0x2D
	if(__NFUN_114__(m_pFinalMapList.Items.Next, none))
	{
		return 0;
	}
	CurItem = UWindowListBoxItem(m_pFinalMapList.Items.Next);
	i = 0;
	J0x56:

	// End:0xD3 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		_SelectedMapList[i] = R6WindowListBoxItem(CurItem).m_szMisc;
		_SelectedGameTypeList[i] = GetLevel().GetGameTypeFromLocName(CurItem.m_stSubText.szGameTypeSelect, true);
		CurItem = UWindowListBoxItem(CurItem.Next);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x56;
	}
	return byte(i);
	return;
}

//===================================================================================
// Notify : Receive msg from UWindowDialogControl window
//===================================================================================
function Notify(UWindowDialogControl C, byte E)
{
	// End:0x35
	if(m_bInGame)
	{
		// End:0x35
		if(__NFUN_129__(R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).1)))
		{
			return;
		}
	}
	// End:0x12E
	if(C.__NFUN_303__('R6WindowTextListBox'))
	{
		switch(E)
		{
			// End:0x117
			case 2:
				// End:0xA7
				if(__NFUN_114__(C, m_pStartMapList))
				{
					// End:0x8E
					if(__NFUN_119__(m_pStartMapList.GetSelectedItem(), none))
					{
						ManageAvailableGameTypes(m_pStartMapList.GetSelectedItem());
					}
					m_pFinalMapList.DropSelection();
					SetButtonRegion(true);					
				}
				else
				{
					// End:0xFE
					if(__NFUN_119__(m_pFinalMapList.GetSelectedItem(), none))
					{
						ManageAvailableGameTypes(m_pFinalMapList.GetSelectedItem(), true);
						m_pGameTypeCombo.SetValue(m_pFinalMapList.GetSelectedItem().m_stSubText.szGameTypeSelect);
					}
					m_pStartMapList.DropSelection();
					SetButtonRegion(false);
				}
				// End:0x12B
				break;
			// End:0x125
			case 11:
				ManageTextListBox();
				// End:0x12B
				break;
			// End:0xFFFF
			default:
				// End:0x12B
				break;
				break;
		}		
	}
	else
	{
		// End:0x160
		if(C.__NFUN_303__('R6WindowComboControl'))
		{
			switch(E)
			{
				// End:0x157
				case 1:
					ManageComboChange();
					// End:0x15D
					break;
				// End:0xFFFF
				default:
					// End:0x15D
					break;
					break;
			}			
		}
		else
		{
			// End:0x26F
			if(C.__NFUN_303__('UWindowButton'))
			{
				// End:0x1B5
				if(__NFUN_132__(UWindowButton(C).bDisabled, __NFUN_130__(__NFUN_119__(C, m_pSelectButton), __NFUN_114__(m_pFinalMapList.GetSelectedItem(), none))))
				{
					return;
				}
				switch(E)
				{
					// End:0x206
					case 2:
						// End:0x1D9
						if(__NFUN_114__(C, m_pSelectButton))
						{
							ManageTextListBox();							
						}
						else
						{
							m_pFinalMapList.SwapItem(m_pFinalMapList.GetSelectedItem(), __NFUN_119__(C, m_pPlusButton));
						}
						// End:0x26F
						break;
					// End:0x239
					case 12:
						UWindowButton(C).m_BorderColor = Root.Colors.BlueLight;
						// End:0x26F
						break;
					// End:0x26C
					case 9:
						UWindowButton(C).m_BorderColor = Root.Colors.White;
						// End:0x26F
						break;
					// End:0xFFFF
					default:
						break;
				}
			}
			else
			{
			}
		}
		return;
	}
}

/////////////////////////////////////////////////////////////////
// ManageTextListBox: Manage the operation between the two map list
/////////////////////////////////////////////////////////////////
function ManageTextListBox()
{
	local UWindowListBoxItem Item, NextItem, prevItem;

	Item = m_pStartMapList.GetSelectedItem();
	// End:0x49
	if(__NFUN_119__(Item, none))
	{
		// End:0x46
		if(__NFUN_123__(m_pGameTypeCombo.GetValue(), ""))
		{
			CopyAndAddItemInList(Item, m_pFinalMapList);
		}		
	}
	else
	{
		Item = m_pFinalMapList.GetSelectedItem();
		// End:0x15E
		if(__NFUN_119__(Item, none))
		{
			prevItem = m_pFinalMapList.CheckForPrevItem(Item);
			NextItem = m_pFinalMapList.CheckForNextItem(Item);
			Item.Remove();
			m_pFinalMapList.DropSelection();
			// End:0xFA
			if(__NFUN_114__(m_pFinalMapList.Items.Next, none))
			{
				m_pFinalMapList.Items.Clear();
				SetButtonRegion(true);				
			}
			else
			{
				// End:0x113
				if(__NFUN_119__(NextItem, none))
				{
					Item = NextItem;					
				}
				else
				{
					// End:0x129
					if(__NFUN_119__(prevItem, none))
					{
						Item = prevItem;
					}
				}
				// End:0x157
				if(__NFUN_119__(Item, none))
				{
					m_pFinalMapList.SetSelectedItem(Item);
					m_pFinalMapList.MakeSelectedVisible();
				}
				SetButtonRegion(false);
			}
		}
	}
	return;
}

function WindowStateChange()
{
	local UWindowListBoxItem Item;

	Item = m_pFinalMapList.GetSelectedItem();
	// End:0x2B
	if(__NFUN_119__(Item, none))
	{
		m_bFromStartList = false;		
	}
	else
	{
		m_bFromStartList = true;
	}
	SetButtonRegion(__NFUN_129__(m_bFromStartList));
	return;
}

/////////////////////////////////////////////////////////////////
// ManageComboChange: Manage the DE_Change combo control message
/////////////////////////////////////////////////////////////////
function ManageComboChange()
{
	local UWindowListBoxItem Item;
	local UWindowComboListItem pComboListItem;

	Item = m_pStartMapList.GetSelectedItem();
	// End:0x88
	if(__NFUN_119__(Item, none))
	{
		pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());
		// End:0x86
		if(__NFUN_119__(pComboListItem, none))
		{
			// End:0x86
			if(__NFUN_129__(pComboListItem.bDisabled))
			{
				Item.m_stSubText.szGameTypeSelect = m_pGameTypeCombo.GetValue();
			}
		}
		return;
	}
	Item = m_pFinalMapList.GetSelectedItem();
	// End:0x10E
	if(__NFUN_119__(Item, none))
	{
		pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());
		// End:0x10E
		if(__NFUN_119__(pComboListItem, none))
		{
			// End:0x10E
			if(__NFUN_129__(pComboListItem.bDisabled))
			{
				Item.m_stSubText.szGameTypeSelect = m_pGameTypeCombo.GetValue();
			}
		}
	}
	return;
}

function SetButtonRegion(bool _bInverseTex)
{
	m_pSelectButton.bUseRegion = true;
	// End:0x6D
	if(_bInverseTex)
	{
		m_pSelectButton.ImageX = 1.0000000;
		m_pSelectButton.ImageY = 3.0000000;
		m_pSelectButton.m_fRotAngleWidth = 9.0000000;
		m_pSelectButton.m_fRotAngleHeight = 7.0000000;		
	}
	else
	{
		m_pSelectButton.ImageX = 3.0000000;
		m_pSelectButton.ImageY = 3.0000000;
		m_pSelectButton.m_fRotAngleWidth = 9.0000000;
		m_pSelectButton.m_fRotAngleHeight = 7.0000000;
	}
	m_pSelectButton.UpTexture = m_pButtonTexture;
	m_pSelectButton.DownTexture = m_pButtonTexture;
	m_pSelectButton.OverTexture = m_pButtonTexture;
	m_pSelectButton.DisabledTexture = m_pButtonTexture;
	m_pSelectButton.UpRegion = m_RArrowUp;
	m_pSelectButton.DownRegion = m_RArrowDown;
	m_pSelectButton.OverRegion = m_RArrowOver;
	m_pSelectButton.DisabledRegion = m_RArrowDisabled;
	m_pSelectButton.m_bUseRotAngle = _bInverseTex;
	m_pSelectButton.m_fRotAngle = 3.1416000;
	SetOrderButtons(_bInverseTex);
	return;
}

function SetOrderButtons(bool _bDisable)
{
	// End:0x1A
	if(__NFUN_132__(__NFUN_114__(m_pSubButton, none), __NFUN_114__(m_pPlusButton, none)))
	{
		return;
	}
	// End:0xB4
	if(__NFUN_132__(_bDisable, __NFUN_152__(m_pFinalMapList.Items.CountShown(), 1)))
	{
		m_pSubButton.m_BorderColor = Root.Colors.GrayLight;
		m_pSubButton.bDisabled = true;
		m_pPlusButton.m_BorderColor = Root.Colors.GrayLight;
		m_pPlusButton.bDisabled = true;		
	}
	else
	{
		m_pSubButton.m_BorderColor = Root.Colors.White;
		m_pSubButton.bDisabled = false;
		m_pPlusButton.m_BorderColor = Root.Colors.White;
		m_pPlusButton.bDisabled = false;
	}
	return;
}

defaultproperties
{
	m_pButtonTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RArrowUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=24098,ZoneNumber=0)
	m_RArrowDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=24098,ZoneNumber=0)
	m_RArrowDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=24098,ZoneNumber=0)
	m_RArrowOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=24098,ZoneNumber=0)
}
