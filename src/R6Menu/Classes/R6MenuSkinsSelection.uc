//=============================================================================
// R6MenuSkinsSelection - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuSkinsSelection extends UWindowDialogClientWindow;

const C_fY_START_TEXT = 15;
const C_fY_START = 40;
const C_fWIDTH = 140;
const C_fWIDTH_OF_ARMOR_W = 160;
const C_fHEIGHT_OF_ARMOR_IMAGE = 245;
const C_iMAX_MAPLIST_SIZE = 32;
const C_MAP_INDEX = 0;
const C_GAME_TYPE_INDEX = 1;
const C_GREEN_ARMOR_INDEX = 2;
const C_RED_ARMOR_INDEX = 3;

struct ArmorInfo
{
	var Class armorClass;
	var string szArmorPkg;
};

var bool m_bFirstDisplay;
var R6WindowTextLabelExt m_pTextInfo;
var R6WindowTextListBoxExt m_pMapList;
var R6WindowTextListBox m_ArmorListBox;
var R6MenuMPArmor m_2DArmor;
var Class<R6ArmorDescription> m_GreenArmorDesc;
var Class<R6ArmorDescription> m_RedArmorDesc;
var array<ArmorInfo> m_AArmors;

function Created()
{
	local float fXPos, fXStep;

	fXStep = __NFUN_171__(__NFUN_175__(__NFUN_175__(WinWidth, float(__NFUN_144__(2, 140))), float(160)), 0.2500000);
	m_pTextInfo = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, WinWidth, WinHeight, self));
	m_pTextInfo.bAlwaysBehind = true;
	m_pTextInfo.SetNoBorder();
	m_pTextInfo.m_Font = Root.Fonts[5];
	fXPos = fXStep;
	m_pTextInfo.m_vTextColor = Root.Colors.White;
	m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_Map", "R6Menu"), fXPos, 15.0000000, 140.0000000, 2, false);
	m_pMapList = R6WindowTextListBoxExt(CreateControl(Class'R6Window.R6WindowTextListBoxExt', fXPos, 40.0000000, 140.0000000, 245.0000000, self));
	m_pMapList.TextColor = Root.Colors.BlueLight;
	m_pMapList.SetCornerType(0);
	m_pMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
	fXPos = __NFUN_174__(__NFUN_174__(fXPos, float(140)), fXStep);
	m_pTextInfo.m_vTextColor = Root.Colors.BlueLight;
	m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Teams", "R6Menu"), fXPos, 15.0000000, 160.0000000, 2, false);
	m_2DArmor = R6MenuMPArmor(CreateControl(Class'R6Menu.R6MenuMPArmor', fXPos, 40.0000000, 160.0000000, 245.0000000, self));
	fXPos = __NFUN_174__(__NFUN_174__(fXPos, float(160)), fXStep);
	m_pTextInfo.m_vTextColor = Root.Colors.White;
	m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_UniformSelect", "R6Menu"), fXPos, 15.0000000, 140.0000000, 2, false);
	m_ArmorListBox = R6WindowTextListBox(CreateControl(Class'R6Window.R6WindowTextListBox', fXPos, 40.0000000, 140.0000000, 245.0000000, self));
	m_ArmorListBox.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_ArmorListBox.m_VertSB.SetHideWhenDisable(true);
	m_ArmorListBox.m_Font = Root.Fonts[6];
	m_ArmorListBox.SetCornerType(0);
	m_ArmorListBox.SetOverBorderColorEffect(Root.Colors.GrayLight);
	m_ArmorListBox.m_fSpaceBetItem = 0.0000000;
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	m_bFirstDisplay = true;
	FirstDisplay();
	m_bFirstDisplay = false;
	return;
}

function FirstDisplay()
{
	// End:0x5E
	if(__NFUN_114__(m_pMapList.GetSelectedItem(), none))
	{
		// End:0x5E
		if(__NFUN_151__(m_pMapList.Items.Count(), 0))
		{
			m_pMapList.SetSelectedItem(UWindowListBoxItem(m_pMapList.Items.Next));
		}
	}
	m_pMapList.MakeSelectedVisible();
	m_2DArmor.SetHighLightGreenArmor(true);
	m_2DArmor.SetHighLightRedArmor(false);
	FillArmorList();
	UpdateImages();
	return;
}

function UpdateImages()
{
	local Region R;
	local string szTemp;

	// End:0xFB
	if(__NFUN_119__(m_ArmorListBox.GetSelectedItem(), none))
	{
		m_2DArmor.SetArmorTexture(m_GreenArmorDesc.default.m_2DMenuTexture, m_GreenArmorDesc.default.m_2dMenuRegion, false);
		szTemp = R6WindowListBoxItemExt(m_pMapList.GetSelectedItem()).m_AItemDesc[1].szText;
		// End:0xD4
		if(GetLevel().IsGameTypeTeamAdversarial(GetLevel().GetGameTypeFromLocName(szTemp, true)))
		{
			m_2DArmor.SetArmorTexture(m_RedArmorDesc.default.m_2DMenuTexture, m_RedArmorDesc.default.m_2dMenuRegion, true);
			m_2DArmor.SetButtonsStatus(false, true);			
		}
		else
		{
			m_2DArmor.SetArmorTexture(none, R, true);
			m_2DArmor.SetButtonsStatus(true, true);
		}
	}
	return;
}

function FillArmorList()
{
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local R6WindowListBoxItem NewItem, GreenItem, RedItem;
	local R6WindowListBoxItemExt MapListItem;
	local string szTemp;
	local int i;

	BuildAvailableMissionArmors();
	// End:0x289
	if(__NFUN_119__(m_ArmorListBox, none))
	{
		m_ArmorListBox.Clear();
		m_GreenArmorDesc = none;
		m_RedArmorDesc = none;
		MapListItem = R6WindowListBoxItemExt(m_pMapList.GetSelectedItem());
		i = 0;
		J0x4F:

		// End:0x19E [Loop If]
		if(__NFUN_150__(i, m_AArmors.Length))
		{
			ArmorDescriptionClass = Class<R6ArmorDescription>(m_AArmors[i].armorClass);
			NewItem = R6WindowListBoxItem(m_ArmorListBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
			NewItem.m_szMisc = m_AArmors[i].szArmorPkg;
			NewItem.m_Object = ArmorDescriptionClass;
			szTemp = MapListItem.GetItemText(2);
			// End:0x14F
			if(__NFUN_122__(szTemp, NewItem.HelpText))
			{
				m_GreenArmorDesc = ArmorDescriptionClass;
				GreenItem = NewItem;
			}
			szTemp = MapListItem.GetItemText(3);
			// End:0x194
			if(__NFUN_122__(szTemp, NewItem.HelpText))
			{
				m_RedArmorDesc = ArmorDescriptionClass;
				RedItem = NewItem;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x4F;
		}
		// End:0x1FC
		if(__NFUN_122__(MapListItem.GetItemText(3), ""))
		{
			// End:0x1FC
			if(m_2DArmor.IsRedArmorSelect())
			{
				m_2DArmor.SetHighLightGreenArmor(true);
				m_2DArmor.SetHighLightRedArmor(false);
				m_ArmorListBox.SetSelectedItem(GreenItem);
			}
		}
		// End:0x27A
		if(__NFUN_114__(m_ArmorListBox.GetSelectedItem(), none))
		{
			// End:0x247
			if(__NFUN_130__(__NFUN_119__(GreenItem, none), m_2DArmor.IsGreenArmorSelect()))
			{
				m_ArmorListBox.SetSelectedItem(GreenItem);				
			}
			else
			{
				// End:0x27A
				if(__NFUN_130__(__NFUN_119__(RedItem, none), m_2DArmor.IsRedArmorSelect()))
				{
					m_ArmorListBox.SetSelectedItem(RedItem);
				}
			}
		}
		m_ArmorListBox.MakeSelectedVisible();
	}
	return;
}

function BuildAvailableMissionArmors()
{
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local R6MissionDescription CurrentMission;
	local R6Console R6Console;
	local ArmorInfo pArmorInfo;
	local array< Class > AArmors;
	local string szTemp;
	local int i, j, nbArmor;
	local bool bFind;
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.__NFUN_1524__();
	R6Console = R6Console(Root.Console);
	m_AArmors.Remove(0, m_AArmors.Length);
	i = 0;
	J0x3F:

	// End:0xED [Loop If]
	if(__NFUN_150__(i, R6Console.m_aMissionDescriptions.Length))
	{
		CurrentMission = R6Console.m_aMissionDescriptions[i];
		// End:0x80
		if(__NFUN_114__(CurrentMission, none))
		{
			// [Explicit Break]
			goto J0xED;
		}
		// End:0xAA
		if(__NFUN_129__(Root.GetMapNameLocalisation(CurrentMission.m_MapName, szTemp)))
		{
			// [Explicit Continue]
			goto J0xE3;
		}
		// End:0xE3
		if(__NFUN_122__(szTemp, R6WindowListBoxItemExt(m_pMapList.GetSelectedItem()).m_AItemDesc[0].szText))
		{
			bFind = true;
			// [Explicit Break]
			goto J0xED;
		}
		J0xE3:

		__NFUN_163__(i);
		// [Loop Continue]
		goto J0x3F;
	}
	J0xED:

	// End:0x32B
	if(bFind)
	{
		nbArmor = 0;
		j = 0;
		J0x104:

		// End:0x1B6 [Loop If]
		if(__NFUN_150__(j, pModManager.m_pCurrentMod.m_aDescriptionPackage.Length))
		{
			ArmorDescriptionClass = Class<R6ArmorDescription>(__NFUN_1005__(__NFUN_112__(pModManager.m_pCurrentMod.m_aDescriptionPackage[j], ".u"), Class'R6Description.R6ArmorDescription'));
			J0x15C:

			// End:0x1A9 [Loop If]
			if(__NFUN_119__(ArmorDescriptionClass, none))
			{
				// End:0x198
				if(__NFUN_123__(ArmorDescriptionClass.default.m_NameID, "NONE"))
				{
					AArmors[nbArmor] = ArmorDescriptionClass;
					__NFUN_165__(nbArmor);
				}
				ArmorDescriptionClass = Class<R6ArmorDescription>(__NFUN_1006__());
				// [Loop Continue]
				goto J0x15C;
			}
			__NFUN_1007__();
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x104;
		}
		// End:0x297
		if(__NFUN_242__(pModManager.m_pCurrentMod.m_bUseCustomOperatives, true))
		{
			j = 0;
			J0x1DB:

			// End:0x297 [Loop If]
			if(__NFUN_150__(j, pModManager.GetPackageMgr().GetNbPackage()))
			{
				ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(j, Class'R6Description.R6ArmorDescription'));
				J0x22C:

				// End:0x28D [Loop If]
				if(__NFUN_130__(__NFUN_119__(ArmorDescriptionClass, none), __NFUN_242__(ArmorDescriptionClass.default.m_bHideFromMenu, false)))
				{
					AArmors[nbArmor] = ArmorDescriptionClass;
					__NFUN_165__(nbArmor);
					ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetNextClassFromPackage());
					// [Loop Continue]
					goto J0x22C;
				}
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x1DB;
			}
		}
		Class'R6Menu.R6MenuEquipmentDetailControl'.static.SortDescriptions(true, AArmors, "R6Armor", true);
		j = 0;
		J0x2BD:

		// End:0x32B [Loop If]
		if(__NFUN_150__(j, nbArmor))
		{
			pArmorInfo.armorClass = AArmors[j];
			ArmorDescriptionClass = Class<R6ArmorDescription>(pArmorInfo.armorClass);
			pArmorInfo.szArmorPkg = ArmorDescriptionClass.default.m_ClassName;
			m_AArmors[j] = pArmorInfo;
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x2BD;
		}
	}
	return;
}

function CopyAllValues(R6MenuMapListExt _pMyList)
{
	local R6WindowListBoxItemExt CurItem, CreateItem, FoundItem;
	local bool Found;

	m_pMapList.DropSelection();
	m_pMapList.Items.Clear();
	CurItem = R6WindowListBoxItemExt(_pMyList.m_pFinalMapList.Items.Next);
	J0x52:

	// End:0x148 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		Found = false;
		FoundItem = R6WindowListBoxItemExt(m_pMapList.Items.Next);
		J0x87:

		// End:0xC9 [Loop If]
		if(__NFUN_119__(FoundItem, none))
		{
			// End:0xAD
			if(SameSkins(FoundItem, CurItem))
			{
				Found = true;
			}
			FoundItem = R6WindowListBoxItemExt(FoundItem.Next);
			// [Loop Continue]
			goto J0x87;
		}
		CreateItem = CopyItemInList(CurItem, m_pMapList);
		// End:0x12C
		if(__NFUN_130__(__NFUN_114__(m_pMapList.GetSelectedItem(), none), __NFUN_114__(_pMyList.m_pFinalMapList.GetSelectedItem(), CurItem)))
		{
			m_pMapList.SetSelectedItem(CreateItem);
		}
		CurItem = R6WindowListBoxItemExt(CurItem.Next);
		// [Loop Continue]
		goto J0x52;
	}
	return;
}

function GetAllValues(out R6MenuMapListExt _pMyList)
{
	local R6WindowListBoxItemExt CurItem;

	_pMyList.m_pFinalMapList.Items.Clear();
	CurItem = R6WindowListBoxItemExt(m_pMapList.Items.Next);
	J0x43:

	// End:0x83 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		CopyItemInList(CurItem, _pMyList.m_pFinalMapList);
		CurItem = R6WindowListBoxItemExt(CurItem.Next);
		// [Loop Continue]
		goto J0x43;
	}
	return;
}

function R6WindowListBoxItemExt CopyItemInList(R6WindowListBoxItemExt _ItemToAdd, UWindowListControl _ListAddItem)
{
	local R6WindowListBoxItemExt NewItem;
	local stItemDesc ItemDesc;
	local int i;

	// End:0x208
	if(__NFUN_150__(_ListAddItem.Items.Count(), 32))
	{
		NewItem = R6WindowListBoxItemExt(_ListAddItem.Items.Append(_ListAddItem.ListClass));
		i = 0;
		J0x57:

		// End:0x208 [Loop If]
		if(__NFUN_150__(i, _ItemToAdd.m_AItemDesc.Length))
		{
			ItemDesc.szText = _ItemToAdd.m_AItemDesc[i].szText;
			ItemDesc.szMisc = _ItemToAdd.m_AItemDesc[i].szMisc;
			ItemDesc.TextFont = _ItemToAdd.m_AItemDesc[i].TextFont;
			ItemDesc.fXPos = _ItemToAdd.m_AItemDesc[i].fXPos;
			ItemDesc.fYPos = _ItemToAdd.m_AItemDesc[i].fYPos;
			ItemDesc.fWidth = _ItemToAdd.m_AItemDesc[i].fWidth;
			ItemDesc.fHeigth = _ItemToAdd.m_AItemDesc[i].fHeigth;
			ItemDesc.iLineNumber = _ItemToAdd.m_AItemDesc[i].iLineNumber;
			ItemDesc.eAlignment = _ItemToAdd.m_AItemDesc[i].eAlignment;
			ItemDesc.bDisplay = _ItemToAdd.m_AItemDesc[i].bDisplay;
			NewItem.m_AItemDesc[NewItem.m_AItemDesc.Length] = ItemDesc;
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x57;
		}
	}
	return NewItem;
	return;
}

function SetButtonRegion(bool _bInverseTex)
{
	return;
	return;
}

function bool SameSkins(R6WindowListBoxItemExt Item1, R6WindowListBoxItemExt Item2)
{
	// End:0x4C
	if(__NFUN_122__(Item1.GetItemMisc(0), Item2.GetItemMisc(0)))
	{
		// End:0x4C
		if(__NFUN_122__(Item1.GetItemMisc(1), Item2.GetItemMisc(1)))
		{
			return true;
		}
	}
	return false;
	return;
}

function ChangeCurrentMapSkin(int Skin)
{
	local R6WindowListBoxItemExt CurItem, SelItem;

	SelItem = R6WindowListBoxItemExt(m_pMapList.GetSelectedItem());
	CurItem = R6WindowListBoxItemExt(m_pMapList.Items.Next);
	J0x3C:

	// End:0xD3 [Loop If]
	if(__NFUN_119__(CurItem, none))
	{
		// End:0xB7
		if(SameSkins(SelItem, CurItem))
		{
			CurItem.SetItemText(Skin, m_ArmorListBox.GetSelectedItem().HelpText);
			CurItem.SetItemMisc(Skin, R6WindowListBoxItem(m_ArmorListBox.GetSelectedItem()).m_szMisc);
		}
		CurItem = R6WindowListBoxItemExt(CurItem.Next);
		// [Loop Continue]
		goto J0x3C;
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local string szTemp;

	// End:0x0B
	if(m_bFirstDisplay)
	{
		return;
	}
	// End:0xF2
	if(C.__NFUN_303__('R6WindowButtonGear'))
	{
		switch(E)
		{
			// End:0xA7
			case 2:
				m_2DArmor.SetHighLightGreenArmor(false);
				m_2DArmor.SetHighLightRedArmor(false);
				// End:0x76
				if(__NFUN_114__(C, m_2DArmor.m_2DArmor))
				{
					m_2DArmor.SetHighLightGreenArmor(true);					
				}
				else
				{
					// End:0x9E
					if(__NFUN_114__(C, m_2DArmor.m_2DArmorRed))
					{
						m_2DArmor.SetHighLightRedArmor(true);
					}
				}
				FillArmorList();
				// End:0xEF
				break;
			// End:0xC8
			case 12:
				m_2DArmor.SetArmorBorderColor(C, E);
				// End:0xEF
				break;
			// End:0xE9
			case 9:
				m_2DArmor.SetArmorBorderColor(C, E);
				// End:0xEF
				break;
			// End:0xFFFF
			default:
				// End:0xEF
				break;
				break;
		}		
	}
	else
	{
		// End:0x148
		if(C.__NFUN_303__('R6WindowTextListBoxExt'))
		{
			// End:0x145
			if(__NFUN_132__(__NFUN_154__(int(E), 2), __NFUN_154__(int(E), 11)))
			{
				// End:0x145
				if(__NFUN_119__(m_pMapList.GetSelectedItem(), none))
				{
					FillArmorList();
					UpdateImages();
				}
			}			
		}
		else
		{
			// End:0x231
			if(C.__NFUN_303__('R6WindowTextListBox'))
			{
				// End:0x231
				if(__NFUN_132__(__NFUN_154__(int(E), 2), __NFUN_154__(int(E), 11)))
				{
					// End:0x231
					if(__NFUN_119__(m_ArmorListBox.GetSelectedItem(), none))
					{
						// End:0x231
						if(__NFUN_119__(m_pMapList.GetSelectedItem(), none))
						{
							// End:0x1E9
							if(m_2DArmor.IsGreenArmorSelect())
							{
								m_GreenArmorDesc = Class<R6ArmorDescription>(R6WindowListBoxItem(m_ArmorListBox.GetSelectedItem()).m_Object);
								ChangeCurrentMapSkin(2);								
							}
							else
							{
								// End:0x22B
								if(m_2DArmor.IsRedArmorSelect())
								{
									m_RedArmorDesc = Class<R6ArmorDescription>(R6WindowListBoxItem(m_ArmorListBox.GetSelectedItem()).m_Object);
									ChangeCurrentMapSkin(3);
								}
							}
							UpdateImages();
						}
					}
				}
			}
		}
	}
	return;
}
