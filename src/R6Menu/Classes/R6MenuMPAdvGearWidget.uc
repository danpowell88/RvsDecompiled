//=============================================================================
// R6MenuMPAdvGearWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPAdvGearWidget.uc : GearRoomMenu for multi-player adverserial
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/24 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvGearWidget extends R6MenuWidget;

enum e2DEquipment
{
	Primary_Weapon,                 // 0
	Primary_WeaponGadget,           // 1
	Primary_Bullet,                 // 2
	Primary_Gadget,                 // 3
	Secondary_Weapon,               // 4
	Secondary_WeaponGadget,         // 5
	Secondary_Bullet,               // 6
	Secondary_Gadget                // 7
};

var R6MenuMPAdvGearWidget.e2DEquipment m_e2DCurEquipmentSel;
//debug
var int m_iCounter;
var bool bShowLog;
var R6MenuMPAdvEquipmentSelectControl m_Equipment2dSelect;  // Left part where we can take a look a selected equipment
var R6MenuMPAdvEquipmentDetailControl m_EquipmentDetails;  // Right side when looking at an equipment item
var R6Operative m_currentOperative;
// NEW IN 1.60
var R6Operative m_BkpOperative;
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
var string PrimaryGadgetDesc;  // MissionPack1   // MPF1

function Created()
{
	local int labelWidth;
	local Region R;
	local int i, j;
	local R6Mod pCurrentMod;
	local Class<R6DescPrimaryMags> ExtraMags;

	m_currentOperative = new (none) Class'R6Game.R6Operative';
	m_BkpOperative = new (none) Class'R6Game.R6Operative';
	m_Equipment2dSelect = R6MenuMPAdvEquipmentSelectControl(CreateWindow(Class'R6Menu.R6MenuMPAdvEquipmentSelectControl', 0.0000000, 0.0000000, 241.0000000, WinHeight, self));
	m_EquipmentDetails = R6MenuMPAdvEquipmentDetailControl(CreateWindow(Class'R6Menu.R6MenuMPAdvEquipmentDetailControl', (m_Equipment2dSelect.WinWidth - float(1)), 0.0000000, ((WinWidth - m_Equipment2dSelect.WinWidth) + float(1)), WinHeight, self));
	GetMenuComEquipment(true);
	m_Equipment2dSelect.Init();
	m_PrimaryMagsGadget = new (none) Class'R6Description.R6DescPrimaryMags';
	pCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod;
	i = 0;
	J0xDE:

	// End:0x201 [Loop If]
	if((i < pCurrentMod.m_aDescriptionPackage.Length))
	{
		// End:0x1F7
		if((pCurrentMod.m_aDescriptionPackage[i] != "R6Description"))
		{
			ExtraMags = Class<R6DescPrimaryMags>(GetFirstPackageClass((pCurrentMod.m_aDescriptionPackage[i] $ ".u"), Class'R6Description.R6DescPrimaryMags'));
			J0x14C:

			// End:0x1F7 [Loop If]
			if((ExtraMags != none))
			{
				j = 0;
				J0x15E:

				// End:0x1E6 [Loop If]
				if((j < ExtraMags.default.m_iNewTagsToAdd))
				{
					m_PrimaryMagsGadget.m_Mags[m_PrimaryMagsGadget.m_Mags.Length] = ExtraMags.default.m_Mags[j];
					m_PrimaryMagsGadget.m_MagTags[m_PrimaryMagsGadget.m_MagTags.Length] = ExtraMags.default.m_MagTags[j];
					(j++);
					// [Loop Continue]
					goto J0x15E;
				}
				ExtraMags = Class<R6DescPrimaryMags>(GetNextClass());
				// [Loop Continue]
				goto J0x14C;
			}
		}
		(i++);
		// [Loop Continue]
		goto J0xDE;
	}
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	GetMenuComEquipment(false);
	m_Equipment2dSelect.UpdateDetails();
	return;
}

function GetMenuComEquipment(bool _bCkeckEquipment)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x11B
	if(_bCkeckEquipment)
	{
		m_currentOperative.m_szPrimaryWeaponBullet = r6Root.m_R6GameMenuCom.m_szPrimaryWeaponBullet;
		m_currentOperative.m_szSecondaryWeaponBullet = r6Root.m_R6GameMenuCom.m_szSecondaryWeaponBullet;
		m_currentOperative.m_szArmor = r6Root.m_R6GameMenuCom.m_szArmor;
		VerifyAllEquipment(r6Root.m_R6GameMenuCom.m_szPrimaryWeapon, r6Root.m_R6GameMenuCom.m_szPrimaryWeaponGadget, r6Root.m_R6GameMenuCom.m_szPrimaryGadget, r6Root.m_R6GameMenuCom.m_szSecondaryWeapon, r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget, r6Root.m_R6GameMenuCom.m_szSecondaryGadget);
	}
	r6Root.m_R6GameMenuCom.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
	r6Root.m_R6GameMenuCom.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
	r6Root.m_R6GameMenuCom.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
	r6Root.m_R6GameMenuCom.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
	r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
	r6Root.m_R6GameMenuCom.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
	SetOperativeEquipment(false);
	SetClassEquipment();
	return;
}

// NEW IN 1.60
function VerifyAllEquipment(string _szPrimaryWeapon, string _szPrimaryWeaponGadget, string _szPrimaryGadget, string _szSecondaryWeapon, string _szSecondaryWeaponGadget, string _szSecondaryGadget)
{
	m_currentOperative.m_szPrimaryWeapon = VerifyEquipment(int(0), _szPrimaryWeapon);
	m_currentOperative.m_szPrimaryWeaponGadget = VerifyEquipment(int(1), _szPrimaryWeaponGadget);
	m_currentOperative.m_szPrimaryGadget = VerifyEquipment(int(3), _szPrimaryGadget);
	m_currentOperative.m_szSecondaryWeapon = VerifyEquipment(int(4), _szSecondaryWeapon);
	m_currentOperative.m_szSecondaryWeaponGadget = VerifyEquipment(int(5), _szSecondaryWeaponGadget);
	m_currentOperative.m_szSecondaryGadget = VerifyEquipment(int(7), _szSecondaryGadget);
	return;
}

function string VerifyEquipment(int _equipmentType, string _szEquipmentToValid)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;
	local string szEquipmentFind;
	local int i;
	local Class<R6PrimaryWeaponDescription> PriWpnClass;
	local string szClassName;
	local bool bFound;
	local Class<R6GadgetDescription> replacedGadgetClass;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	switch(_equipmentType)
	{
		// End:0xDA
		case int(0):
			szEquipmentFind = _szEquipmentToValid;
			bFound = false;
			i = 0;
			J0x38:

			// End:0x9F [Loop If]
			if(((i < m_EquipmentDetails.m_APrimaryWeapons.Length) && (!bFound)))
			{
				szClassName = ("" $ string(m_EquipmentDetails.m_APrimaryWeapons[i]));
				// End:0x95
				if((szClassName ~= _szEquipmentToValid))
				{
					bFound = true;
				}
				(i++);
				// [Loop Continue]
				goto J0x38;
			}
			// End:0xD7
			if((!bFound))
			{
				szEquipmentFind = "R6Description.R6DescPrimaryWeaponNone";
			}
			// End:0x520
			break;
		// End:0x19A
		case int(1):
			szEquipmentFind = _szEquipmentToValid;
			bFound = false;
			i = 0;
			J0xFB:

			// End:0x160 [Loop If]
			if(((i < m_EquipmentDetails.m_APriWpnGadget.Length) && (!bFound)))
			{
				szClassName = ("" $ m_EquipmentDetails.m_APriWpnGadget[i]);
				// End:0x156
				if((szClassName ~= _szEquipmentToValid))
				{
					bFound = true;
				}
				(i++);
				// [Loop Continue]
				goto J0xFB;
			}
			// End:0x197
			if((!bFound))
			{
				szEquipmentFind = "R6Description.R6DescWeaponGadgetNone";
			}
			// End:0x520
			break;
		// End:0x283
		case int(3):
			szEquipmentFind = _szEquipmentToValid;
			// End:0x1CE
			if(CheckGadget(szEquipmentFind, self, false, replacedGadgetClass))
			{
				szEquipmentFind = string(replacedGadgetClass);
			}
			PrimaryGadgetDesc = szEquipmentFind;
			bFound = false;
			i = 0;
			J0x1E8:

			// End:0x24F [Loop If]
			if(((i < m_EquipmentDetails.m_AGadgets.Length) && (!bFound)))
			{
				szClassName = ("" $ string(m_EquipmentDetails.m_AGadgets[i]));
				// End:0x245
				if((szClassName ~= szEquipmentFind))
				{
					bFound = true;
				}
				(i++);
				// [Loop Continue]
				goto J0x1E8;
			}
			// End:0x280
			if((!bFound))
			{
				szEquipmentFind = "R6Description.R6DescGadgetNone";
			}
			// End:0x520
			break;
		// End:0x377
		case int(4):
			szEquipmentFind = _szEquipmentToValid;
			bFound = false;
			i = 0;
			J0x2A4:

			// End:0x30B [Loop If]
			if(((i < m_EquipmentDetails.m_ASecondaryWeapons.Length) && (!bFound)))
			{
				szClassName = ("" $ string(m_EquipmentDetails.m_ASecondaryWeapons[i]));
				// End:0x301
				if((szClassName ~= _szEquipmentToValid))
				{
					bFound = true;
				}
				(i++);
				// [Loop Continue]
				goto J0x2A4;
			}
			// End:0x374
			if((!bFound))
			{
				szEquipmentFind = "R6Description.R6DescPistol92FS";
				r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget = "R6Description.R6DescGadgetNone";
			}
			// End:0x520
			break;
		// End:0x437
		case int(5):
			szEquipmentFind = _szEquipmentToValid;
			bFound = false;
			i = 0;
			J0x398:

			// End:0x3FD [Loop If]
			if(((i < m_EquipmentDetails.m_ASecWpnGadget.Length) && (!bFound)))
			{
				szClassName = ("" $ m_EquipmentDetails.m_ASecWpnGadget[i]);
				// End:0x3F3
				if((szClassName ~= _szEquipmentToValid))
				{
					bFound = true;
				}
				(i++);
				// [Loop Continue]
				goto J0x398;
			}
			// End:0x434
			if((!bFound))
			{
				szEquipmentFind = "R6Description.R6DescWeaponGadgetNone";
			}
			// End:0x520
			break;
		// End:0x51A
		case int(7):
			szEquipmentFind = _szEquipmentToValid;
			// End:0x470
			if(CheckGadget(szEquipmentFind, self, false, replacedGadgetClass, PrimaryGadgetDesc))
			{
				szEquipmentFind = string(replacedGadgetClass);
			}
			bFound = false;
			i = 0;
			J0x47F:

			// End:0x4E6 [Loop If]
			if(((i < m_EquipmentDetails.m_AGadgets.Length) && (!bFound)))
			{
				szClassName = ("" $ string(m_EquipmentDetails.m_AGadgets[i]));
				// End:0x4DC
				if((szClassName ~= szEquipmentFind))
				{
					bFound = true;
				}
				(i++);
				// [Loop Continue]
				goto J0x47F;
			}
			// End:0x517
			if((!bFound))
			{
				szEquipmentFind = "R6Description.R6DescGadgetNone";
			}
			// End:0x520
			break;
		// End:0xFFFF
		default:
			// End:0x520
			break;
			break;
	}
	return szEquipmentFind;
	return;
}

function setMenuComEquipment()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x65
	if((r6Root.m_R6GameMenuCom == none))
	{
		// End:0x63
		if(bShowLog)
		{
			Log("setMenuComEquipment() GameMenuCom is no more valid");
		}
		return;
	}
	r6Root.m_R6GameMenuCom.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
	r6Root.m_R6GameMenuCom.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
	r6Root.m_R6GameMenuCom.m_szPrimaryWeaponBullet = m_currentOperative.m_szPrimaryWeaponBullet;
	r6Root.m_R6GameMenuCom.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
	r6Root.m_R6GameMenuCom.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
	r6Root.m_R6GameMenuCom.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
	r6Root.m_R6GameMenuCom.m_szSecondaryWeaponBullet = m_currentOperative.m_szSecondaryWeaponBullet;
	r6Root.m_R6GameMenuCom.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
	r6Root.m_R6GameMenuCom.m_szArmor = m_currentOperative.m_szArmor;
	r6Root.m_R6GameMenuCom.SavePlayerSetupInfo();
	return;
}

// NEW IN 1.60
function SetOperativeEquipment(bool _bCopyBkpToCurrent)
{
	// End:0x111
	if(_bCopyBkpToCurrent)
	{
		m_currentOperative.m_szPrimaryWeapon = m_BkpOperative.m_szPrimaryWeapon;
		m_currentOperative.m_szPrimaryWeaponGadget = m_BkpOperative.m_szPrimaryWeaponGadget;
		m_currentOperative.m_szPrimaryWeaponBullet = m_BkpOperative.m_szPrimaryWeaponBullet;
		m_currentOperative.m_szPrimaryGadget = m_BkpOperative.m_szPrimaryGadget;
		m_currentOperative.m_szSecondaryWeapon = m_BkpOperative.m_szSecondaryWeapon;
		m_currentOperative.m_szSecondaryWeaponGadget = m_BkpOperative.m_szSecondaryWeaponGadget;
		m_currentOperative.m_szSecondaryWeaponBullet = m_BkpOperative.m_szSecondaryWeaponBullet;
		m_currentOperative.m_szSecondaryGadget = m_BkpOperative.m_szSecondaryGadget;
		m_currentOperative.m_szArmor = m_BkpOperative.m_szArmor;		
	}
	else
	{
		m_BkpOperative.m_szPrimaryWeapon = m_currentOperative.m_szPrimaryWeapon;
		m_BkpOperative.m_szPrimaryWeaponGadget = m_currentOperative.m_szPrimaryWeaponGadget;
		m_BkpOperative.m_szPrimaryWeaponBullet = m_currentOperative.m_szPrimaryWeaponBullet;
		m_BkpOperative.m_szPrimaryGadget = m_currentOperative.m_szPrimaryGadget;
		m_BkpOperative.m_szSecondaryWeapon = m_currentOperative.m_szSecondaryWeapon;
		m_BkpOperative.m_szSecondaryWeaponGadget = m_currentOperative.m_szSecondaryWeaponGadget;
		m_BkpOperative.m_szSecondaryWeaponBullet = m_currentOperative.m_szSecondaryWeaponBullet;
		m_BkpOperative.m_szSecondaryGadget = m_currentOperative.m_szSecondaryGadget;
		m_BkpOperative.m_szArmor = m_currentOperative.m_szArmor;
	}
	return;
}

// NEW IN 1.60
function SetClassEquipment()
{
	m_OpFirstWeaponDesc = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(m_currentOperative.m_szPrimaryWeapon, Class'Core.Class'));
	m_OpFirstWeaponGadgetDesc = Class'R6Description.R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponGadget);
	m_OpFirstWeaponBulletDesc = Class'R6Description.R6DescriptionManager'.static.GetPrimaryBulletDesc(m_OpFirstWeaponDesc, m_currentOperative.m_szPrimaryWeaponBullet);
	m_OpSecondaryWeaponDesc = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(m_currentOperative.m_szSecondaryWeapon, Class'Core.Class'));
	m_OpSecondWeaponGadgetDesc = Class'R6Description.R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponGadget);
	m_OpSecondWeaponBulletDesc = Class'R6Description.R6DescriptionManager'.static.GetSecondaryBulletDesc(m_OpSecondaryWeaponDesc, m_currentOperative.m_szSecondaryWeaponBullet);
	m_OpFirstGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.m_szPrimaryGadget, Class'Core.Class'));
	m_OpSecondGadgetDesc = Class<R6GadgetDescription>(DynamicLoadObject(m_currentOperative.m_szSecondaryGadget, Class'Core.Class'));
	return;
}

// NEW IN 1.60
function AcceptSelection()
{
	// End:0x2B
	if(bShowLog)
	{
		Log("MPGearWidget AcceptSelection()");
	}
	RefreshGearInfo(true);
	setMenuComEquipment();
	SetOperativeEquipment(false);
	return;
}

// NEW IN 1.60
function CancelSelection()
{
	// End:0x2B
	if(bShowLog)
	{
		Log("MPGearWidget CancelSelection()");
	}
	SetOperativeEquipment(true);
	SetClassEquipment();
	m_EquipmentDetails.m_listBox.DropSelection();
	return;
}

function EquipmentSelected(R6MenuMPAdvGearWidget.e2DEquipment EquipmentSelected)
{
	local R6WindowListBoxItem TempItem;

	m_e2DCurEquipmentSel = EquipmentSelected;
	m_EquipmentDetails.ShowWindow();
	m_EquipmentDetails.FillListBox(int(EquipmentSelected));
	return;
}

function EquipmentChanged(int EquipmentSelected, Class<R6Description> DecriptionClass)
{
	local Class<R6Description> inDescriptionClass;

	switch(EquipmentSelected)
	{
		// End:0x191
		case 0:
			inDescriptionClass = DecriptionClass;
			// End:0x18E
			if((m_OpFirstWeaponDesc != Class<R6PrimaryWeaponDescription>(DecriptionClass)))
			{
				m_currentOperative.m_szPrimaryWeapon = string(DecriptionClass);
				m_OpFirstWeaponDesc = Class<R6PrimaryWeaponDescription>(DecriptionClass);
				// End:0x89
				if(bShowLog)
				{
					Log(("Changing Primary Weapon for " @ m_currentOperative.m_szPrimaryWeapon));
				}
				DecriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
				m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.default.m_NameID;
				m_OpFirstWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
				// End:0x101
				if(bShowLog)
				{
					Log(("Changing Primary Weapon Gadget for " @ m_currentOperative.m_szPrimaryWeaponGadget));
				}
				DecriptionClass = Class'R6Description.R6DescriptionManager'.static.findPrimaryDefaultAmmo(Class<R6PrimaryWeaponDescription>(inDescriptionClass));
				m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.default.m_NameTag;
				m_OpFirstWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
				// End:0x18E
				if(bShowLog)
				{
					Log(("Changing Primary Weapon Bullets for " @ m_currentOperative.m_szPrimaryWeaponBullet));
				}
			}
			// End:0x5CE
			break;
		// End:0x205
		case 1:
			m_currentOperative.m_szPrimaryWeaponGadget = DecriptionClass.default.m_NameID;
			m_OpFirstWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
			// End:0x202
			if(bShowLog)
			{
				Log(("Changing Primary Weapon Gadget for " @ m_currentOperative.m_szPrimaryWeaponGadget));
			}
			// End:0x5CE
			break;
		// End:0x27B
		case 2:
			m_currentOperative.m_szPrimaryWeaponBullet = DecriptionClass.default.m_NameTag;
			m_OpFirstWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
			// End:0x278
			if(bShowLog)
			{
				Log(("Changing Primary Weapon Bullets for " @ m_currentOperative.m_szPrimaryWeaponBullet));
			}
			// End:0x5CE
			break;
		// End:0x2E2
		case 3:
			m_currentOperative.m_szPrimaryGadget = string(DecriptionClass);
			m_OpFirstGadgetDesc = Class<R6GadgetDescription>(DecriptionClass);
			// End:0x2DF
			if(bShowLog)
			{
				Log(("Changing Primary Gadget for " @ m_currentOperative.m_szPrimaryWeapon));
			}
			// End:0x5CE
			break;
		// End:0x473
		case 4:
			inDescriptionClass = DecriptionClass;
			// End:0x470
			if((m_OpSecondaryWeaponDesc != Class<R6SecondaryWeaponDescription>(DecriptionClass)))
			{
				m_currentOperative.m_szSecondaryWeapon = string(DecriptionClass);
				m_OpSecondaryWeaponDesc = Class<R6SecondaryWeaponDescription>(DecriptionClass);
				// End:0x367
				if(bShowLog)
				{
					Log(("Changing Secondary Weapon for " @ m_currentOperative.m_szSecondaryWeapon));
				}
				DecriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
				m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.default.m_NameID;
				m_OpSecondWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
				// End:0x3E1
				if(bShowLog)
				{
					Log(("Changing Secondary Weapon Gadget for " @ m_currentOperative.m_szSecondaryWeaponGadget));
				}
				DecriptionClass = Class'R6Description.R6DescriptionManager'.static.findSecondaryDefaultAmmo(Class<R6SecondaryWeaponDescription>(inDescriptionClass));
				m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.default.m_NameTag;
				m_OpSecondWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
				// End:0x470
				if(bShowLog)
				{
					Log(("Changing Secondary Weapon Bullets for " @ m_currentOperative.m_szSecondaryWeaponBullet));
				}
			}
			// End:0x5CE
			break;
		// End:0x4EA
		case 5:
			m_currentOperative.m_szSecondaryWeaponGadget = DecriptionClass.default.m_NameID;
			m_OpSecondWeaponGadgetDesc = Class<R6WeaponGadgetDescription>(DecriptionClass);
			// End:0x4E7
			if(bShowLog)
			{
				Log(("Changing Secondary Weapon Gadget for " @ m_currentOperative.m_szSecondaryWeaponGadget));
			}
			// End:0x5CE
			break;
		// End:0x562
		case 6:
			m_currentOperative.m_szSecondaryWeaponBullet = DecriptionClass.default.m_NameTag;
			m_OpSecondWeaponBulletDesc = Class<R6BulletDescription>(DecriptionClass);
			// End:0x55F
			if(bShowLog)
			{
				Log(("Changing Secondary Weapon Bullets for " @ m_currentOperative.m_szSecondaryWeaponBullet));
			}
			// End:0x5CE
			break;
		// End:0x5CB
		case 7:
			m_currentOperative.m_szSecondaryGadget = string(DecriptionClass);
			m_OpSecondGadgetDesc = Class<R6GadgetDescription>(DecriptionClass);
			// End:0x5C8
			if(bShowLog)
			{
				Log(("Changing Secondary Gadget for " @ m_currentOperative.m_szSecondaryGadget));
			}
			// End:0x5CE
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_Equipment2dSelect.UpdateDetails();
	return;
}

//MAKE SURE THIS FUNCTION IS THE SAME AS THE ONE IN THE SINGLEPLAYER GEAR ROOM
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

//=========================================================================================
// RefreshGearInfo: Refresh all the gear according the new restriction kit
//=========================================================================================
function RefreshGearInfo(bool _bForceUpdate)
{
	// End:0xB2
	if(((m_iCounter > 10) || _bForceUpdate))
	{
		m_iCounter = 0;
		m_EquipmentDetails.BuildAvailableEquipment();
		m_EquipmentDetails.FillListBox(int(m_e2DCurEquipmentSel));
		VerifyAllEquipment(m_currentOperative.m_szPrimaryWeapon, m_currentOperative.m_szPrimaryWeaponGadget, m_currentOperative.m_szPrimaryGadget, m_currentOperative.m_szSecondaryWeapon, m_currentOperative.m_szSecondaryWeaponGadget, m_currentOperative.m_szSecondaryGadget);
		SetClassEquipment();
		m_Equipment2dSelect.UpdateDetails();
	}
	(m_iCounter++);
	return;
}

static function bool CheckGadget(string _gadgetDesc, UWindowWindow _caller, bool _isSecondGadget, optional out Class<R6GadgetDescription> _replaceGadgetClass, optional string _otherGadget)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(_caller.Root);
	// End:0x2A6
	if((r6Root != none))
	{
		// End:0x1C3
		if((r6Root.m_szCurrentGameType == "RGM_CaptureTheEnemyAdvMode"))
		{
			// End:0x1C0
			if(((((_gadgetDesc == "R6Description.R6DescFragGrenadeGadget") || (_gadgetDesc == "R6Description.R6DescBreachingChargeGadget")) || (_gadgetDesc == "R6Description.R6DescClaymoreGadget")) || (_gadgetDesc == "R6Description.R6DescRemoteChargeGadget")))
			{
				// End:0x176
				if(_isSecondGadget)
				{
					// End:0x168
					if((_otherGadget == "R6Description.R6DescSmokeGrenadeGadget"))
					{
						_replaceGadgetClass = Class'R6Description.R6DescFlashBangGadget';						
					}
					else
					{
						_replaceGadgetClass = Class'R6Description.R6DescSmokeGrenadeGadget';
					}					
				}
				else
				{
					// End:0x1B3
					if((_otherGadget == "R6Description.R6DescFlashBangGadget"))
					{
						_replaceGadgetClass = Class'R6Description.R6DescSmokeGrenadeGadget';						
					}
					else
					{
						_replaceGadgetClass = Class'R6Description.R6DescFlashBangGadget';
					}
				}
				return true;
			}			
		}
		else
		{
			// End:0x2A6
			if((r6Root.m_szCurrentGameType == "RGM_KamikazeMode"))
			{
				// End:0x2A6
				if(((((_gadgetDesc == "R6Description.R6DescHBSGadget") || (_gadgetDesc == "R6Description.R6DescHBSJammerGadget")) || (_gadgetDesc == "R6Description.R6DescHBSSAJammerGadget")) || (_gadgetDesc == "R6Description.R6DescFalseHBGadget")))
				{
					return true;
				}
			}
		}
	}
	return false;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var c
// REMOVED IN 1.60: function PopUpBoxDone
