//=============================================================================
// R6MenuGearWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuGearWidget.uc : GearRoomMenu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearWidget extends R6MenuLaptopWidget;

enum e2DEquipment
{
	Primary_Weapon,                 // 0
	Primary_WeaponGadget,           // 1
	Primary_Bullet,                 // 2
	Primary_Gadget,                 // 3
	Secondary_Weapon,               // 4
	Secondary_WeaponGadget,         // 5
	Secondary_Bullet,               // 6
	Secondary_Gadget,               // 7
	Armor,                          // 8
	All_Primary,                    // 9
	All_Secondary,                  // 10
	All_PrimaryGadget,              // 11
	All_SecondaryGadget,            // 12
	All_Armor,                      // 13
	All_ToAll                       // 14
};

enum eOperativeTeam
{
	Red_Team,                       // 0
	Green_Team,                     // 1
	Gold_Team,                      // 2
	No_Team                         // 3
};

var R6MenuGearWidget.eOperativeTeam m_currentOperativeTeam;  // list in witch the current operative has been added
var int m_IRosterListLeftPad;
var bool bShowLog;  // debug
var float m_fPaddingBetweenElements;
var R6WindowTextLabel m_CodeName;
// NEW IN 1.60
var R6WindowTextLabel m_DateTime;
// NEW IN 1.60
var R6WindowTextLabel m_Location;
var Font m_labelFont;
var R6MenuDynTeamListsControl m_RosterListCtrl;  // Lists on the left of the menu
var R6MenuOperativeDetailControl m_OperativeDetails;  // Right side when looking at an operative details
var R6MenuEquipmentSelectControl m_Equipment2dSelect;  // Middle part where we can take a look a selected equipment
var R6MenuEquipmentDetailControl m_EquipmentDetails;  // Right side when looking at an equipment item
var R6Operative m_currentOperative;  // Current Selected Operative
var R6DescPrimaryMags m_PrimaryMagsGadget;
var Class<R6PrimaryWeaponDescription> m_OpFirstWeaponDesc;  // Equipment of the selected Operative
var Class<R6SecondaryWeaponDescription> m_OpSecondaryWeaponDesc;
var Class<R6WeaponGadgetDescription> m_OpFirstWeaponGadgetDesc;
// NEW IN 1.60
var Class<R6WeaponGadgetDescription> m_OpSecondWeaponGadgetDesc;
var Class<R6BulletDescription> m_OpFirstWeaponBulletDesc;
// NEW IN 1.60
var Class<R6BulletDescription> m_OpSecondWeaponBulletDesc;
var Class<R6GadgetDescription> m_OpFirstGadgetDesc;
// NEW IN 1.60
var Class<R6GadgetDescription> m_OpSecondGadgetDesc;
var Class<R6ArmorDescription> m_OpArmorDesc;

function Created()
{
	local int labelWidth;
	local Region R;
	local int i, j;
	local R6Mod pCurrentMod;
	local Class<R6DescPrimaryMags> ExtraMags;

	super.Created();
	m_labelFont = Root.Fonts[9];
	labelWidth = (int((m_Right.WinLeft - m_Left.WinWidth)) / 3);
	labelWidth = (int((m_Right.WinLeft - m_Left.WinWidth)) / 3);
	m_CodeName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_Left.WinWidth, m_Top.WinHeight, float(labelWidth), 18.0000000, self));
	m_DateTime = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_CodeName.WinLeft + m_CodeName.WinWidth), m_Top.WinHeight, float(labelWidth), 18.0000000, self));
	m_Location = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_DateTime.WinLeft + m_DateTime.WinWidth), m_Top.WinHeight, m_DateTime.WinWidth, 18.0000000, self));
	m_RosterListCtrl = R6MenuDynTeamListsControl(CreateWindow(Class'R6Menu.R6MenuDynTeamListsControl', (m_Left.WinWidth + float(m_IRosterListLeftPad)), (m_CodeName.WinTop + m_CodeName.WinHeight), 199.0000000, ((m_HelpTextBar.WinTop - (m_CodeName.WinTop + m_CodeName.WinHeight)) - float(2)), self));
	m_OperativeDetails = R6MenuOperativeDetailControl(CreateWindow(Class'R6Menu.R6MenuOperativeDetailControl', 430.0000000, m_RosterListCtrl.WinTop, 189.0000000, 339.0000000, self));
	m_OperativeDetails.HideWindow();
	m_EquipmentDetails = R6MenuEquipmentDetailControl(CreateWindow(Class'R6Menu.R6MenuEquipmentDetailControl', 430.0000000, m_RosterListCtrl.WinTop, 189.0000000, 339.0000000, self));
	m_EquipmentDetails.HideWindow();
	m_Equipment2dSelect = R6MenuEquipmentSelectControl(CreateWindow(Class'R6Menu.R6MenuEquipmentSelectControl', 222.0000000, m_RosterListCtrl.WinTop, 206.0000000, 339.0000000, self));
	m_NavBar.m_GearButton.bDisabled = true;
	m_PrimaryMagsGadget = new (none) Class'R6Description.R6DescPrimaryMags';
	pCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod;
	i = 0;
	J0x2DF:

	// End:0x402 [Loop If]
	if((i < pCurrentMod.m_aDescriptionPackage.Length))
	{
		// End:0x3F8
		if((pCurrentMod.m_aDescriptionPackage[i] != "R6Description"))
		{
			ExtraMags = Class<R6DescPrimaryMags>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[i] $ ".u"), Class'R6Description.R6DescPrimaryMags'));
			J0x34D:

			// End:0x3F8 [Loop If]
			if((ExtraMags != none))
			{
				j = 0;
				J0x35F:

				// End:0x3E7 [Loop If]
				if((j < ExtraMags.default.m_iNewTagsToAdd))
				{
					m_PrimaryMagsGadget.m_Mags[m_PrimaryMagsGadget.m_Mags.Length] = ExtraMags.default.m_Mags[j];
					m_PrimaryMagsGadget.m_MagTags[m_PrimaryMagsGadget.m_MagTags.Length] = ExtraMags.default.m_MagTags[j];
					(j++);
					// [Loop Continue]
					goto J0x35F;
				}
				ExtraMags = Class<R6DescPrimaryMags>(GetNextClass());
				// [Loop Continue]
				goto J0x34D;
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x2DF;
	}
	return;
}

function ShowWindow()
{
	local R6GameOptions pGameOptions;

	super(UWindowWindow).ShowWindow();
	// End:0x72
	if((R6MenuRootWindow(Root).m_bPlayerPlanInitialized == false))
	{
		pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
		// End:0x72
		if((pGameOptions.PopUpLoadPlan == true))
		{
			R6MenuRootWindow(Root).m_ePopUpID = 48;
			R6MenuRootWindow(Root).PopUpMenu(true);
		}
	}
	return;
}

function Reset()
{
	local R6MissionDescription CurrentMission;

	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	m_CodeName.SetProperties(Localize(CurrentMission.m_MapName, "ID_CODENAME", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_DateTime.SetProperties(Localize(CurrentMission.m_MapName, "ID_DATETIME", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_Location.SetProperties(Localize(CurrentMission.m_MapName, "ID_LOCATION", CurrentMission.LocalizationFile), 2, m_labelFont, Root.Colors.White, false);
	m_EquipmentDetails.BuildAvailableMissionArmors();
	m_RosterListCtrl.FillRosterList();
	return;
}

function OperativeSelected(R6Operative selectedOperative, R6MenuGearWidget.eOperativeTeam _selectedTeam, optional UWindowWindow _pActiveWindow)
{
	m_EquipmentDetails.HideWindow();
	m_currentOperative = selectedOperative;
	m_OpFirstWeaponDesc = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(m_currentOperative.m_szPrimaryWeapon, Class'Core.Class'));
	// End:0x8A
	if((m_OpFirstWeaponDesc == none))
	{
		m_OpFirstWeaponDesc = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(m_currentOperative.default.m_szPrimaryWeapon, Class'Core.Class'));
		m_currentOperative.m_szPrimaryWeapon = m_currentOperative.default.m_szPrimaryWeapon;
	}
	m_OpFirstWeaponGadgetDesc = Class'R6Description.R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponGadget);
	// End:0x102
	if((m_OpFirstWeaponGadgetDesc == none))
	{
		m_OpFirstWeaponGadgetDesc = Class'R6Description.R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(m_OpFirstWeaponDesc, m_currentOperative.default.m_szPrimaryWeaponGadget);
		m_currentOperative.m_szPrimaryWeaponGadget = m_currentOperative.default.m_szPrimaryWeaponGadget;
	}
	m_OpFirstWeaponBulletDesc = Class'R6Description.R6DescriptionManager'.static.GetPrimaryBulletDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponBullet);
	// End:0x17A
	if((m_OpFirstWeaponBulletDesc == none))
	{
		m_OpFirstWeaponBulletDesc = Class'R6Description.R6DescriptionManager'.static.GetPrimaryBulletDesc(m_OpFirstWeaponDesc, m_currentOperative.default.m_szPrimaryWeaponBullet);
		m_currentOperative.m_szPrimaryWeaponBullet = m_currentOperative.default.m_szPrimaryWeaponBullet;
	}
	m_OpSecondaryWeaponDesc = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(m_currentOperative.m_szSecondaryWeapon, Class'Core.Class'));
	// End:0x1EA
	if((m_OpSecondaryWeaponDesc == none))
	{
		m_OpSecondaryWeaponDesc = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(m_currentOperative.default.m_szSecondaryWeapon, Class'Core.Class'));
		m_currentOperative.m_szSecondaryWeapon = m_currentOperative.default.m_szSecondaryWeapon;
	}
	m_OpSecondWeaponGadgetDesc = Class'R6Description.R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponGadget);
	// End:0x262
	if((m_OpSecondWeaponGadgetDesc == none))
	{
		m_OpSecondWeaponGadgetDesc = Class'R6Description.R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(m_OpSecondaryWeaponDesc, m_currentOperative.default.m_szSecondaryWeaponGadget);
		m_currentOperative.m_szSecondaryWeaponGadget = m_currentOperative.default.m_szSecondaryWeaponGadget;
	}
	m_OpSecondWeaponBulletDesc = Class'R6Description.R6DescriptionManager'.static.GetSecondaryBulletDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponBullet);
	// End:0x2DA
	if((m_OpSecondWeaponBulletDesc == none))
	{
		m_OpSecondWeaponBulletDesc = Class'R6Description.R6DescriptionManager'.static.GetSecondaryBulletDesc(m_OpSecondaryWeaponDesc, m_currentOperative.default.m_szSecondaryWeaponBullet);
		m_currentOperative.m_szSecondaryWeaponBullet = m_currentOperative.default.m_szSecondaryWeaponBullet;
	}
	m_OpFirstGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.m_szPrimaryGadget, Class'Core.Class'));
	// End:0x34A
	if((m_OpFirstGadgetDesc == none))
	{
		m_OpFirstGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.default.m_szPrimaryGadget, Class'Core.Class'));
		m_currentOperative.m_szPrimaryGadget = m_currentOperative.default.m_szPrimaryGadget;
	}
	m_OpSecondGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.m_szSecondaryGadget, Class'Core.Class'));
	// End:0x3BA
	if((m_OpSecondGadgetDesc == none))
	{
		m_OpSecondGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.default.m_szSecondaryGadget, Class'Core.Class'));
		m_currentOperative.m_szSecondaryGadget = m_currentOperative.default.m_szSecondaryGadget;
	}
	m_OpArmorDesc = Class<R6ArmorDescription>(DynamicLoadObject(m_currentOperative.m_szArmor, Class'Core.Class'));
	// End:0x42A
	if((m_OpArmorDesc == none))
	{
		m_OpArmorDesc = Class<R6ArmorDescription>(DynamicLoadObject(m_currentOperative.default.m_szArmor, Class'Core.Class'));
		m_currentOperative.m_szArmor = m_currentOperative.default.m_szArmor;
	}
	m_OperativeDetails.ShowWindow();
	m_OperativeDetails.UpdateDetails();
	m_Equipment2dSelect.UpdateDetails();
	m_currentOperativeTeam = _selectedTeam;
	m_Equipment2dSelect.DisableControls((int(m_currentOperativeTeam) == int(3)));
	// End:0x4A5
	if((bWindowVisible && (_pActiveWindow != none)))
	{
		_pActiveWindow.ActivateWindow(0, false);
	}
	return;
}

function SetupOperative(out R6Operative OpToChek)
{
	local Class<R6ArmorDescription> currentArmor;

	currentArmor = Class<R6ArmorDescription>(DynamicLoadObject(OpToChek.m_szArmor, Class'Core.Class'));
	// End:0x63
	if((m_EquipmentDetails.IsAmorAvailable(currentArmor, OpToChek) == false))
	{
		OpToChek.m_szArmor = string(m_EquipmentDetails.GetDefaultArmor());
	}
	return;
}

function EquipmentSelected(R6MenuGearWidget.e2DEquipment EquipmentSelected)
{
	local R6WindowTextIconsListBox listboxes[3];
	local R6Operative tmpOperative;
	local R6WindowListBoxItem tmpItem;
	local int i;

	listboxes[0] = m_RosterListCtrl.m_RedListBox.m_listBox;
	listboxes[1] = m_RosterListCtrl.m_GreenListBox.m_listBox;
	listboxes[2] = m_RosterListCtrl.m_GoldListBox.m_listBox;
	switch(EquipmentSelected)
	{
		// End:0x139
		case 9:
			tmpItem = R6WindowListBoxItem(listboxes[int(m_currentOperativeTeam)].Items.Next);
			J0x94:

			// End:0x136 [Loop If]
			if((tmpItem != none))
			{
				tmpOperative = R6Operative(tmpItem.m_Object);
				// End:0x11A
				if((tmpOperative != none))
				{
					tmpOperative.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
					tmpOperative.m_szPrimaryWeaponBullet = m_currentOperative.m_szPrimaryWeaponBullet;
					tmpOperative.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
				}
				tmpItem = R6WindowListBoxItem(tmpItem.Next);
				// [Loop Continue]
				goto J0x94;
			}
			// End:0x5B2
			break;
		// End:0x20D
		case 10:
			tmpItem = R6WindowListBoxItem(listboxes[int(m_currentOperativeTeam)].Items.Next);
			J0x168:

			// End:0x20A [Loop If]
			if((tmpItem != none))
			{
				tmpOperative = R6Operative(tmpItem.m_Object);
				// End:0x1EE
				if((tmpOperative != none))
				{
					tmpOperative.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
					tmpOperative.m_szSecondaryWeaponBullet = m_currentOperative.m_szSecondaryWeaponBullet;
					tmpOperative.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
				}
				tmpItem = R6WindowListBoxItem(tmpItem.Next);
				// [Loop Continue]
				goto J0x168;
			}
			// End:0x5B2
			break;
		// End:0x2A7
		case 11:
			tmpItem = R6WindowListBoxItem(listboxes[int(m_currentOperativeTeam)].Items.Next);
			J0x23C:

			// End:0x2A4 [Loop If]
			if((tmpItem != none))
			{
				tmpOperative = R6Operative(tmpItem.m_Object);
				// End:0x288
				if((tmpOperative != none))
				{
					tmpOperative.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
				}
				tmpItem = R6WindowListBoxItem(tmpItem.Next);
				// [Loop Continue]
				goto J0x23C;
			}
			// End:0x5B2
			break;
		// End:0x341
		case 12:
			tmpItem = R6WindowListBoxItem(listboxes[int(m_currentOperativeTeam)].Items.Next);
			J0x2D6:

			// End:0x33E [Loop If]
			if((tmpItem != none))
			{
				tmpOperative = R6Operative(tmpItem.m_Object);
				// End:0x322
				if((tmpOperative != none))
				{
					tmpOperative.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
				}
				tmpItem = R6WindowListBoxItem(tmpItem.Next);
				// [Loop Continue]
				goto J0x2D6;
			}
			// End:0x5B2
			break;
		// End:0x3DB
		case 13:
			tmpItem = R6WindowListBoxItem(listboxes[int(m_currentOperativeTeam)].Items.Next);
			J0x370:

			// End:0x3D8 [Loop If]
			if((tmpItem != none))
			{
				tmpOperative = R6Operative(tmpItem.m_Object);
				// End:0x3BC
				if((tmpOperative != none))
				{
					tmpOperative.m_szArmor = m_currentOperative.m_szArmor;
				}
				tmpItem = R6WindowListBoxItem(tmpItem.Next);
				// [Loop Continue]
				goto J0x370;
			}
			// End:0x5B2
			break;
		// End:0x578
		case 14:
			i = 0;
			J0x3E7:

			// End:0x575 [Loop If]
			if((i < 3))
			{
				tmpItem = R6WindowListBoxItem(listboxes[i].Items.Next);
				J0x41B:

				// End:0x56B [Loop If]
				if((tmpItem != none))
				{
					tmpOperative = R6Operative(tmpItem.m_Object);
					// End:0x54F
					if((tmpOperative != none))
					{
						tmpOperative.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
						tmpOperative.m_szPrimaryWeaponBullet = m_currentOperative.m_szPrimaryWeaponBullet;
						tmpOperative.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
						tmpOperative.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
						tmpOperative.m_szSecondaryWeaponBullet = m_currentOperative.m_szSecondaryWeaponBullet;
						tmpOperative.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
						tmpOperative.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
						tmpOperative.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
						tmpOperative.m_szArmor = m_currentOperative.m_szArmor;
					}
					tmpItem = R6WindowListBoxItem(tmpItem.Next);
					// [Loop Continue]
					goto J0x41B;
				}
				(i++);
				// [Loop Continue]
				goto J0x3E7;
			}
			// End:0x5B2
			break;
		// End:0xFFFF
		default:
			m_OperativeDetails.HideWindow();
			m_EquipmentDetails.ShowWindow();
			m_EquipmentDetails.FillListBox(int(EquipmentSelected));
			// End:0x5B2
			break;
			break;
	}
	return;
}

function EquipmentChanged(int EquipmentSelected, Class<R6Description> DecriptionClass)
{
	local Class<R6Description> inDescriptionClass;

	switch(EquipmentSelected)
	{
		// End:0x1D3
		case 0:
			inDescriptionClass = DecriptionClass;
			// End:0x1D0
			if((m_OpFirstWeaponDesc != Class<R6PrimaryWeaponDescription>(DecriptionClass)))
			{
				m_currentOperative.m_szPrimaryWeapon = string(DecriptionClass);
				m_OpFirstWeaponDesc = Class<R6PrimaryWeaponDescription>(DecriptionClass);
				// End:0x9F
				if(bShowLog)
				{
					Log(((("Changing" @ string(m_currentOperative.Class)) @ " Primary Weapon for ") @ m_currentOperative.m_szPrimaryWeapon));
				}
				DecriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
				m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.default.m_NameID;
				m_OpFirstWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
				// End:0x12D
				if(bShowLog)
				{
					Log(((("Changing" @ string(m_currentOperative.Class)) @ " Primary Weapon Gadget for ") @ m_currentOperative.m_szPrimaryWeaponGadget));
				}
				DecriptionClass = Class'R6Description.R6DescriptionManager'.static.findPrimaryDefaultAmmo(Class<R6PrimaryWeaponDescription>(inDescriptionClass));
				m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.default.m_NameTag;
				m_OpFirstWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
				// End:0x1D0
				if(bShowLog)
				{
					Log(((("Changing" @ string(m_currentOperative.Class)) @ " Primary Weapon Bullets for ") @ m_currentOperative.m_szPrimaryWeaponBullet));
				}
			}
			// End:0x74A
			break;
		// End:0x25D
		case 1:
			m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.default.m_NameID;
			m_OpFirstWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
			// End:0x25A
			if(bShowLog)
			{
				Log(((("Changing" @ string(m_currentOperative.Class)) @ " Primary Weapon Gadget for ") @ m_currentOperative.m_szPrimaryWeaponGadget));
			}
			// End:0x74A
			break;
		// End:0x2E9
		case 2:
			m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.default.m_NameTag;
			m_OpFirstWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
			// End:0x2E6
			if(bShowLog)
			{
				Log(((("Changing" @ string(m_currentOperative.Class)) @ " Primary Weapon Bullets for ") @ m_currentOperative.m_szPrimaryWeaponBullet));
			}
			// End:0x74A
			break;
		// End:0x366
		case 3:
			m_currentOperative.m_szPrimaryGadget = string(DecriptionClass);
			m_OpFirstGadgetDesc = Class<R6GadgetDescription>(DecriptionClass);
			// End:0x363
			if(bShowLog)
			{
				Log(((("Changing" @ string(m_currentOperative.Class)) @ " Primary Gadget for ") @ m_currentOperative.m_szPrimaryWeapon));
			}
			// End:0x74A
			break;
		// End:0x539
		case 4:
			inDescriptionClass = DecriptionClass;
			// End:0x536
			if((m_OpSecondaryWeaponDesc != Class<R6SecondaryWeaponDescription>(DecriptionClass)))
			{
				m_currentOperative.m_szSecondaryWeapon = string(DecriptionClass);
				m_OpSecondaryWeaponDesc = Class<R6SecondaryWeaponDescription>(DecriptionClass);
				// End:0x401
				if(bShowLog)
				{
					Log(((("Changing" @ string(m_currentOperative.Class)) @ " Secondary Weapon for ") @ m_currentOperative.m_szSecondaryWeapon));
				}
				DecriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
				m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.default.m_NameID;
				m_OpSecondWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
				// End:0x491
				if(bShowLog)
				{
					Log(((("Changing" @ string(m_currentOperative.Class)) @ " Secondary Weapon Gadget for ") @ m_currentOperative.m_szSecondaryWeaponGadget));
				}
				DecriptionClass = Class'R6Description.R6DescriptionManager'.static.findSecondaryDefaultAmmo(Class<R6SecondaryWeaponDescription>(inDescriptionClass));
				m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.default.m_NameTag;
				m_OpSecondWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
				// End:0x536
				if(bShowLog)
				{
					Log(((("Changing" @ string(m_currentOperative.Class)) @ " Secondary Weapon Bullets for ") @ m_currentOperative.m_szSecondaryWeaponBullet));
				}
			}
			// End:0x74A
			break;
		// End:0x5C6
		case 5:
			m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.default.m_NameID;
			m_OpSecondWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
			// End:0x5C3
			if(bShowLog)
			{
				Log(((("Changing" @ string(m_currentOperative.Class)) @ " Secondary Weapon Gadget for ") @ m_currentOperative.m_szSecondaryWeaponGadget));
			}
			// End:0x74A
			break;
		// End:0x654
		case 6:
			m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.default.m_NameTag;
			m_OpSecondWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
			// End:0x651
			if(bShowLog)
			{
				Log(((("Changing" @ string(m_currentOperative.Class)) @ " Secondary Weapon Bullets for ") @ m_currentOperative.m_szSecondaryWeaponBullet));
			}
			// End:0x74A
			break;
		// End:0x6D3
		case 7:
			m_currentOperative.m_szSecondaryGadget = string(DecriptionClass);
			m_OpSecondGadgetDesc = Class<R6GadgetDescription>(DecriptionClass);
			// End:0x6D0
			if(bShowLog)
			{
				Log(((("Changing" @ string(m_currentOperative.Class)) @ " Secondary Gadget for ") @ m_currentOperative.m_szSecondaryGadget));
			}
			// End:0x74A
			break;
		// End:0x747
		case 8:
			m_currentOperative.m_szArmor = string(DecriptionClass);
			m_OpArmorDesc = Class<R6ArmorDescription>(DecriptionClass);
			// End:0x744
			if(bShowLog)
			{
				Log(((("Changing" @ string(m_currentOperative.Class)) @ " Armor for ") @ m_currentOperative.m_szArmor));
			}
			// End:0x74A
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_Equipment2dSelect.UpdateDetails();
	return;
}

//MAKE SURE THIS FUNCTION IS THE SAME AS THE ONE IN THE MULTIPLAYER GEAR ROOM
function TexRegion GetGadgetTexture(Class<R6GadgetDescription> _CurrentGadget)
{
	local bool bFound;
	local string Tag;
	local int i;
	local TexRegion TR;

	// End:0xDB
	if((Class'R6Description.R6DescPrimaryMags' == _CurrentGadget))
	{
		// End:0xC4
		if((m_OpFirstWeaponGadgetDesc.default.m_NameTag == "CMAG"))
		{
			bFound = true;
			TR.t = m_OpFirstWeaponGadgetDesc.default.m_2DMenuTexture;
			TR.X = m_OpFirstWeaponGadgetDesc.default.m_2dMenuRegion.X;
			TR.Y = m_OpFirstWeaponGadgetDesc.default.m_2dMenuRegion.Y;
			TR.W = m_OpFirstWeaponGadgetDesc.default.m_2dMenuRegion.W;
			TR.H = m_OpFirstWeaponGadgetDesc.default.m_2dMenuRegion.H;			
		}
		else
		{
			Tag = m_OpFirstWeaponDesc.default.m_MagTag;
		}		
	}
	else
	{
		// End:0x1B3
		if((Class'R6Description.R6DescSecondaryMags' == _CurrentGadget))
		{
			// End:0x19F
			if((m_OpSecondWeaponGadgetDesc.default.m_NameTag == "CMAG"))
			{
				bFound = true;
				TR.t = m_OpSecondWeaponGadgetDesc.default.m_2DMenuTexture;
				TR.X = m_OpSecondWeaponGadgetDesc.default.m_2dMenuRegion.X;
				TR.Y = m_OpSecondWeaponGadgetDesc.default.m_2dMenuRegion.Y;
				TR.W = m_OpSecondWeaponGadgetDesc.default.m_2dMenuRegion.W;
				TR.H = m_OpSecondWeaponGadgetDesc.default.m_2dMenuRegion.H;				
			}
			else
			{
				Tag = m_OpSecondaryWeaponDesc.default.m_MagTag;
			}
		}
	}
	// End:0x23A
	if((Tag != ""))
	{
		i = 0;
		J0x1C6:

		// End:0x23A [Loop If]
		if(((i < m_PrimaryMagsGadget.m_MagTags.Length) && (bFound == false)))
		{
			// End:0x230
			if((m_PrimaryMagsGadget.m_MagTags[i] == Tag))
			{
				bFound = true;
				TR = m_PrimaryMagsGadget.m_Mags[i];				
			}
			else
			{
				(i++);
			}
			// [Loop Continue]
			goto J0x1C6;
		}
	}
	// End:0x2D7
	if((bFound == false))
	{
		TR.t = _CurrentGadget.default.m_2DMenuTexture;
		TR.X = _CurrentGadget.default.m_2dMenuRegion.X;
		TR.Y = _CurrentGadget.default.m_2dMenuRegion.Y;
		TR.W = _CurrentGadget.default.m_2dMenuRegion.W;
		TR.H = _CurrentGadget.default.m_2dMenuRegion.H;
	}
	return TR;
	return;
}

function SetStartTeamInfo()
{
	local R6StartGameInfo StartGameInfo;
	local int i, j, k, rainbowAdded;
	local R6WindowTextIconsListBox tmpListBox[3], currentListBox;
	local R6Operative tmpOperative;
	local R6WindowListBoxItem tmpItem;
	local string Tag;
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6BulletDescription> PrimaryWeaponBulletClass, SecondaryWeaponBulletClass;
	local Class<R6GadgetDescription> PrimaryGadgetClass, SecondaryGadgetClass;
	local Class<R6WeaponGadgetDescription> PrimaryWeaponGadgetClass, SecondaryWeaponGadgetClass;
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local bool Found;

	StartGameInfo = R6Console(Root.Console).Master.m_StartGameInfo;
	tmpListBox[0] = m_RosterListCtrl.m_RedListBox.m_listBox;
	tmpListBox[1] = m_RosterListCtrl.m_GreenListBox.m_listBox;
	tmpListBox[2] = m_RosterListCtrl.m_GoldListBox.m_listBox;
	j = 0;
	J0x90:

	// End:0xD4E [Loop If]
	if((j < 3))
	{
		currentListBox = tmpListBox[j];
		tmpItem = R6WindowListBoxItem(currentListBox.Items.Next);
		rainbowAdded = 0;
		i = 0;
		J0xDD:

		// End:0xD21 [Loop If]
		if((i < currentListBox.Items.Count()))
		{
			tmpOperative = R6Operative(tmpItem.m_Object);
			// End:0xD17
			if((tmpOperative != none))
			{
				PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(tmpOperative.m_szPrimaryWeapon, Class'Core.Class'));
				PrimaryWeaponBulletClass = Class'R6Description.R6DescriptionManager'.static.GetPrimaryBulletDesc(PrimaryWeaponClass, tmpOperative.m_szPrimaryWeaponBullet);
				PrimaryWeaponGadgetClass = Class'R6Description.R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(PrimaryWeaponClass, tmpOperative.m_szPrimaryWeaponGadget);
				SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(tmpOperative.m_szSecondaryWeapon, Class'Core.Class'));
				SecondaryWeaponBulletClass = Class'R6Description.R6DescriptionManager'.static.GetSecondaryBulletDesc(SecondaryWeaponClass, tmpOperative.m_szSecondaryWeaponBullet);
				SecondaryWeaponGadgetClass = Class'R6Description.R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(SecondaryWeaponClass, tmpOperative.m_szSecondaryWeaponGadget);
				PrimaryGadgetClass = Class<R6GadgetDescription>(DynamicLoadObject(tmpOperative.m_szPrimaryGadget, Class'Core.Class'));
				SecondaryGadgetClass = Class<R6GadgetDescription>(DynamicLoadObject(tmpOperative.m_szSecondaryGadget, Class'Core.Class'));
				ArmorDescriptionClass = Class<R6ArmorDescription>(DynamicLoadObject(tmpOperative.m_szArmor, Class'Core.Class'));
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_CharacterName = tmpOperative.GetShortName();
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_ArmorName = ArmorDescriptionClass.default.m_ClassName;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[0] = PrimaryWeaponGadgetClass.default.m_ClassName;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[1] = SecondaryWeaponGadgetClass.default.m_ClassName;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[0] = PrimaryGadgetClass.default.m_ClassName;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[1] = SecondaryGadgetClass.default.m_ClassName;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iHealth = tmpOperative.m_iHealth;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID = tmpOperative.m_iUniqueID;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceTexture = tmpOperative.m_TMenuFaceSmall;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.X = float(tmpOperative.m_RMenuFaceSmallX);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.Y = float(tmpOperative.m_RMenuFaceSmallY);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.Z = float(tmpOperative.m_RMenuFaceSmallW);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_FaceCoords.W = float(tmpOperative.m_RMenuFaceSmallH);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID = tmpOperative.m_szSpecialityID;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillAssault = (tmpOperative.m_fAssault * 0.0100000);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillDemolitions = (tmpOperative.m_fDemolitions * 0.0100000);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillElectronics = (tmpOperative.m_fElectronics * 0.0100000);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillSniper = (tmpOperative.m_fSniper * 0.0100000);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillStealth = (tmpOperative.m_fStealth * 0.0100000);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillSelfControl = (tmpOperative.m_fSelfControl * 0.0100000);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillLeadership = (tmpOperative.m_fLeadership * 0.0100000);
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_fSkillObservation = (tmpOperative.m_fObservation * 0.0100000);
				// End:0x82E
				if((tmpOperative.m_szGender == "M"))
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_bIsMale = true;					
				}
				else
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_bIsMale = false;
				}
				Found = false;
				k = 0;
				J0x86C:

				// End:0x9B8 [Loop If]
				if(((k < PrimaryWeaponClass.default.m_WeaponTags.Length) && (Found == false)))
				{
					// End:0x922
					if((PrimaryWeaponClass.default.m_WeaponTags[k] == PrimaryWeaponGadgetClass.default.m_NameTag))
					{
						Found = true;
						StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[k];
						Tag = PrimaryWeaponClass.default.m_WeaponTags[k];
						// [Explicit Continue]
						goto J0x9AE;
					}
					// End:0x9AE
					if((PrimaryWeaponClass.default.m_WeaponTags[k] == PrimaryWeaponBulletClass.default.m_NameTag))
					{
						Found = true;
						StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[k];
						Tag = PrimaryWeaponClass.default.m_WeaponTags[k];
					}
					J0x9AE:

					(k++);
					// [Loop Continue]
					goto J0x86C;
				}
				// End:0xA19
				if((Found == false))
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[0];
					Tag = PrimaryWeaponClass.default.m_WeaponTags[0];
				}
				// End:0xA6D
				if((Tag == "SILENCED"))
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0] = PrimaryWeaponBulletClass.default.m_SubsonicClassName;					
				}
				else
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0] = PrimaryWeaponBulletClass.default.m_ClassName;
				}
				Found = false;
				k = 0;
				J0xAB9:

				// End:0xC05 [Loop If]
				if(((k < SecondaryWeaponClass.default.m_WeaponTags.Length) && (Found == false)))
				{
					// End:0xB6F
					if((SecondaryWeaponClass.default.m_WeaponTags[k] == SecondaryWeaponGadgetClass.default.m_NameTag))
					{
						Found = true;
						StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[k];
						Tag = SecondaryWeaponClass.default.m_WeaponTags[k];
						// [Explicit Continue]
						goto J0xBFB;
					}
					// End:0xBFB
					if((SecondaryWeaponClass.default.m_WeaponTags[k] == SecondaryWeaponBulletClass.default.m_NameTag))
					{
						Found = true;
						StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[k];
						Tag = SecondaryWeaponClass.default.m_WeaponTags[k];
					}
					J0xBFB:

					(k++);
					// [Loop Continue]
					goto J0xAB9;
				}
				// End:0xC66
				if((Found == false))
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[0];
					Tag = SecondaryWeaponClass.default.m_WeaponTags[0];
				}
				// End:0xCBA
				if((Tag == "SILENCED"))
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1] = SecondaryWeaponBulletClass.default.m_SubsonicClassName;					
				}
				else
				{
					StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1] = SecondaryWeaponBulletClass.default.m_ClassName;
				}
				tmpItem = R6WindowListBoxItem(tmpItem.Next);
				(rainbowAdded++);
			}
			(i++);
			// [Loop Continue]
			goto J0xDD;
		}
		StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers = rainbowAdded;
		(j++);
		// [Loop Continue]
		goto J0x90;
	}
	return;
}

function SetStartTeamInfoForSaving()
{
	local R6StartGameInfo StartGameInfo;
	local int i, j, k;
	local R6WindowTextIconsListBox tmpListBox[3], currentListBox;
	local R6Operative tmpOperative;
	local R6WindowListBoxItem tmpItem;
	local bool Found;

	StartGameInfo = R6Console(Root.Console).Master.m_StartGameInfo;
	tmpListBox[0] = m_RosterListCtrl.m_RedListBox.m_listBox;
	tmpListBox[1] = m_RosterListCtrl.m_GreenListBox.m_listBox;
	tmpListBox[2] = m_RosterListCtrl.m_GoldListBox.m_listBox;
	j = 0;
	J0x90:

	// End:0x420 [Loop If]
	if((j < 3))
	{
		currentListBox = tmpListBox[j];
		tmpItem = R6WindowListBoxItem(currentListBox.Items.Next);
		StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers = 0;
		i = 0;
		J0xF5:

		// End:0x416 [Loop If]
		if((i < currentListBox.Items.Count()))
		{
			tmpOperative = R6Operative(tmpItem.m_Object);
			// End:0x3F3
			if((tmpOperative != none))
			{
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_ArmorName = tmpOperative.m_szArmor;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0] = tmpOperative.m_szPrimaryWeapon;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1] = tmpOperative.m_szSecondaryWeapon;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0] = tmpOperative.m_szPrimaryWeaponBullet;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1] = tmpOperative.m_szSecondaryWeaponBullet;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[0] = tmpOperative.m_szPrimaryWeaponGadget;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[1] = tmpOperative.m_szSecondaryWeaponGadget;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[0] = tmpOperative.m_szPrimaryGadget;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[1] = tmpOperative.m_szSecondaryGadget;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID = tmpOperative.m_iUniqueID;
				StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID = tmpOperative.m_szSpecialityID;
				(StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers++);
			}
			tmpItem = R6WindowListBoxItem(tmpItem.Next);
			(i++);
			// [Loop Continue]
			goto J0xF5;
		}
		(j++);
		// [Loop Continue]
		goto J0x90;
	}
	return;
}

function LoadRosterFromStartInfo()
{
	local R6StartGameInfo StartGameInfo;
	local int i, j, k, L, TeamIDs;

	local R6WindowTextIconsSubListBox tmpListBox[3], currentListBox;
	local bool Found, bOperativeIsNotReady, bRookieCase, bIDMatch;
	local R6WindowListBoxItem TempItem, SelectedItem, bkpValidItem;
	local R6Operative tmpOperative;
	local R6WindowListBoxItem selectedOperativeItem;
	local int selectedOperativeTeamId;

	StartGameInfo = R6Console(Root.Console).Master.m_StartGameInfo;
	tmpListBox[0] = m_RosterListCtrl.m_RedListBox;
	tmpListBox[1] = m_RosterListCtrl.m_GreenListBox;
	tmpListBox[2] = m_RosterListCtrl.m_GoldListBox;
	Reset();
	k = 0;
	j = 0;
	J0x82:

	// End:0x10F [Loop If]
	if((j < 3))
	{
		i = 0;
		J0x95:

		// End:0x105 [Loop If]
		if((i < StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers))
		{
			TeamIDs[k] = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID;
			(k++);
			(i++);
			// [Loop Continue]
			goto J0x95;
		}
		(j++);
		// [Loop Continue]
		goto J0x82;
	}
	j = 0;
	J0x116:

	// End:0x809 [Loop If]
	if((j < 3))
	{
		currentListBox = tmpListBox[j];
		i = 0;
		J0x13A:

		// End:0x7FF [Loop If]
		if((i < StartGameInfo.m_TeamInfo[j].m_iNumberOfMembers))
		{
			k = 0;
			Found = false;
			bOperativeIsNotReady = false;
			bRookieCase = false;
			bIDMatch = false;
			bkpValidItem = none;
			SelectedItem = R6WindowListBoxItem(m_RosterListCtrl.m_listBox.Items.Next);
			// End:0x218
			if((StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID > (m_RosterListCtrl.m_listBox.Items.Count() - 5)))
			{
				bRookieCase = true;
			}
			J0x218:

			// End:0x7F5 [Loop If]
			if(((Found == false) && (k < m_RosterListCtrl.m_listBox.Items.Count())))
			{
				tmpOperative = R6Operative(SelectedItem.m_Object);
				// End:0x485
				if((tmpOperative != none))
				{
					bIDMatch = (StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_iOperativeID == tmpOperative.m_iUniqueID);
					// End:0x322
					if(bIDMatch)
					{
						// End:0x322
						if((tmpOperative.m_iRookieID != -1))
						{
							// End:0x322
							if((!(StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID ~= tmpOperative.m_szSpecialityID)))
							{
								bRookieCase = true;
							}
						}
					}
					// End:0x376
					if((bIDMatch && (!bRookieCase)))
					{
						// End:0x36B
						if(((!tmpOperative.IsOperativeReady()) || SelectedItem.m_addedToSubList))
						{
							bOperativeIsNotReady = true;							
						}
						else
						{
							Found = true;
						}						
					}
					else
					{
						// End:0x43A
						if((StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_szSpecialityID ~= tmpOperative.m_szSpecialityID))
						{
							// End:0x43A
							if(((bkpValidItem == none) && (tmpOperative.IsOperativeReady() && (!SelectedItem.m_addedToSubList))))
							{
								bkpValidItem = SelectedItem;
								L = 0;
								J0x3FC:

								// End:0x43A [Loop If]
								if((L < 8))
								{
									// End:0x430
									if((TeamIDs[L] == tmpOperative.m_iUniqueID))
									{
										bkpValidItem = none;
										// [Explicit Break]
										goto J0x43A;
									}
									(L++);
									// [Loop Continue]
									goto J0x3FC;
								}
							}
						}
					}
					J0x43A:

					// End:0x485
					if((bOperativeIsNotReady || bRookieCase))
					{
						// End:0x485
						if((bkpValidItem != none))
						{
							SelectedItem = bkpValidItem;
							tmpOperative = R6Operative(SelectedItem.m_Object);
							Found = true;
						}
					}
				}
				// End:0x7D2
				if(Found)
				{
					tmpOperative.m_szArmor = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_ArmorName;
					tmpOperative.m_szPrimaryWeapon = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[0];
					tmpOperative.m_szSecondaryWeapon = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponName[1];
					tmpOperative.m_szPrimaryWeaponBullet = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[0];
					tmpOperative.m_szSecondaryWeaponBullet = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_BulletType[1];
					tmpOperative.m_szPrimaryWeaponGadget = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[0];
					tmpOperative.m_szSecondaryWeaponGadget = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_WeaponGadgetName[1];
					tmpOperative.m_szPrimaryGadget = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[0];
					tmpOperative.m_szSecondaryGadget = StartGameInfo.m_TeamInfo[j].m_CharacterInTeam[i].m_GadgetName[1];
					SetupOperative(tmpOperative);
					TempItem = R6WindowListBoxItem(currentListBox.m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					// End:0x7AE
					if((TempItem != none))
					{
						TempItem.m_Icon = SelectedItem.m_Icon;
						TempItem.m_IconRegion = SelectedItem.m_IconRegion;
						TempItem.m_IconSelectedRegion = SelectedItem.m_IconSelectedRegion;
						TempItem.HelpText = SelectedItem.HelpText;
						TempItem.m_ParentListItem = SelectedItem;
						TempItem.m_Object = SelectedItem.m_Object;
						SelectedItem.m_addedToSubList = true;
					}
					// End:0x7CF
					if((selectedOperativeItem == none))
					{
						selectedOperativeItem = TempItem;
						selectedOperativeTeamId = j;
					}					
				}
				else
				{
					(k++);
					SelectedItem = R6WindowListBoxItem(SelectedItem.Next);
				}
				// [Loop Continue]
				goto J0x218;
			}
			(i++);
			// [Loop Continue]
			goto J0x13A;
		}
		(j++);
		// [Loop Continue]
		goto J0x116;
	}
	m_RosterListCtrl.RefreshButtons();
	m_RosterListCtrl.ResizeSubLists();
	// End:0x858
	if((selectedOperativeItem != none))
	{
		tmpListBox[selectedOperativeTeamId].m_listBox.SetSelectedItem(selectedOperativeItem);		
	}
	else
	{
		OperativeSelected(m_currentOperative, m_currentOperativeTeam, m_RosterListCtrl.m_listBox);
	}
	return;
}

function bool IsTeamConfigValid()
{
	// End:0x0D
	if((m_RosterListCtrl == none))
	{
		return false;
	}
	// End:0x9A
	if((((m_RosterListCtrl.m_RedListBox.m_listBox.Items.Count() + m_RosterListCtrl.m_GreenListBox.m_listBox.Items.Count()) + m_RosterListCtrl.m_GoldListBox.m_listBox.Items.Count()) <= 0))
	{
		return false;		
	}
	else
	{
		return true;
	}
	return;
}

defaultproperties
{
	m_currentOperativeTeam=3
	m_IRosterListLeftPad=1
	m_fPaddingBetweenElements=3.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var m_bRebuildAllPlan
// REMOVED IN 1.60: var c
// REMOVED IN 1.60: function RebuildAllPlanningFile
