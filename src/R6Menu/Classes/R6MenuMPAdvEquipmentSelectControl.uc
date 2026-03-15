//=============================================================================
// R6MenuMPAdvEquipmentSelectControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPAdvEquipmentSelectControl.uc : This control should provide functionalities
//                                      needed to show 2d representations of equipment
//                                      multi-player adverserial    
//                                      
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvEquipmentSelectControl extends R6MenuEquipmentSelectControl;

//Debug
var bool bShowLog;
var float m_fPrimaryGadgetWindowWidth;

function Created()
{
	m_DisableColor = Root.Colors.GrayLight;
	m_EnableColor = Root.Colors.White;
	m_2DWeaponPrimary = R6MenuMPAdvGearPrimaryWeapon(CreateControl(Class'R6Menu.R6MenuMPAdvGearPrimaryWeapon', 0.0000000, 0.0000000, WinWidth, m_fPrimaryWindowHeight, self));
	m_2DWeaponSecondary = R6MenuMPAdvGearSecondaryWeapon(CreateControl(Class'R6Menu.R6MenuMPAdvGearSecondaryWeapon', 0.0000000, (m_fPrimaryWindowHeight - float(1)), WinWidth, (m_fSecondaryWindowHeight + float(1)), self));
	m_2DGadgetPrimary = R6MenuMPAdvGearGadget(CreateControl(Class'R6Menu.R6MenuMPAdvGearGadget', 0.0000000, ((m_fPrimaryWindowHeight + m_fSecondaryWindowHeight) - float(1)), (WinWidth / float(2)), (((WinHeight - m_fPrimaryWindowHeight) - m_fSecondaryWindowHeight) + float(1)), self));
	m_2DGadgetSecondary = R6MenuMPAdvGearGadget(CreateControl(Class'R6Menu.R6MenuMPAdvGearGadget', ((m_2DGadgetPrimary.WinLeft + m_2DGadgetPrimary.WinWidth) - float(1)), m_2DGadgetPrimary.WinTop, (((WinWidth - m_2DGadgetPrimary.WinLeft) - m_2DGadgetPrimary.WinWidth) + float(1)), m_2DGadgetPrimary.WinHeight, self));
	return;
}

function Init()
{
	R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(0);
	setHighLight(m_2DWeaponPrimary.m_2DWeapon);
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

function TexRegion GetCurrentGadgetTex(bool _Primary)
{
	// End:0x37
	if((_Primary == true))
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).GetGadgetTexture(R6MenuMPAdvGearWidget(OwnerWindow).m_OpFirstGadgetDesc);		
	}
	else
	{
		return R6MenuMPAdvGearWidget(OwnerWindow).GetGadgetTexture(R6MenuMPAdvGearWidget(OwnerWindow).m_OpSecondGadgetDesc);
	}
	return;
}

function bool CenterGadgetTexture(bool _Primary)
{
	return true;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x364
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x7C
			case m_2DWeaponPrimary.m_2DWeapon:
				// End:0x4F
				if(bShowLog)
				{
					Log("m_2DWeaponPrimary.m_2DWeapon");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(0);
				setHighLight(m_2DWeaponPrimary.m_2DWeapon);
				// End:0x364
				break;
			// End:0xE3
			case m_2DWeaponPrimary.m_2DBullet:
				// End:0xB6
				if(bShowLog)
				{
					Log("m_2DWeaponPrimary.m_2DBullet");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(2);
				setHighLight(m_2DWeaponPrimary.m_2DBullet);
				// End:0x364
				break;
			// End:0x150
			case m_2DWeaponPrimary.m_2DWeaponGadget:
				// End:0x123
				if(bShowLog)
				{
					Log("m_2DWeaponPrimary.m_2DWeaponGadget");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(1);
				setHighLight(m_2DWeaponPrimary.m_2DWeaponGadget);
				// End:0x364
				break;
			// End:0x1B9
			case m_2DWeaponSecondary.m_2DWeapon:
				// End:0x18C
				if(bShowLog)
				{
					Log("m_2DWeaponSecondary.m_2DWeapon");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(4);
				setHighLight(m_2DWeaponSecondary.m_2DWeapon);
				// End:0x364
				break;
			// End:0x222
			case m_2DWeaponSecondary.m_2DBullet:
				// End:0x1F5
				if(bShowLog)
				{
					Log("m_2DWeaponSecondary.m_2DBullet");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(6);
				setHighLight(m_2DWeaponSecondary.m_2DBullet);
				// End:0x364
				break;
			// End:0x291
			case m_2DWeaponSecondary.m_2DWeaponGadget:
				// End:0x264
				if(bShowLog)
				{
					Log("m_2DWeaponSecondary.m_2DWeaponGadget");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(5);
				setHighLight(m_2DWeaponSecondary.m_2DWeaponGadget);
				// End:0x364
				break;
			// End:0x2F8
			case m_2DGadgetPrimary.m_2DGadget:
				// End:0x2CB
				if(bShowLog)
				{
					Log("m_2DGadgetPrimary.m_2DGadget");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(3);
				setHighLight(m_2DGadgetPrimary.m_2DGadget);
				// End:0x364
				break;
			// End:0x361
			case m_2DGadgetSecondary.m_2DGadget:
				// End:0x334
				if(bShowLog)
				{
					Log("m_2DGadgetSecondary.m_2DGadget");
				}
				R6MenuMPAdvGearWidget(OwnerWindow).EquipmentSelected(7);
				setHighLight(m_2DGadgetSecondary.m_2DGadget);
				// End:0x364
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

defaultproperties
{
	m_fPrimaryWindowHeight=138.0000000
	m_fSecondaryWindowHeight=84.0000000
}
