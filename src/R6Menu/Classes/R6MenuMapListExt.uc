//=============================================================================
// R6MenuMapListExt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuMapListExt extends R6MenuMapList;

const C_fHEIGHT_OF_MAPLIST = 214;
const C_fY_ButPos = 117;
const C_MAP_INDEX = 0;
const C_GAME_TYPE_INDEX = 1;
const C_GREEN_ARMOR_INDEX = 2;
const C_RED_ARMOR_INDEX = 3;

var bool m_bFinalListEmpty;

function Created()
{
	local UWindowListBoxItem CurItem;
	local float fXOffset, fYOffset, fWidth, fXSecondWindow;

	fXSecondWindow = __NFUN_175__(__NFUN_175__(WinWidth, float(7)), float(135));
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
	fYOffset = __NFUN_174__(__NFUN_174__(16.0000000, float(214)), float(5));
	m_pTextInfo.m_Font = Root.Fonts[6];
	m_iTextIndex = m_pTextInfo.AddTextLabel(__NFUN_112__(__NFUN_112__(m_szLocGameMode, " "), Localize("MPCreateGame", "Options_GameType", "R6Menu")), fXOffset, fYOffset, __NFUN_175__(fXSecondWindow, fXOffset), 0, false);
	m_pStartMapList = R6WindowTextListBoxExt(CreateControl(Class'R6Window.R6WindowTextListBoxExt', 7.0000000, 16.0000000, 135.0000000, 214.0000000, self));
	m_pStartMapList.TextColor = Root.Colors.BlueLight;
	m_pStartMapList.SetCornerType(0);
	m_pStartMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
	m_pStartMapList.ToolTipString = Localize("Tip", "Options_Map", "R6Menu");
	m_pFinalMapList = R6WindowTextListBoxExt(CreateControl(Class'R6Window.R6WindowTextListBoxExt', fXSecondWindow, 16.0000000, 135.0000000, 214.0000000, self));
	m_pFinalMapList.TextColor = Root.Colors.BlueLight;
	m_pFinalMapList.SetCornerType(0);
	m_pFinalMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
	m_pFinalMapList.ToolTipString = Localize("Tip", "Options_MapList", "R6Menu");
	m_pSelectButton = UWindowButton(CreateControl(Class'UWindow.UWindowButton', 148.0000000, 117.0000000, 13.0000000, 13.0000000, self));
	m_pSelectButton.m_bDrawButtonBorders = true;
	SetButtonRegion(true);
	m_pSelectButton.ToolTipString = Localize("Tip", "Options_MapListAddRemove", "R6Menu");
	fYOffset = __NFUN_174__(__NFUN_174__(16.0000000, float(214)), float(5));
	m_pGameTypeCombo = R6WindowComboControl(CreateControl(Class'R6Window.R6WindowComboControl', fXSecondWindow, fYOffset, fWidth, LookAndFeel.Size_ComboHeight));
	m_pGameTypeCombo.SetFont(6);
	m_pGameTypeCombo.SetEditBoxTip(Localize("Tip", "Options_MapListGameType", "R6Menu"));
	m_pGameTypeCombo.List.MaxVisible = 5;
	CreateButtons();
	return;
}

function FillMapListItem()
{
	local R6WindowListBoxItemExt NewItem;
	local R6MissionDescription mission;
	local R6Console R6Console;
	local LevelInfo pLevel;
	local Region ItemR;
	local string szLocMapName, szMod, szRavenShieldMod;
	local int i, j;
	local bool bLoadMap;

	pLevel = GetLevel();
	R6Console = R6Console(Root.Console);
	m_pStartMapList.Items.Clear();
	szMod = Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod.m_szKeyWord;
	szRavenShieldMod = Class'Engine.Actor'.static.__NFUN_1524__().m_pRVS.m_szKeyWord;
	i = 0;
	J0x8C:

	// End:0x26B [Loop If]
	if(__NFUN_150__(i, R6Console.m_aMissionDescriptions.Length))
	{
		mission = R6Console.m_aMissionDescriptions[i];
		// End:0x261
		if(__NFUN_123__(mission.m_MapName, ""))
		{
			j = 0;
			J0xDB:

			// End:0x261 [Loop If]
			if(__NFUN_150__(j, mission.m_szGameTypes.Length))
			{
				bLoadMap = false;
				// End:0x11F
				if(__NFUN_124__(szMod, mission.mod))
				{
					bLoadMap = true;					
				}
				else
				{
					// End:0x13F
					if(__NFUN_124__(mission.mod, szRavenShieldMod))
					{
						bLoadMap = true;
					}
				}
				// End:0x257
				if(__NFUN_130__(bLoadMap, pLevel.IsGameTypeMultiplayer(mission.m_szGameTypes[j], true)))
				{
					NewItem = R6WindowListBoxItemExt(m_pStartMapList.Items.Append(m_pStartMapList.ListClass));
					// End:0x1DD
					if(__NFUN_129__(Root.GetMapNameLocalisation(mission.m_MapName, szLocMapName)))
					{
						szLocMapName = mission.m_MapName;
					}
					ItemR.X = 5;
					ItemR.Y = 0;
					ItemR.W = __NFUN_147__(__NFUN_147__(135, 5), 13);
					ItemR.H = 14;
					AssignParamsToNewItem(NewItem, 0, szLocMapName, mission.m_MapName, ItemR, 0);
					AssignParamsToNewItem(NewItem, 1, "", "", ItemR, 0, true);
					// [Explicit Break]
					goto J0x261;
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0xDB;
			}
		}
		J0x261:

		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x8C;
	}
	m_pStartMapList.Items.Sort();
	return;
}

function string FillFinalMapList()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local R6WindowListBoxItemExt NewItem;
	local int i;
	local Region ItemR;
	local string szGameType, szResult, szTemp, szGreenArmor, szRedArmor, szGreenPkg,
		szRedPkg;

	local R6ServerInfo pServerOpt;
	local LevelInfo pLevel;
	local Region ItemRegion;

	pServerOpt = Class'Engine.Actor'.static.__NFUN_1273__();
	pLevel = GetLevel();
	m_pFinalMapList.Items.Clear();
	// End:0x6B
	if(__NFUN_114__(pServerOpt.m_ServerMapList, none))
	{
		pServerOpt.m_ServerMapList = GetPlayerOwner().__NFUN_278__(Class'Engine.R6MapList');
	}
	i = 0;
	J0x72:

	// End:0x3A0 [Loop If]
	if(__NFUN_130__(__NFUN_150__(i, 32), __NFUN_123__(pServerOpt.m_ServerMapList.Maps[i], "")))
	{
		szGameType = pLevel.GetGameTypeFromClassName(pServerOpt.m_ServerMapList.GameType[i]);
		szTemp = GetGameModeFromList(szGameType);
		// End:0x142
		if(__NFUN_154__(int(m_eMyGameMode), int(GetPlayerOwner().3)))
		{
			// End:0x134
			if(__NFUN_129__(pLevel.IsGameTypeAdversarial(szGameType)))
			{
				// End:0x131
				if(__NFUN_122__(szResult, ""))
				{
					szResult = szTemp;
				}
				// [Explicit Continue]
				goto J0x396;
			}
			szResult = szTemp;			
		}
		else
		{
			// End:0x19D
			if(__NFUN_154__(int(m_eMyGameMode), int(GetPlayerOwner().2)))
			{
				// End:0x18F
				if(__NFUN_129__(pLevel.IsGameTypeCooperative(szGameType)))
				{
					// End:0x18C
					if(__NFUN_122__(szResult, ""))
					{
						szResult = szTemp;
					}
					// [Explicit Continue]
					goto J0x396;
				}
				szResult = szTemp;				
			}
			else
			{
				// [Explicit Continue]
				goto J0x396;
			}
		}
		// End:0x224
		if(__NFUN_129__(Root.GetMapNameLocalisation(pServerOpt.m_ServerMapList.Maps[i], szTemp)))
		{
			// End:0x201
			if(__NFUN_129__(FindMapInStartMapList(pServerOpt.m_ServerMapList.Maps[i])))
			{
				// [Explicit Continue]
				goto J0x396;
			}
			szTemp = pServerOpt.m_ServerMapList.Maps[i];
		}
		NewItem = R6WindowListBoxItemExt(m_pFinalMapList.Items.Append(m_pFinalMapList.ListClass));
		ItemR.X = 5;
		ItemR.Y = 0;
		ItemR.W = __NFUN_147__(__NFUN_147__(135, 5), 13);
		ItemR.H = 14;
		AssignParamsToNewItem(NewItem, 0, szTemp, pServerOpt.m_ServerMapList.Maps[i], ItemR, 0);
		ItemR.X = 10;
		ItemR.W = __NFUN_147__(__NFUN_147__(135, 10), 13);
		ItemR.H = 11;
		AssignParamsToNewItem(NewItem, 1, pLevel.GetGameNameLocalization(szGameType), pServerOpt.m_ServerMapList.GameType[i], ItemR, 1);
		GetInitArmor(szTemp, szGameType, szGreenArmor, szRedArmor, szGreenPkg, szRedPkg);
		AssignParamsToNewItem(NewItem, 2, szGreenArmor, szGreenPkg, ItemR, 2);
		AssignParamsToNewItem(NewItem, 3, szRedArmor, szRedPkg, ItemR, 3);
		J0x396:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x72;
	}
	// End:0x3B9
	if(__NFUN_122__(szResult, ""))
	{
		szResult = string(m_eMyGameMode);
	}
	return szResult;
	return;
}

function ManageAvailableGameTypes(UWindowList _pSelectItem, optional bool _bKeepItemGameType)
{
	local UWindowComboListItem pComboListItem;
	local R6MissionDescription pCurMissionDesc;
	local string szGameTypeFind, szGameTypeClassName, szFirstGameTypeFound, szItemGameType;
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
	szMapName = R6WindowListBoxItemExt(_pSelectItem).GetItemMisc(0);
	szItemGameType = R6WindowListBoxItemExt(_pSelectItem).GetItemMisc(1);
	i = 0;
	J0x6F:

	// End:0xD6 [Loop If]
	if(__NFUN_150__(i, R6Console.m_aMissionDescriptions.Length))
	{
		// End:0xCC
		if(__NFUN_122__(szMapName, R6Console.m_aMissionDescriptions[i].m_MapName))
		{
			pCurMissionDesc = R6Console.m_aMissionDescriptions[i];
			// [Explicit Break]
			goto J0xD6;
		}
		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x6F;
	}
	J0xD6:

	// End:0x258
	if(__NFUN_119__(pCurMissionDesc, none))
	{
		m_pGameTypeCombo.DisableAllItems();
		szEditBoxValue = m_pGameTypeCombo.GetValue();
		szFirstGameTypeFound = "RGM_NoRulesMode";
		i = 0;
		J0x123:

		// End:0x258 [Loop If]
		if(__NFUN_150__(i, pCurMissionDesc.m_szGameTypes.Length))
		{
			szGameTypeFind = pCurMissionDesc.m_szGameTypes[i];
			szGameTypeClassName = __NFUN_112__(__NFUN_112__(pCurMissionDesc.GameTypes[i].Package, "."), pCurMissionDesc.GameTypes[i].type);
			pComboListItem = m_pGameTypeCombo.GetItem(pLevel.GetGameNameLocalization(szGameTypeFind));
			// End:0x24E
			if(__NFUN_119__(pComboListItem, none))
			{
				pComboListItem.bDisabled = false;
				// End:0x200
				if(__NFUN_122__(szFirstGameTypeFound, "RGM_NoRulesMode"))
				{
					szFirstGameTypeFound = szGameTypeFind;
				}
				// End:0x228
				if(__NFUN_130__(_bKeepItemGameType, __NFUN_122__(szItemGameType, szGameTypeClassName)))
				{
					szFirstGameTypeFound = szGameTypeFind;
					// [Explicit Continue]
					goto J0x24E;
				}
				// End:0x24E
				if(__NFUN_122__(szEditBoxValue, pLevel.GetGameNameLocalization(szGameTypeFind)))
				{
					bUseSameGameType = true;
				}
			}
			J0x24E:

			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x123;
		}
	}
	// End:0x2B7
	if(__NFUN_130__(__NFUN_129__(bUseSameGameType), __NFUN_123__(szFirstGameTypeFound, "RGM_NoRulesMode")))
	{
		m_pGameTypeCombo.SetValue(pLevel.GetGameNameLocalization(szFirstGameTypeFound), pLevel.GetGameTypeClassName(szFirstGameTypeFound));
	}
	return;
}

function CopyAndAddItemInList(UWindowListBoxItem _ItemToAdd, UWindowListControl _ListAddItem)
{
	local R6WindowListBoxItemExt NewItem, ItemToAdd;
	local Region ItemR;
	local string szGreenArmor, szRedArmor, szGreenPkg, szRedPkg;

	// End:0x1EB
	if(__NFUN_130__(__NFUN_150__(_ListAddItem.Items.Count(), 32), __NFUN_119__(_ItemToAdd, none)))
	{
		ItemToAdd = R6WindowListBoxItemExt(_ItemToAdd);
		NewItem = R6WindowListBoxItemExt(_ListAddItem.Items.Append(_ListAddItem.ListClass));
		ItemR.X = 5;
		ItemR.Y = 0;
		ItemR.W = __NFUN_147__(__NFUN_147__(135, 5), 13);
		ItemR.H = 14;
		AssignParamsToNewItem(NewItem, 0, ItemToAdd.GetItemText(0), ItemToAdd.GetItemMisc(0), ItemR, 0);
		ItemR.X = 10;
		ItemR.W = __NFUN_147__(__NFUN_147__(135, 10), 13);
		ItemR.H = 11;
		szGreenArmor = GetLevel().GetGameTypeFromLocName(m_pGameTypeCombo.GetValue(), true);
		AssignParamsToNewItem(NewItem, 1, m_pGameTypeCombo.GetValue(), GetLevel().GetGameTypeClassName(szGreenArmor), ItemR, 1);
		GetInitArmor(ItemToAdd.GetItemText(0), GetLevel().GetGameTypeFromLocName(m_pGameTypeCombo.GetValue(), true), szGreenArmor, szRedArmor, szGreenPkg, szRedPkg);
		AssignParamsToNewItem(NewItem, 2, szGreenArmor, szGreenPkg, ItemR, 2);
		AssignParamsToNewItem(NewItem, 3, szRedArmor, szRedPkg, ItemR, 3);
	}
	return;
}

function AssignParamsToNewItem(R6WindowListBoxItemExt NewItem, int _index, string _szText, string _szMisc, Region R, int _iLineNumber, optional bool _bNotDisplay)
{
	local stItemDesc NewItemDesc;

	// End:0xED
	if(__NFUN_119__(NewItem, none))
	{
		NewItemDesc.szText = _szText;
		NewItemDesc.szMisc = _szMisc;
		NewItemDesc.TextFont = Root.Fonts[6];
		NewItemDesc.fXPos = float(R.X);
		NewItemDesc.fYPos = float(R.Y);
		NewItemDesc.fWidth = float(R.W);
		NewItemDesc.fHeigth = float(R.H);
		NewItemDesc.iLineNumber = _iLineNumber;
		NewItemDesc.eAlignment = 0;
		NewItemDesc.bDisplay = __NFUN_129__(_bNotDisplay);
		NewItem.SetItemParam(_index, NewItemDesc);
	}
	return;
}

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

	// End:0xC6 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		_SelectedMapList[i] = R6WindowListBoxItemExt(CurItem).GetItemMisc(0);
		_SelectedGameTypeList[i] = R6WindowListBoxItemExt(CurItem).GetItemMisc(1);
		CurItem = UWindowListBoxItem(CurItem.Next);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x56;
	}
	return byte(i);
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local bool bUpdate;

	// End:0x0B
	if(m_bInGame)
	{
		return;
	}
	// End:0x106
	if(C.__NFUN_303__('R6WindowTextListBoxExt'))
	{
		switch(E)
		{
			// End:0xEF
			case 2:
				// End:0x7D
				if(__NFUN_114__(C, m_pStartMapList))
				{
					// End:0x64
					if(__NFUN_119__(m_pStartMapList.GetSelectedItem(), none))
					{
						ManageAvailableGameTypes(m_pStartMapList.GetSelectedItem());
					}
					m_pFinalMapList.DropSelection();
					SetButtonRegion(true);					
				}
				else
				{
					// End:0xD6
					if(__NFUN_119__(m_pFinalMapList.GetSelectedItem(), none))
					{
						ManageAvailableGameTypes(m_pFinalMapList.GetSelectedItem(), true);
						m_pGameTypeCombo.SetValue(R6WindowListBoxItemExt(m_pFinalMapList.GetSelectedItem()).GetItemText(1));
					}
					m_pStartMapList.DropSelection();
					SetButtonRegion(false);
				}
				// End:0x103
				break;
			// End:0xFD
			case 11:
				ManageTextListBox();
				// End:0x103
				break;
			// End:0xFFFF
			default:
				// End:0x103
				break;
				break;
		}		
	}
	else
	{
		super.Notify(C, E);
	}
	bUpdate = false;
	// End:0x145
	if(m_bFinalListEmpty)
	{
		// End:0x142
		if(__NFUN_129__(IsFinalMapListEmpty()))
		{
			m_bFinalListEmpty = false;
			bUpdate = true;
		}		
	}
	else
	{
		// End:0x15E
		if(IsFinalMapListEmpty())
		{
			m_bFinalListEmpty = true;
			bUpdate = true;
		}
	}
	// End:0x18B
	if(bUpdate)
	{
		// End:0x18B
		if(__NFUN_119__(R6MenuMPCreateGameTabOptions(OwnerWindow), none))
		{
			R6MenuMPCreateGameTabOptions(OwnerWindow).UpdateSkinButton();
		}
	}
	return;
}

function ManageComboChange()
{
	local R6WindowListBoxItemExt Item;
	local UWindowComboListItem pComboListItem;
	local string szTemp, szGreenArmor, szRedArmor, szGreenPkg, szRedPkg;

	Item = R6WindowListBoxItemExt(m_pStartMapList.GetSelectedItem());
	// End:0x89
	if(__NFUN_119__(Item, none))
	{
		pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());
		// End:0x87
		if(__NFUN_119__(pComboListItem, none))
		{
			// End:0x87
			if(__NFUN_129__(pComboListItem.bDisabled))
			{
				Item.SetItemMisc(1, m_pGameTypeCombo.GetValue());
			}
		}
		return;
	}
	Item = R6WindowListBoxItemExt(m_pFinalMapList.GetSelectedItem());
	// End:0x1B6
	if(__NFUN_119__(Item, none))
	{
		pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());
		// End:0x1B6
		if(__NFUN_119__(pComboListItem, none))
		{
			// End:0x1B6
			if(__NFUN_129__(pComboListItem.bDisabled))
			{
				szTemp = GetLevel().GetGameTypeFromLocName(m_pGameTypeCombo.GetValue(), true);
				Item.SetItemText(1, m_pGameTypeCombo.GetValue());
				Item.SetItemMisc(1, GetLevel().GetGameTypeClassName(szTemp));
				GetInitArmor(Item.GetItemText(0), szTemp, szGreenArmor, szRedArmor, szGreenPkg, szRedPkg);
				Item.SetItemText(2, szGreenArmor);
				Item.SetItemText(3, szRedArmor);
			}
		}
	}
	return;
}

function GetInitArmor(string _szMapName, string _szGameType, out string _szGreenArmor, out string _szRedArmor, out string _szGreenPkg, out string _szRedPkg)
{
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local R6MissionDescription CurrentMission;
	local R6Console R6Console;
	local string szGreenArmor, szRedArmor, szTemp, szValidEntry;
	local int i, j, nbArmor;
	local bool bFind, bFindBothArmor, bFindGreenArmor, bFindRedArmor;
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.__NFUN_1524__();
	R6Console = R6Console(Root.Console);
	szGreenArmor = "";
	szRedArmor = "";
	i = 0;
	J0x42:

	// End:0xD1 [Loop If]
	if(__NFUN_150__(i, R6Console.m_aMissionDescriptions.Length))
	{
		CurrentMission = R6Console.m_aMissionDescriptions[i];
		// End:0x83
		if(__NFUN_114__(CurrentMission, none))
		{
			// [Explicit Break]
			goto J0xD1;
		}
		// End:0xAD
		if(__NFUN_129__(Root.GetMapNameLocalisation(CurrentMission.m_MapName, szTemp)))
		{
			// [Explicit Continue]
			goto J0xC7;
		}
		// End:0xC7
		if(__NFUN_122__(szTemp, _szMapName))
		{
			bFind = true;
			// [Explicit Break]
			goto J0xD1;
		}
		J0xC7:

		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x42;
	}
	J0xD1:

	// End:0x1B6
	if(bFind)
	{
		j = 0;
		J0xE1:

		// End:0x1B6 [Loop If]
		if(__NFUN_150__(j, CurrentMission.SkinsPerGameTypes.Length))
		{
			szTemp = GetLevel().GetGameTypeClassName(_szGameType);
			i = __NFUN_126__(szTemp, ".");
			szTemp = __NFUN_234__(szTemp, __NFUN_147__(__NFUN_147__(__NFUN_125__(szTemp), 1), __NFUN_126__(szTemp, ".")));
			// End:0x1AC
			if(__NFUN_124__(CurrentMission.SkinsPerGameTypes[j].type, szTemp))
			{
				szGreenArmor = CurrentMission.SkinsPerGameTypes[j].Green;
				szRedArmor = CurrentMission.SkinsPerGameTypes[j].Red;
				// [Explicit Break]
				goto J0x1B6;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0xE1;
		}
	}
	J0x1B6:

	bFind = false;
	// End:0x5DA
	if(__NFUN_123__(szGreenArmor, ""))
	{
		bFindBothArmor = GetLevel().IsGameTypeTeamAdversarial(_szGameType);
		szGreenArmor = __NFUN_112__(__NFUN_112__(CurrentMission.SkinsPerGameTypes[j].greenPackage, "."), szGreenArmor);
		szRedArmor = __NFUN_112__(__NFUN_112__(CurrentMission.SkinsPerGameTypes[j].redPackage, "."), szRedArmor);
		_szGreenPkg = szGreenArmor;
		_szRedPkg = szRedArmor;
		j = 0;
		J0x259:

		// End:0x413 [Loop If]
		if(__NFUN_150__(j, pModManager.m_pCurrentMod.m_aDescriptionPackage.Length))
		{
			ArmorDescriptionClass = Class<R6ArmorDescription>(__NFUN_1005__(__NFUN_112__(pModManager.m_pCurrentMod.m_aDescriptionPackage[j], ".u"), Class'R6Description.R6ArmorDescription'));
			J0x2B1:

			// End:0x406 [Loop If]
			if(__NFUN_119__(ArmorDescriptionClass, none))
			{
				// End:0x3F5
				if(__NFUN_123__(ArmorDescriptionClass.default.m_NameID, "NONE"))
				{
					// End:0x324
					if(__NFUN_122__(ArmorDescriptionClass.default.m_ClassName, szGreenArmor))
					{
						szGreenArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
						bFindGreenArmor = true;						
					}
					else
					{
						// End:0x37E
						if(__NFUN_130__(bFindBothArmor, __NFUN_122__(ArmorDescriptionClass.default.m_ClassName, szRedArmor)))
						{
							szRedArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
							bFindRedArmor = true;							
						}
						else
						{
							// End:0x3B6
							if(__NFUN_122__(szValidEntry, ""))
							{
								szValidEntry = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
							}
						}
					}
					// End:0x3E1
					if(bFindBothArmor)
					{
						// End:0x3DE
						if(__NFUN_130__(bFindGreenArmor, bFindRedArmor))
						{
							bFind = true;
							// [Explicit Break]
							goto J0x406;
						}						
					}
					else
					{
						// End:0x3F5
						if(bFindGreenArmor)
						{
							bFind = true;
							// [Explicit Break]
							goto J0x406;
						}
					}
				}
				ArmorDescriptionClass = Class<R6ArmorDescription>(__NFUN_1006__());
				// [Loop Continue]
				goto J0x2B1;
			}
			J0x406:

			__NFUN_1007__();
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x259;
		}
		// End:0x5DA
		if(__NFUN_130__(__NFUN_129__(bFind), __NFUN_242__(pModManager.m_pCurrentMod.m_bUseCustomOperatives, true)))
		{
			j = 0;
			J0x445:

			// End:0x5DA [Loop If]
			if(__NFUN_150__(j, pModManager.GetPackageMgr().GetNbPackage()))
			{
				// End:0x474
				if(bFind)
				{
					// [Explicit Break]
					goto J0x5DA;
				}
				ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(j, Class'R6Description.R6ArmorDescription'));
				J0x4A2:

				// End:0x5D0 [Loop If]
				if(__NFUN_130__(__NFUN_119__(ArmorDescriptionClass, none), __NFUN_242__(ArmorDescriptionClass.default.m_bHideFromMenu, false)))
				{
					// End:0x513
					if(__NFUN_122__(ArmorDescriptionClass.default.m_ClassName, szGreenArmor))
					{
						szGreenArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
						bFindGreenArmor = true;						
					}
					else
					{
						// End:0x56A
						if(__NFUN_130__(bFindBothArmor, __NFUN_122__(ArmorDescriptionClass.default.m_ClassName, szRedArmor)))
						{
							szRedArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
							bFindRedArmor = true;
						}
					}
					// End:0x595
					if(bFindBothArmor)
					{
						// End:0x592
						if(__NFUN_130__(bFindGreenArmor, bFindRedArmor))
						{
							bFind = true;
							// [Explicit Break]
							goto J0x5D0;
						}						
					}
					else
					{
						// End:0x5A9
						if(bFindGreenArmor)
						{
							bFind = true;
							// [Explicit Break]
							goto J0x5D0;
						}
					}
					ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetNextClassFromPackage());
					// [Loop Continue]
					goto J0x4A2;
				}
				J0x5D0:

				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x445;
			}
		}
	}
	J0x5DA:

	// End:0x6AB
	if(__NFUN_129__(bFind))
	{
		// End:0x648
		if(__NFUN_129__(bFindGreenArmor))
		{
			// End:0x612
			if(__NFUN_130__(bFindBothArmor, bFindRedArmor))
			{
				szGreenArmor = szRedArmor;				
			}
			else
			{
				// End:0x62C
				if(__NFUN_123__(szValidEntry, ""))
				{
					szGreenArmor = szValidEntry;					
				}
				else
				{
					szGreenArmor = "Uniform is not valid";
				}
			}
		}
		// End:0x6AB
		if(__NFUN_129__(bFindRedArmor))
		{
			// End:0x675
			if(__NFUN_130__(bFindBothArmor, bFindGreenArmor))
			{
				szRedArmor = szGreenArmor;				
			}
			else
			{
				// End:0x68F
				if(__NFUN_123__(szValidEntry, ""))
				{
					szRedArmor = szValidEntry;					
				}
				else
				{
					szRedArmor = "Uniform is not valid";
				}
			}
		}
	}
	_szGreenArmor = szGreenArmor;
	// End:0x6CD
	if(bFindBothArmor)
	{
		_szRedArmor = szRedArmor;		
	}
	else
	{
		_szRedArmor = "";
	}
	return;
}

function SetAllArmor()
{
	local int i;
	local R6WindowListBoxItemExt CurItem;
	local string szMapName, szItemGameType, szGreenArmor, szRedArmor;
	local R6MissionDescription mission;
	local R6Console R6Console;

	R6Console = R6Console(Root.Console);
	CurItem = R6WindowListBoxItemExt(m_pFinalMapList.Items.Next);
	J0x3B:

	// End:0x136 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		szMapName = CurItem.GetItemMisc(0);
		szItemGameType = CurItem.GetItemMisc(1);
		szGreenArmor = CurItem.GetItemMisc(2);
		szRedArmor = CurItem.GetItemMisc(3);
		i = 0;
		J0xA7:

		// End:0x11A [Loop If]
		if(__NFUN_150__(i, R6Console.m_aMissionDescriptions.Length))
		{
			mission = R6Console.m_aMissionDescriptions[i];
			// End:0x110
			if(__NFUN_122__(mission.m_MapName, szMapName))
			{
				mission.SetSkins(szItemGameType, szGreenArmor, szRedArmor);
			}
			__NFUN_163__(i);
			// [Loop Continue]
			goto J0xA7;
		}
		CurItem = R6WindowListBoxItemExt(CurItem.Next);
		// [Loop Continue]
		goto J0x3B;
	}
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
