//=============================================================================
// R6MenuMPAdvEquipmentDetailControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPAdvEquipmentDetailControl.uc : This control should provide functionalities
//                                      needed to select armor, weapons, bullets
//                                      gadgets for an operative for adversial multi-player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvEquipmentDetailControl extends R6MenuEquipmentDetailControl;

var int m_iLastListIndex;  // this is the last list index to know if your are in the same list
var array< Class > m_ADefaultPrimaryWeapons;  // class<R6PrimaryWeaponDescription>
var array< Class > m_ADefaultSecondaryWeapons;  // class<R6SecondaryWeaponDescription>
var array< Class > m_ADefaultGadgets;  // class<R6GadgetDescription>
var array<string> m_ADefaultWpnGadget;
var array<string> m_APriWpnGadget;  // List of available primary weapon gadgets
var array<string> m_ASecWpnGadget;  // List of available secondary weapon gadgets

function Created()
{
	local Color labelFontColor, co;
	local Texture BorderTexture;

	labelFontColor = Root.Colors.White;
	m_Title = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, m_fListBoxLabelHeight, self));
	m_Title.Align = 2;
	m_Title.m_Font = Root.Fonts[6];
	m_Title.TextColor = labelFontColor;
	m_Title.m_BGTexture = none;
	m_listBox = R6WindowTextListBox(CreateControl(Class'R6Window.R6WindowTextListBox', 0.0000000, ((m_Title.WinTop + m_Title.WinHeight) - float(1)), WinWidth, m_fListBoxHeight));
	m_listBox.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_listBox.m_VertSB.SetHideWhenDisable(true);
	m_listBox.m_Font = m_Title.m_Font;
	m_listBox.SetCornerType(0);
	m_WeaponStats = R6MenuWeaponStats(CreateWindow(Class'R6Menu.R6MenuWeaponStats', 0.0000000, (m_listBox.WinTop + m_listBox.WinHeight), WinWidth, ((WinHeight - m_listBox.WinTop) - m_listBox.WinHeight), self));
	m_WeaponStats.m_bDrawBorders = false;
	m_WeaponStats.m_bDrawBG = false;
	m_WeaponStats.HideWindow();
	m_CurrentEquipmentType = -1;
	BuildAvailableEquipment();
	m_AnchorButtons = R6MenuEquipmentAnchorButtons(CreateControl(Class'R6Menu.R6MenuEquipmentAnchorButtons', 0.0000000, 0.0000000, WinWidth, m_fAnchorAreaHeight, self));
	m_AnchorButtons.m_bDrawBorders = false;
	m_AnchorButtons.m_fPrimarWTabOffset = 3.0000000;
	m_AnchorButtons.m_fGrenadesOffset = 3.0000000;
	m_AnchorButtons.m_fPistolOffset = 3.0000000;
	m_AnchorButtons.Resize();
	m_AnchorButtons.HideWindow();
	return;
}

function R6Operative GetCurrentOperative()
{
	return R6MenuMPAdvGearWidget(OwnerWindow).m_currentOperative;
	return;
}

function Class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon()
{
	return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstWeaponDesc;
	return;
}

function Class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon()
{
	return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondaryWeaponDesc;
	return;
}

function Class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(bool _Primary)
{
	// End:0x23
	if((_Primary == true))
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstWeaponGadgetDesc;		
	}
	else
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondWeaponGadgetDesc;
	}
	return;
}

function Class<R6BulletDescription> GetCurrentWeaponBullet(bool _Primary)
{
	// End:0x23
	if((_Primary == true))
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstWeaponBulletDesc;		
	}
	else
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondWeaponBulletDesc;
	}
	return;
}

function Class<R6GadgetDescription> GetCurrentGadget(bool _Primary)
{
	// End:0x23
	if((_Primary == true))
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstGadgetDesc;		
	}
	else
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondGadgetDesc;
	}
	return;
}

function NotifyEquipmentChanged(int EquipmentSelected, Class<R6Description> DecriptionClass)
{
	R6MenuMPAdvGearWidget(OwnerWindow).EquipmentChanged(EquipmentSelected, DecriptionClass);
	return;
}

function FillListBox(int _equipmentType)
{
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6BulletDescription> WeaponBulletDescriptionClass;
	local Class<R6GadgetDescription> GadgetClass;
	local Class<R6WeaponGadgetDescription> WeaponGadgetDescriptionClass;
	local UWindowList FindItem;
	local R6WindowListBoxItem NewItem, SelectedItem, FirstInsertedItem, OldSelectedItem;
	local R6Operative currentOperative;
	local int i, j, OldVertSBPos;
	local bool bRestricted;
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	currentOperative = GetCurrentOperative();
	SelectedItem = none;
	// End:0x5F
	if((m_listBox.m_SelectedItem != none))
	{
		// End:0x5F
		if((m_iLastListIndex == _equipmentType))
		{
			OldSelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
		}
	}
	OldVertSBPos = int(m_listBox.m_VertSB.pos);
	switch(_equipmentType)
	{
		// End:0x93
		case 0:
			super.FillListBox(0);
			// End:0x6D1
			break;
		// End:0x383
		case 1:
			m_Title.SetNewText(Localize("GearRoom", "PrimaryWeaponGadget", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(3);
			PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(currentOperative.m_szPrimaryWeapon, Class'Core.Class'));
			i = 0;
			J0x116:

			// End:0x288 [Loop If]
			if((i < PrimaryWeaponClass.default.m_MyGadgets.Length))
			{
				WeaponGadgetDescriptionClass = Class<R6WeaponGadgetDescription>(PrimaryWeaponClass.default.m_MyGadgets[i]);
				bRestricted = false;
				j = 0;
				J0x15D:

				// End:0x1B9 [Loop If]
				if((j < 32))
				{
					// End:0x1AF
					if((R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgPrimaryRes[j] == WeaponGadgetDescriptionClass.default.m_NameID))
					{
						bRestricted = true;
					}
					(j++);
					// [Loop Continue]
					goto J0x15D;
				}
				// End:0x27E
				if((((WeaponGadgetDescriptionClass != Class'R6Description.R6DescWeaponGadgetNone') && WeaponGadgetDescriptionClass.default.m_bPriGadgetWAvailable) && (!bRestricted)))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
					NewItem.m_Object = WeaponGadgetDescriptionClass;
					// End:0x27E
					if((GetCurrentWeaponGadget(true) == WeaponGadgetDescriptionClass))
					{
						SelectedItem = NewItem;
					}
				}
				(i++);
				// [Loop Continue]
				goto J0x116;
			}
			m_listBox.Items.Sort();
			WeaponGadgetDescriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
			NewItem = R6WindowListBoxItem(m_listBox.Items.InsertAfter(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
			NewItem.m_Object = WeaponGadgetDescriptionClass;
			// End:0x340
			if((GetCurrentWeaponGadget(true) == WeaponGadgetDescriptionClass))
			{
				SelectedItem = NewItem;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x380
			if((SelectedItem != none))
			{
				m_listBox.SetSelectedItem(SelectedItem);
				m_listBox.MakeSelectedVisible();
			}
			// End:0x6D1
			break;
		// End:0x393
		case 2:
			super.FillListBox(2);
			// End:0x6D1
			break;
		// End:0x3A3
		case 3:
			super.FillListBox(3);
			// End:0x6D1
			break;
		// End:0x3B3
		case 4:
			super.FillListBox(4);
			// End:0x6D1
			break;
		// End:0x6A6
		case 5:
			m_Title.SetNewText(Localize("GearRoom", "SecondaryWeaponGadget", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(3);
			SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(currentOperative.m_szSecondaryWeapon, Class'Core.Class'));
			i = 0;
			J0x439:

			// End:0x5AB [Loop If]
			if((i < SecondaryWeaponClass.default.m_MyGadgets.Length))
			{
				WeaponGadgetDescriptionClass = Class<R6WeaponGadgetDescription>(SecondaryWeaponClass.default.m_MyGadgets[i]);
				bRestricted = false;
				j = 0;
				J0x480:

				// End:0x4DC [Loop If]
				if((j < 32))
				{
					// End:0x4D2
					if((R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgSecondayRes[j] == WeaponGadgetDescriptionClass.default.m_NameID))
					{
						bRestricted = true;
					}
					(j++);
					// [Loop Continue]
					goto J0x480;
				}
				// End:0x5A1
				if((((WeaponGadgetDescriptionClass != Class'R6Description.R6DescWeaponGadgetNone') && WeaponGadgetDescriptionClass.default.m_bSecGadgetWAvailable) && (!bRestricted)))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
					NewItem.m_Object = WeaponGadgetDescriptionClass;
					// End:0x5A1
					if((GetCurrentWeaponGadget(false) == WeaponGadgetDescriptionClass))
					{
						SelectedItem = NewItem;
					}
				}
				(i++);
				// [Loop Continue]
				goto J0x439;
			}
			m_listBox.Items.Sort();
			WeaponGadgetDescriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
			NewItem = R6WindowListBoxItem(m_listBox.Items.InsertAfter(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
			NewItem.m_Object = WeaponGadgetDescriptionClass;
			// End:0x663
			if((GetCurrentWeaponGadget(false) == WeaponGadgetDescriptionClass))
			{
				SelectedItem = NewItem;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x6A3
			if((SelectedItem != none))
			{
				m_listBox.SetSelectedItem(SelectedItem);
				m_listBox.MakeSelectedVisible();
			}
			// End:0x6D1
			break;
		// End:0x6B6
		case 6:
			super.FillListBox(6);
			// End:0x6D1
			break;
		// End:0x6C6
		case 7:
			super.FillListBox(7);
			// End:0x6D1
			break;
		// End:0x6CE
		case 8:
			// End:0x6D1
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x74B
	if((m_listBox.m_SelectedItem != none))
	{
		// End:0x74B
		if((R6WindowListBoxItem(m_listBox.m_SelectedItem) != OldSelectedItem))
		{
			// End:0x74B
			if((OldSelectedItem != none))
			{
				FindItem = m_listBox.FindItemWithName(OldSelectedItem.HelpText);
				// End:0x74B
				if((FindItem != none))
				{
					SelectedItem = R6WindowListBoxItem(FindItem);
				}
			}
		}
	}
	// End:0x789
	if((SelectedItem != none))
	{
		m_listBox.SetSelectedItem(SelectedItem);
		m_listBox.m_VertSB.pos = float(OldVertSBPos);
	}
	m_listBox.ShowWindow();
	m_iLastListIndex = _equipmentType;
	return;
}

function enableWeaponStats(bool _enable)
{
	// End:0x5D
	if(_enable)
	{
		m_WeaponStats.ShowWindow();
		m_listBox.SetSize(m_listBox.WinWidth, ((WinHeight - m_listBox.WinTop) - m_WeaponStats.WinHeight));		
	}
	else
	{
		m_WeaponStats.HideWindow();
		m_listBox.SetSize(m_listBox.WinWidth, (WinHeight - m_listBox.WinTop));
	}
	return;
}

//This Hides Or display Anchor buttons for equipment that support it
function UpdateAnchorButtons(R6MenuEquipmentAnchorButtons.eAnchorEquipmentType _AEType)
{
	// End:0x9B
	if((int(_AEType) == int(3)))
	{
		m_AnchorButtons.HideWindow();
		m_Title.WinTop = 0.0000000;
		m_Title.m_bDrawBorders = false;
		m_listBox.WinTop = ((m_Title.WinTop + m_Title.WinHeight) - float(1));
		m_listBox.SetSize(m_listBox.WinWidth, m_fListBoxHeight);		
	}
	else
	{
		m_AnchorButtons.ShowWindow();
		m_AnchorButtons.DisplayButtons(_AEType);
		m_Title.WinTop = (m_AnchorButtons.WinTop + m_AnchorButtons.WinHeight);
		m_Title.m_bDrawBorders = true;
		m_listBox.WinTop = ((m_Title.WinTop + m_Title.WinHeight) - float(1));
		m_listBox.SetSize(m_listBox.WinWidth, (m_fListBoxHeight - m_AnchorButtons.WinHeight));
	}
	return;
}

function BuildAvailableEquipment()
{
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6GadgetDescription> GadgetClass;
	local Class<R6WeaponGadgetDescription> WeaponGadgetClass;
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local int i, j, k;
	local bool bFound, bEquipValid;
	local R6Mod pCurrentMod;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x45
	if(((r6Root.m_R6GameMenuCom == none) || (r6Root.m_R6GameMenuCom.m_GameRepInfo == none)))
	{
		return;
	}
	m_APrimaryWeapons.Remove(0, m_APrimaryWeapons.Length);
	m_ASecondaryWeapons.Remove(0, m_ASecondaryWeapons.Length);
	m_AGadgets.Remove(0, m_AGadgets.Length);
	m_APriWpnGadget.Remove(0, m_APriWpnGadget.Length);
	m_ASecWpnGadget.Remove(0, m_ASecWpnGadget.Length);
	GetAllPrimaryWeapon();
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szSubMachineGunsRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szShotGunRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szAssRifleRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szMachGunRes, m_APrimaryWeapons);
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szSnipRifleRes, m_APrimaryWeapons);
	SortDescriptions(true, m_APrimaryWeapons, "R6Weapons");
	GetAllWeaponGadget();
	i = 0;
	J0x1A0:

	// End:0x21E [Loop If]
	if((i < 32))
	{
		j = 0;
		J0x1B3:

		// End:0x214 [Loop If]
		if((j < m_APriWpnGadget.Length))
		{
			// End:0x20A
			if((R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgPrimaryRes[i] == m_APriWpnGadget[j]))
			{
				m_APriWpnGadget.Remove(j, 1);
			}
			(j++);
			// [Loop Continue]
			goto J0x1B3;
		}
		(i++);
		// [Loop Continue]
		goto J0x1A0;
	}
	GetAllGadgets();
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgMiscRes, m_AGadgets);
	SortDescriptions(true, m_AGadgets, "R6Gadgets");
	GetAllSecondaryWeapon();
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szPistolRes, m_ASecondaryWeapons);
	CompareGearItemsWithServerRest(R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szMachPistolRes, m_ASecondaryWeapons);
	SortDescriptions(true, m_ASecondaryWeapons, "R6Weapons");
	i = 0;
	J0x2EF:

	// End:0x36D [Loop If]
	if((i < 32))
	{
		j = 0;
		J0x302:

		// End:0x363 [Loop If]
		if((j < m_ASecWpnGadget.Length))
		{
			// End:0x359
			if((R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo).m_szGadgSecondayRes[i] == m_ASecWpnGadget[j]))
			{
				m_ASecWpnGadget.Remove(j, 1);
			}
			(j++);
			// [Loop Continue]
			goto J0x302;
		}
		(i++);
		// [Loop Continue]
		goto J0x2EF;
	}
	return;
}

function CompareGearItemsWithServerRest(string _AServerRest[32], out array< Class > _AGearItems)
{
	local int i, j, iSizeOfServRestArray;
	local bool bFound;

	iSizeOfServRestArray = 32;
	i = 0;
	J0x0F:

	// End:0x9B [Loop If]
	if((i < iSizeOfServRestArray))
	{
		bFound = false;
		j = 0;
		J0x2D:

		// End:0x91 [Loop If]
		if(((j < _AGearItems.Length) && (!bFound)))
		{
			// End:0x87
			if((_AServerRest[i] == Class<R6Description>(_AGearItems[j]).default.m_NameID))
			{
				bFound = true;
				_AGearItems.Remove(j, 1);
			}
			(j++);
			// [Loop Continue]
			goto J0x2D;
		}
		(i++);
		// [Loop Continue]
		goto J0x0F;
	}
	return;
}

//===================================================================
// GetAllPrimaryWeapon: Get all the primary weapon
//===================================================================
function GetAllPrimaryWeapon()
{
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local int i;
	local bool bEquipValid;
	local int j;
	local R6Mod pCurrentMod;

	pCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod;
	// End:0xF6
	if((m_ADefaultPrimaryWeapons.Length == 0))
	{
		i = 0;
		j = 0;
		J0x35:

		// End:0xF3 [Loop If]
		if((j < pCurrentMod.m_aDescriptionPackage.Length))
		{
			PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[j] $ ".u"), Class'R6Description.R6PrimaryWeaponDescription'));
			J0x7B:

			// End:0xE6 [Loop If]
			if((PrimaryWeaponClass != none))
			{
				bEquipValid = (PrimaryWeaponClass.default.m_NameID != "NONE");
				// End:0xD5
				if(bEquipValid)
				{
					m_APrimaryWeapons[i] = PrimaryWeaponClass;
					m_ADefaultPrimaryWeapons[i] = PrimaryWeaponClass;
					(i++);
				}
				PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(GetNextClass());
				// [Loop Continue]
				goto J0x7B;
			}
			FreePackageObjects();
			(j++);
			// [Loop Continue]
			goto J0x35;
		}		
	}
	else
	{
		i = 0;
		J0xFD:

		// End:0x12E [Loop If]
		if((i < m_ADefaultPrimaryWeapons.Length))
		{
			m_APrimaryWeapons[i] = m_ADefaultPrimaryWeapons[i];
			(i++);
			// [Loop Continue]
			goto J0xFD;
		}
	}
	return;
}

//===================================================================
// GetAllSecondaryWeapon: Get all the secondary weapon
//===================================================================
function GetAllSecondaryWeapon()
{
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local int i;
	local bool bEquipValid;
	local int j;
	local R6Mod pCurrentMod;

	pCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod;
	// End:0xF6
	if((m_ADefaultSecondaryWeapons.Length == 0))
	{
		i = 0;
		j = 0;
		J0x35:

		// End:0xF3 [Loop If]
		if((j < pCurrentMod.m_aDescriptionPackage.Length))
		{
			SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[j] $ ".u"), Class'R6Description.R6SecondaryWeaponDescription'));
			J0x7B:

			// End:0xE6 [Loop If]
			if((SecondaryWeaponClass != none))
			{
				bEquipValid = (SecondaryWeaponClass.default.m_NameID != "NONE");
				// End:0xD5
				if(bEquipValid)
				{
					m_ASecondaryWeapons[i] = SecondaryWeaponClass;
					m_ADefaultSecondaryWeapons[i] = SecondaryWeaponClass;
					(i++);
				}
				SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(GetNextClass());
				// [Loop Continue]
				goto J0x7B;
			}
			FreePackageObjects();
			(j++);
			// [Loop Continue]
			goto J0x35;
		}		
	}
	else
	{
		i = 0;
		J0xFD:

		// End:0x12E [Loop If]
		if((i < m_ADefaultSecondaryWeapons.Length))
		{
			m_ASecondaryWeapons[i] = m_ADefaultSecondaryWeapons[i];
			(i++);
			// [Loop Continue]
			goto J0xFD;
		}
	}
	return;
}

//===================================================================
// GetAllGadgets: Get all gadgets
//===================================================================
function GetAllGadgets()
{
	local Class<R6GadgetDescription> GadgetClass;
	local int i;
	local bool bEquipValid;
	local int j;
	local R6Mod pCurrentMod;

	pCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod;
	// End:0xF6
	if((m_ADefaultGadgets.Length == 0))
	{
		i = 0;
		j = 0;
		J0x35:

		// End:0xF3 [Loop If]
		if((j < pCurrentMod.m_aDescriptionPackage.Length))
		{
			GadgetClass = Class<R6GadgetDescription>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[j] $ ".u"), Class'R6Description.R6GadgetDescription'));
			J0x7B:

			// End:0xE6 [Loop If]
			if((GadgetClass != none))
			{
				bEquipValid = (GadgetClass.default.m_NameID != "NONE");
				// End:0xD5
				if(bEquipValid)
				{
					m_AGadgets[i] = GadgetClass;
					m_ADefaultGadgets[i] = GadgetClass;
					(i++);
				}
				GadgetClass = Class<R6GadgetDescription>(GetNextClass());
				// [Loop Continue]
				goto J0x7B;
			}
			FreePackageObjects();
			(j++);
			// [Loop Continue]
			goto J0x35;
		}		
	}
	else
	{
		i = 0;
		J0xFD:

		// End:0x12E [Loop If]
		if((i < m_ADefaultGadgets.Length))
		{
			m_AGadgets[i] = m_ADefaultGadgets[i];
			(i++);
			// [Loop Continue]
			goto J0xFD;
		}
	}
	return;
}

//===================================================================
// GetAllPrimaryWeaponGadget: Get All Primary Weapon Gadget
//===================================================================
function GetAllWeaponGadget()
{
	local Class<R6WeaponGadgetDescription> WeaponGadgetClass;
	local array<string> ATemp;
	local int i, k;
	local bool bEquipValid, bFound;
	local int j;
	local R6Mod pCurrentMod;

	pCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod;
	// End:0x1E3
	if((m_ADefaultWpnGadget.Length == 0))
	{
		WeaponGadgetClass = Class'R6Description.R6DescWeaponGadgetNone';
		m_APriWpnGadget[0] = WeaponGadgetClass.default.m_NameID;
		m_ASecWpnGadget[0] = WeaponGadgetClass.default.m_NameID;
		m_ADefaultWpnGadget[0] = m_APriWpnGadget[0];
		i = 1;
		j = 0;
		J0x7B:

		// End:0x1E0 [Loop If]
		if((j < pCurrentMod.m_aDescriptionPackage.Length))
		{
			WeaponGadgetClass = Class<R6WeaponGadgetDescription>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[j] $ ".u"), Class'R6Description.R6WeaponGadgetDescription'));
			J0xC1:

			// End:0x1D3 [Loop If]
			if((WeaponGadgetClass != none))
			{
				bEquipValid = ((WeaponGadgetClass.default.m_NameID != "NONE") && WeaponGadgetClass.default.m_bPriGadgetWAvailable);
				// End:0x1C2
				if(bEquipValid)
				{
					bFound = false;
					k = 0;
					J0x115:

					// End:0x162 [Loop If]
					if(((k < m_APriWpnGadget.Length) && (!bFound)))
					{
						// End:0x158
						if((WeaponGadgetClass.default.m_NameID == m_APriWpnGadget[k]))
						{
							bFound = true;
						}
						(k++);
						// [Loop Continue]
						goto J0x115;
					}
					// End:0x1C2
					if((!bFound))
					{
						m_APriWpnGadget[i] = WeaponGadgetClass.default.m_NameID;
						m_ASecWpnGadget[i] = WeaponGadgetClass.default.m_NameID;
						m_ADefaultWpnGadget[i] = WeaponGadgetClass.default.m_NameID;
						(i++);
					}
				}
				WeaponGadgetClass = Class<R6WeaponGadgetDescription>(GetNextClass());
				// [Loop Continue]
				goto J0xC1;
			}
			FreePackageObjects();
			(j++);
			// [Loop Continue]
			goto J0x7B;
		}		
	}
	else
	{
		i = 0;
		J0x1EA:

		// End:0x232 [Loop If]
		if((i < m_ADefaultWpnGadget.Length))
		{
			m_APriWpnGadget[i] = m_ADefaultWpnGadget[i];
			m_ASecWpnGadget[i] = m_ADefaultWpnGadget[i];
			(i++);
			// [Loop Continue]
			goto J0x1EA;
		}
	}
	return;
}

defaultproperties
{
	m_iLastListIndex=-1
	m_bDrawListBg=false
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function IsEquipmentAvailable
