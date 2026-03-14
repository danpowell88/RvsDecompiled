//=============================================================================
// R6MenuEquipmentSelectControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuEquipmentSelectControl.uc : This control should provide functionalities
//                                      needed to show 2d representations of equipment
//                                      
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEquipmentSelectControl extends UWindowDialogClientWindow;

var bool m_bDisableControls;
//Debug
var bool bShowLog;
//Display variables
var float m_fArmorWindowWidth;
var float m_fPrimaryWindowHeight;
var float m_fSecondaryWindowHeight;
var float m_fPrimaryGadgetWindowHeight;
var R6MenuGearPrimaryWeapon m_2DWeaponPrimary;
var R6MenuGearSecondaryWeapon m_2DWeaponSecondary;
var R6MenuGearGadget m_2DGadgetPrimary;
var R6MenuGearGadget m_2DGadgetSecondary;
var R6MenuGearArmor m_2DArmor;
var R6MenuAssignAllButton m_AssignAllToAllButton;  // Assign All equimnent to all assigned operatives
var Texture m_TAssignAllToAllButton;
var R6WindowButtonGear m_HighlightedButton;
var Region m_RAssignAllToAllUp;
// NEW IN 1.60
var Region m_RAssignAllToAllOver;
// NEW IN 1.60
var Region m_RAssignAllToAllDown;
// NEW IN 1.60
var Region m_RAssignAllToAllDisable;
var Color m_DisableColor;
var Color m_EnableColor;

function Created()
{
	m_DisableColor = Root.Colors.GrayLight;
	m_EnableColor = Root.Colors.White;
	m_2DWeaponPrimary = R6MenuGearPrimaryWeapon(CreateControl(Class'R6Menu.R6MenuGearPrimaryWeapon', 0.0000000, 0.0000000, WinWidth, m_fPrimaryWindowHeight, self));
	m_2DWeaponSecondary = R6MenuGearSecondaryWeapon(CreateControl(Class'R6Menu.R6MenuGearSecondaryWeapon', __NFUN_175__(m_fArmorWindowWidth, float(1)), __NFUN_175__(m_fPrimaryWindowHeight, float(1)), __NFUN_174__(__NFUN_175__(WinWidth, m_fArmorWindowWidth), float(1)), m_fSecondaryWindowHeight, self));
	m_2DGadgetPrimary = R6MenuGearGadget(CreateControl(Class'R6Menu.R6MenuGearGadget', __NFUN_175__(m_fArmorWindowWidth, float(1)), __NFUN_175__(__NFUN_174__(m_2DWeaponSecondary.WinTop, m_2DWeaponSecondary.WinHeight), float(1)), m_2DWeaponSecondary.WinWidth, m_fPrimaryGadgetWindowHeight, self));
	m_2DGadgetSecondary = R6MenuGearGadget(CreateControl(Class'R6Menu.R6MenuGearGadget', __NFUN_175__(m_fArmorWindowWidth, float(1)), __NFUN_175__(__NFUN_174__(m_2DGadgetPrimary.WinTop, m_2DGadgetPrimary.WinHeight), float(1)), m_2DWeaponSecondary.WinWidth, m_fPrimaryGadgetWindowHeight, self));
	m_2DArmor = R6MenuGearArmor(CreateControl(Class'R6Menu.R6MenuGearArmor', 0.0000000, __NFUN_175__(m_2DWeaponPrimary.WinHeight, float(1)), m_fArmorWindowWidth, 247.0000000, self));
	m_AssignAllToAllButton = R6MenuAssignAllButton(CreateControl(Class'R6Menu.R6MenuAssignAllButton', 0.0000000, __NFUN_175__(WinHeight, float(12)), WinWidth, 12.0000000, self));
	m_AssignAllToAllButton.bAlwaysOnTop = true;
	m_AssignAllToAllButton.ToolTipString = Localize("GearRoom", "AssignAllToAll", "R6Menu");
	m_AssignAllToAllButton.m_iDrawStyle = int(5);
	m_AssignAllToAllButton.SetCompleteAssignAllButton();
	return;
}

function DisableControls(bool _Disable)
{
	m_AssignAllToAllButton.SetButtonStatus(_Disable);
	m_2DWeaponPrimary.SetButtonsStatus(_Disable);
	m_2DWeaponSecondary.SetButtonsStatus(_Disable);
	m_2DGadgetPrimary.SetButtonsStatus(_Disable);
	m_2DGadgetSecondary.SetButtonsStatus(_Disable);
	m_2DArmor.SetButtonsStatus(_Disable);
	m_bDisableControls = _Disable;
	// End:0xD9
	if(__NFUN_130__(__NFUN_242__(_Disable, true), __NFUN_119__(m_HighlightedButton, none)))
	{
		m_HighlightedButton.m_HighLight = false;
		m_HighlightedButton.OwnerWindow.SetBorderColor(m_DisableColor);
		m_HighlightedButton = none;
	}
	return;
}

function setHighLight(R6WindowButtonGear newButton)
{
	// End:0x39
	if(__NFUN_119__(m_HighlightedButton, none))
	{
		m_HighlightedButton.m_HighLight = false;
		m_HighlightedButton.OwnerWindow.SetBorderColor(m_DisableColor);
	}
	// End:0x95
	if(__NFUN_119__(newButton, none))
	{
		m_HighlightedButton = newButton;
		m_HighlightedButton.m_HighLight = true;
		m_HighlightedButton.OwnerWindow.SetBorderColor(m_EnableColor);
		m_HighlightedButton.OwnerWindow.BringToFront();
	}
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x0B
	if(m_bDisableControls)
	{
		return;
	}
	// End:0x180
	if(__NFUN_154__(int(E), 12))
	{
		switch(C.OwnerWindow)
		{
			// End:0x8F
			case self:
				// End:0x8C
				if(__NFUN_114__(C, m_AssignAllToAllButton))
				{
					m_2DWeaponPrimary.ForceMouseOver(true);
					m_2DWeaponSecondary.ForceMouseOver(true);
					m_2DGadgetPrimary.ForceMouseOver(true);
					m_2DGadgetSecondary.ForceMouseOver(true);
					m_2DArmor.ForceMouseOver(true);
				}
				// End:0x17D
				break;
			// End:0xBE
			case m_2DWeaponPrimary:
				m_2DWeaponPrimary.ForceMouseOver(__NFUN_114__(C, m_2DWeaponPrimary.m_AssignAll));
				// End:0x17D
				break;
			// End:0xED
			case m_2DWeaponSecondary:
				m_2DWeaponSecondary.ForceMouseOver(__NFUN_114__(C, m_2DWeaponSecondary.m_AssignAll));
				// End:0x17D
				break;
			// End:0x11C
			case m_2DGadgetPrimary:
				m_2DGadgetPrimary.ForceMouseOver(__NFUN_114__(C, m_2DGadgetPrimary.m_AssignAll));
				// End:0x17D
				break;
			// End:0x14B
			case m_2DGadgetSecondary:
				m_2DGadgetSecondary.ForceMouseOver(__NFUN_114__(C, m_2DGadgetSecondary.m_AssignAll));
				// End:0x17D
				break;
			// End:0x17A
			case m_2DArmor:
				m_2DArmor.ForceMouseOver(__NFUN_114__(C, m_2DArmor.m_AssignAll));
				// End:0x17D
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x1E1
		if(__NFUN_154__(int(E), 9))
		{
			m_2DWeaponPrimary.ForceMouseOver(false);
			m_2DWeaponSecondary.ForceMouseOver(false);
			m_2DGadgetPrimary.ForceMouseOver(false);
			m_2DGadgetSecondary.ForceMouseOver(false);
			m_2DArmor.ForceMouseOver(false);			
		}
		else
		{
			// End:0x51A
			if(__NFUN_154__(int(E), 2))
			{
				switch(C)
				{
					// End:0x217
					case m_AssignAllToAllButton:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(14);
						// End:0x51A
						break;
					// End:0x241
					case m_2DWeaponPrimary.m_AssignAll:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(9);
						// End:0x51A
						break;
					// End:0x27F
					case m_2DWeaponPrimary.m_2DWeapon:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(0);
						setHighLight(m_2DWeaponPrimary.m_2DWeapon);
						// End:0x51A
						break;
					// End:0x2BD
					case m_2DWeaponPrimary.m_2DBullet:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(2);
						setHighLight(m_2DWeaponPrimary.m_2DBullet);
						// End:0x51A
						break;
					// End:0x2FB
					case m_2DWeaponPrimary.m_2DWeaponGadget:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(1);
						setHighLight(m_2DWeaponPrimary.m_2DWeaponGadget);
						// End:0x51A
						break;
					// End:0x325
					case m_2DWeaponSecondary.m_AssignAll:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(10);
						// End:0x51A
						break;
					// End:0x363
					case m_2DWeaponSecondary.m_2DWeapon:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(4);
						setHighLight(m_2DWeaponSecondary.m_2DWeapon);
						// End:0x51A
						break;
					// End:0x3A1
					case m_2DWeaponSecondary.m_2DBullet:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(6);
						setHighLight(m_2DWeaponSecondary.m_2DBullet);
						// End:0x51A
						break;
					// End:0x3DF
					case m_2DWeaponSecondary.m_2DWeaponGadget:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(5);
						setHighLight(m_2DWeaponSecondary.m_2DWeaponGadget);
						// End:0x51A
						break;
					// End:0x409
					case m_2DGadgetPrimary.m_AssignAll:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(11);
						// End:0x51A
						break;
					// End:0x447
					case m_2DGadgetPrimary.m_2DGadget:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(3);
						setHighLight(m_2DGadgetPrimary.m_2DGadget);
						// End:0x51A
						break;
					// End:0x471
					case m_2DGadgetSecondary.m_AssignAll:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(12);
						// End:0x51A
						break;
					// End:0x4AF
					case m_2DGadgetSecondary.m_2DGadget:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(7);
						setHighLight(m_2DGadgetSecondary.m_2DGadget);
						// End:0x51A
						break;
					// End:0x4D9
					case m_2DArmor.m_AssignAll:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(13);
						// End:0x51A
						break;
					// End:0x517
					case m_2DArmor.m_2DArmor:
						R6MenuGearWidget(OwnerWindow).EquipmentSelected(8);
						setHighLight(m_2DArmor.m_2DArmor);
						// End:0x51A
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

function Class<R6PrimaryWeaponDescription> GetCurrentPrimaryWeapon()
{
	return R6MenuGearWidget(OwnerWindow).m_OpFirstWeaponDesc;
	return;
}

function Class<R6SecondaryWeaponDescription> GetCurrentSecondaryWeapon()
{
	return R6MenuGearWidget(OwnerWindow).m_OpSecondaryWeaponDesc;
	return;
}

function Class<R6WeaponGadgetDescription> GetCurrentWeaponGadget(bool _Primary)
{
	// End:0x23
	if(__NFUN_242__(_Primary, true))
	{
		return R6MenuGearWidget(OwnerWindow).m_OpFirstWeaponGadgetDesc;		
	}
	else
	{
		return R6MenuGearWidget(OwnerWindow).m_OpSecondWeaponGadgetDesc;
	}
	return;
}

function Class<R6BulletDescription> GetCurrentWeaponBullet(bool _Primary)
{
	// End:0x23
	if(__NFUN_242__(_Primary, true))
	{
		return R6MenuGearWidget(OwnerWindow).m_OpFirstWeaponBulletDesc;		
	}
	else
	{
		return R6MenuGearWidget(OwnerWindow).m_OpSecondWeaponBulletDesc;
	}
	return;
}

function TexRegion GetCurrentGadgetTex(bool _Primary)
{
	// End:0x37
	if(__NFUN_242__(_Primary, true))
	{
		return R6MenuGearWidget(OwnerWindow).GetGadgetTexture(R6MenuGearWidget(OwnerWindow).m_OpFirstGadgetDesc);		
	}
	else
	{
		return R6MenuGearWidget(OwnerWindow).GetGadgetTexture(R6MenuGearWidget(OwnerWindow).m_OpSecondGadgetDesc);
	}
	return;
}

function bool CenterGadgetTexture(bool _Primary)
{
	local bool Result;
	local R6MenuGearWidget GearRoom;

	GearRoom = R6MenuGearWidget(OwnerWindow);
	// End:0x61
	if(__NFUN_242__(_Primary, true))
	{
		// End:0x5E
		if(__NFUN_114__(Class'R6Description.R6DescPrimaryMags', GearRoom.m_OpFirstGadgetDesc))
		{
			// End:0x5E
			if(__NFUN_122__(GearRoom.m_OpFirstWeaponGadgetDesc.default.m_NameTag, "CMAG"))
			{
				Result = true;
			}
		}		
	}
	else
	{
		// End:0xA3
		if(__NFUN_114__(Class'R6Description.R6DescSecondaryMags', GearRoom.m_OpSecondGadgetDesc))
		{
			// End:0xA3
			if(__NFUN_122__(GearRoom.m_OpSecondWeaponGadgetDesc.default.m_NameTag, "CMAG"))
			{
				Result = true;
			}
		}
	}
	return Result;
	return;
}

function Class<R6ArmorDescription> GetCurrentArmor()
{
	return R6MenuGearWidget(OwnerWindow).m_OpArmorDesc;
	return;
}

function UpdateDetails()
{
	local TexRegion TR;

	m_2DWeaponPrimary.SetWeaponTexture(static.GetCurrentPrimaryWeapon().default.m_2DMenuTexture, static.GetCurrentPrimaryWeapon().default.m_2dMenuRegion);
	m_2DWeaponPrimary.SetWeaponGadgetTexture(static.GetCurrentWeaponGadget(true).default.m_2DMenuTexture, static.GetCurrentWeaponGadget(true).default.m_2dMenuRegion);
	m_2DWeaponPrimary.SetBulletTexture(static.GetCurrentWeaponBullet(true).default.m_2DMenuTexture, static.GetCurrentWeaponBullet(true).default.m_2dMenuRegion);
	m_2DWeaponSecondary.SetWeaponTexture(static.GetCurrentSecondaryWeapon().default.m_2DMenuTexture, static.GetCurrentSecondaryWeapon().default.m_2dMenuRegion);
	m_2DWeaponSecondary.SetWeaponGadgetTexture(static.GetCurrentWeaponGadget(false).default.m_2DMenuTexture, static.GetCurrentWeaponGadget(false).default.m_2dMenuRegion);
	m_2DWeaponSecondary.SetBulletTexture(static.GetCurrentWeaponBullet(false).default.m_2DMenuTexture, static.GetCurrentWeaponBullet(false).default.m_2dMenuRegion);
	TR = GetCurrentGadgetTex(true);
	m_2DGadgetPrimary.m_bCenterTexture = CenterGadgetTexture(true);
	m_2DGadgetPrimary.SetGadgetTexture(TR.t, GetRegion(TR));
	TR = GetCurrentGadgetTex(false);
	m_2DGadgetPrimary.m_bCenterTexture = CenterGadgetTexture(false);
	m_2DGadgetSecondary.SetGadgetTexture(TR.t, GetRegion(TR));
	// End:0x1DE
	if(__NFUN_119__(m_2DArmor, none))
	{
		m_2DArmor.SetArmorTexture(static.GetCurrentArmor().default.m_2DMenuTexture, static.GetCurrentArmor().default.m_2dMenuRegion);
	}
	return;
}

defaultproperties
{
	m_fArmorWindowWidth=131.0000000
	m_fPrimaryWindowHeight=79.0000000
	m_fSecondaryWindowHeight=133.0000000
	m_fPrimaryGadgetWindowHeight=58.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var r
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var e
