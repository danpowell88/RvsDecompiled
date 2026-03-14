//=============================================================================
// R6MenuEquipmentDetailControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuEquipmentDetailControl.uc : This control should provide functionalities
//                                      needed to select armor, weapons, bullets
//                                      gadgets for an operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEquipmentDetailControl extends UWindowDialogClientWindow;

var int m_CurrentEquipmentType;  // To notify the gear menu
var bool m_bDrawListBg;
var float m_fListBoxLabelHeight;
// NEW IN 1.60
var float m_fListBoxHeight;
var float m_fAnchorAreaHeight;
var R6WindowTextLabel m_Title;
var R6WindowTextListBox m_listBox;
var R6WindowWrappedTextArea m_EquipmentText;
var Font m_DescriptionTextFont;
var R6MenuEquipmentAnchorButtons m_AnchorButtons;
var R6MenuWeaponStats m_WeaponStats;
var R6MenuWeaponDetailRadioArea m_Buttons;
var array< Class > m_APrimaryWeapons;  // class<R6PrimaryWeaponDescription>
var array< Class > m_ASecondaryWeapons;  // class<R6SecondaryWeaponDescription>
var array< Class > m_AGadgets;  // class<R6GadgetDescription>
var array< Class > m_AArmors;  // class<R6ArmorDescription>
var Color m_DescriptionTextColor;  // For description Area

function Created()
{
	local Color labelFontColor, co;
	local Texture BorderTexture;

	m_BorderColor = Root.Colors.GrayLight;
	labelFontColor = Root.Colors.White;
	m_Title = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, m_fListBoxLabelHeight, self));
	m_Title.Align = 2;
	m_Title.m_Font = Root.Fonts[6];
	m_Title.TextColor = labelFontColor;
	m_Title.m_BGTexture = none;
	m_Title.m_BorderColor = m_BorderColor;
	m_listBox = R6WindowTextListBox(CreateControl(Class'R6Window.R6WindowTextListBox', 0.0000000, __NFUN_175__(m_fListBoxLabelHeight, float(1)), WinWidth, m_fListBoxHeight, self));
	m_listBox.ListClass = Class'R6Window.R6WindowListBoxItem';
	m_listBox.m_VertSB.SetHideWhenDisable(true);
	m_listBox.m_Font = m_Title.m_Font;
	m_listBox.SetCornerType(0);
	m_listBox.m_BorderColor = m_BorderColor;
	m_listBox.m_fSpaceBetItem = 0.0000000;
	m_listBox.m_VertSB.SetEffect(true);
	m_EquipmentText = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', 0.0000000, __NFUN_175__(__NFUN_174__(m_listBox.WinTop, m_listBox.WinHeight), float(1)), WinWidth, __NFUN_174__(__NFUN_175__(__NFUN_175__(WinHeight, m_Title.WinHeight), m_listBox.WinHeight), float(1)), self));
	m_EquipmentText.m_HBorderTexture = m_Title.m_HBorderTexture;
	m_EquipmentText.m_VBorderTexture = m_Title.m_VBorderTexture;
	m_EquipmentText.m_HBorderTextureRegion = m_Title.m_HBorderTextureRegion;
	m_EquipmentText.m_VBorderTextureRegion = m_Title.m_VBorderTextureRegion;
	m_EquipmentText.m_fHBorderHeight = m_Title.m_fHBorderHeight;
	m_EquipmentText.m_fVBorderWidth = m_Title.m_fVBorderWidth;
	m_EquipmentText.m_BorderColor = m_BorderColor;
	m_EquipmentText.SetScrollable(true);
	m_EquipmentText.m_fXOffSet = 5.0000000;
	m_EquipmentText.m_fYOffSet = 5.0000000;
	m_EquipmentText.VertSB.SetEffect(true);
	m_EquipmentText.m_bUseBGTexture = true;
	m_EquipmentText.m_BGTexture = Texture'UWindow.WhiteTexture';
	m_EquipmentText.m_BGRegion.X = 0;
	m_EquipmentText.m_BGRegion.Y = 0;
	m_EquipmentText.m_BGRegion.W = m_EquipmentText.m_BGTexture.USize;
	m_EquipmentText.m_BGRegion.H = m_EquipmentText.m_BGTexture.VSize;
	m_EquipmentText.m_bUseBGColor = true;
	m_EquipmentText.m_BGColor = Root.Colors.Black;
	m_EquipmentText.m_BGColor.A = byte(Root.Colors.DarkBGAlpha);
	m_DescriptionTextColor = Root.Colors.White;
	m_DescriptionTextFont = Root.Fonts[6];
	m_CurrentEquipmentType = -1;
	BuildAvailableEquipment();
	m_AnchorButtons = R6MenuEquipmentAnchorButtons(CreateControl(Class'R6Menu.R6MenuEquipmentAnchorButtons', 0.0000000, 0.0000000, WinWidth, m_fAnchorAreaHeight, self));
	m_AnchorButtons.m_BorderColor = m_BorderColor;
	m_AnchorButtons.HideWindow();
	m_Buttons = R6MenuWeaponDetailRadioArea(CreateWindow(Class'R6Menu.R6MenuWeaponDetailRadioArea', 0.0000000, __NFUN_175__(__NFUN_174__(m_listBox.WinTop, m_listBox.WinHeight), float(1)), WinWidth, m_fAnchorAreaHeight, self));
	m_Buttons.m_BorderColor = m_BorderColor;
	m_Buttons.HideWindow();
	m_WeaponStats = R6MenuWeaponStats(CreateWindow(Class'R6Menu.R6MenuWeaponStats', 0.0000000, __NFUN_175__(__NFUN_174__(m_Buttons.WinTop, m_Buttons.WinHeight), float(1)), WinWidth, __NFUN_174__(__NFUN_175__(__NFUN_175__(WinHeight, m_Buttons.WinTop), m_Buttons.WinHeight), float(1)), self));
	m_WeaponStats.m_BorderColor = m_BorderColor;
	m_WeaponStats.HideWindow();
	return;
}

function R6Operative GetCurrentOperative()
{
	return R6MenuGearWidget(OwnerWindow).m_currentOperative;
	return;
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

function Class<R6GadgetDescription> GetCurrentGadget(bool _Primary)
{
	// End:0x23
	if(__NFUN_242__(_Primary, true))
	{
		return R6MenuGearWidget(OwnerWindow).m_OpFirstGadgetDesc;		
	}
	else
	{
		return R6MenuGearWidget(OwnerWindow).m_OpSecondGadgetDesc;
	}
	return;
}

function Class<R6ArmorDescription> GetCurrentArmor()
{
	return R6MenuGearWidget(OwnerWindow).m_OpArmorDesc;
	return;
}

function NotifyEquipmentChanged(int EquipmentSelected, Class<R6Description> DecriptionClass)
{
	R6MenuGearWidget(OwnerWindow).EquipmentChanged(EquipmentSelected, DecriptionClass);
	return;
}

function FillListBox(int _equipmentType)
{
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6BulletDescription> WeaponBulletDescriptionClass;
	local Class<R6GadgetDescription> GadgetClass;
	local Class<R6WeaponGadgetDescription> WeaponGadgetDescriptionClass;
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local R6ArmorDescription ArmorForAvailabilityTest;
	local R6WindowListBoxItem NewItem, SelectedItem, FirstInsertedItem;
	local R6Operative currentOperative;
	local int i;

	currentOperative = GetCurrentOperative();
	SelectedItem = none;
	switch(_equipmentType)
	{
		// End:0x312
		case 0:
			m_Title.SetNewText(Localize("GearRoom", "PrimaryWeapon", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(0);
			PrimaryWeaponClass = Class'R6Description.R6DescPrimaryWeaponNone';
			NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(PrimaryWeaponClass.default.m_NameID, "ID_NAME", "R6Weapons");
			NewItem.m_Object = PrimaryWeaponClass;
			// End:0x105
			if(__NFUN_114__(GetCurrentPrimaryWeapon(), PrimaryWeaponClass))
			{
				SelectedItem = NewItem;
			}
			FirstInsertedItem = CreatePrimaryWeaponsSeparators();
			i = 0;
			J0x118:

			// End:0x2FD [Loop If]
			if(__NFUN_150__(i, m_APrimaryWeapons.Length))
			{
				PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(m_APrimaryWeapons[i]);
				// End:0x17A
				if(__NFUN_119__(Class<R6SubGunDescription>(PrimaryWeaponClass), none))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 1);					
				}
				else
				{
					// End:0x1B7
					if(__NFUN_119__(Class<R6AssaultDescription>(PrimaryWeaponClass), none))
					{
						NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 2);						
					}
					else
					{
						// End:0x1F4
						if(__NFUN_119__(Class<R6ShotgunDescription>(PrimaryWeaponClass), none))
						{
							NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 3);							
						}
						else
						{
							// End:0x231
							if(__NFUN_119__(Class<R6SniperDescription>(PrimaryWeaponClass), none))
							{
								NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 4);								
							}
							else
							{
								// End:0x26E
								if(__NFUN_119__(Class<R6LMGDescription>(PrimaryWeaponClass), none))
								{
									NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 5);									
								}
								else
								{
									NewItem = R6WindowListBoxItem(FirstInsertedItem.InsertBefore(Class'R6Window.R6WindowListBoxItem'));
								}
							}
						}
					}
				}
				NewItem.HelpText = Localize(PrimaryWeaponClass.default.m_NameID, "ID_NAME", "R6Weapons");
				NewItem.m_Object = PrimaryWeaponClass;
				// End:0x2F3
				if(__NFUN_114__(GetCurrentPrimaryWeapon(), PrimaryWeaponClass))
				{
					SelectedItem = NewItem;
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x118;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(true);
			// End:0x139D
			break;
		// End:0x548
		case 1:
			m_Title.SetNewText(Localize("GearRoom", "PrimaryWeaponGadget", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(3);
			PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(currentOperative.m_szPrimaryWeapon, Class'Core.Class'));
			i = 0;
			J0x395:

			// End:0x47B [Loop If]
			if(__NFUN_150__(i, PrimaryWeaponClass.default.m_MyGadgets.Length))
			{
				WeaponGadgetDescriptionClass = Class<R6WeaponGadgetDescription>(PrimaryWeaponClass.default.m_MyGadgets[i]);
				// End:0x471
				if(__NFUN_119__(WeaponGadgetDescriptionClass, Class'R6Description.R6DescWeaponGadgetNone'))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
					NewItem.m_Object = WeaponGadgetDescriptionClass;
					// End:0x471
					if(__NFUN_114__(GetCurrentWeaponGadget(true), WeaponGadgetDescriptionClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x395;
			}
			m_listBox.Items.Sort();
			WeaponGadgetDescriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
			NewItem = R6WindowListBoxItem(m_listBox.Items.InsertAfter(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
			NewItem.m_Object = WeaponGadgetDescriptionClass;
			// End:0x533
			if(__NFUN_114__(GetCurrentWeaponGadget(true), WeaponGadgetDescriptionClass))
			{
				SelectedItem = NewItem;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x139D
			break;
		// End:0x6CE
		case 2:
			m_Title.SetNewText(Localize("GearRoom", "PrimaryAmmo", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(3);
			PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(currentOperative.m_szPrimaryWeapon, Class'Core.Class'));
			i = 0;
			J0x5C4:

			// End:0x6A1 [Loop If]
			if(__NFUN_150__(i, PrimaryWeaponClass.default.m_Bullets.Length))
			{
				WeaponBulletDescriptionClass = Class<R6BulletDescription>(PrimaryWeaponClass.default.m_Bullets[i]);
				// End:0x697
				if(__NFUN_119__(WeaponBulletDescriptionClass, Class'R6Description.R6DescBulletNone'))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					NewItem.HelpText = Localize(WeaponBulletDescriptionClass.default.m_NameID, "ID_NAME", "R6Ammo");
					NewItem.m_Object = WeaponBulletDescriptionClass;
					// End:0x697
					if(__NFUN_114__(GetCurrentWeaponBullet(true), WeaponBulletDescriptionClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x5C4;
			}
			m_listBox.Items.Sort();
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x139D
			break;
		// End:0x9B4
		case 3:
			m_Title.SetNewText(Localize("GearRoom", "PrimaryGadget", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(2);
			GadgetClass = Class'R6Description.R6DescGadgetNone';
			NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(GadgetClass.default.m_NameID, "ID_NAME", "R6Gadgets");
			NewItem.m_Object = GadgetClass;
			// End:0x7BB
			if(__NFUN_114__(GetCurrentGadget(true), GadgetClass))
			{
				SelectedItem = NewItem;
			}
			FirstInsertedItem = CreateGadgetsSeparators();
			i = 0;
			J0x7CE:

			// End:0x99F [Loop If]
			if(__NFUN_150__(i, m_AGadgets.Length))
			{
				GadgetClass = Class<R6GadgetDescription>(m_AGadgets[i]);
				// End:0x995
				if(__NFUN_129__(Class'R6Menu.R6MenuMPAdvGearWidget'.static.CheckGadget(string(GadgetClass), self, false)))
				{
					// End:0x84D
					if(__NFUN_119__(Class<R6GrenadeDescription>(GadgetClass), none))
					{
						NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 1);						
					}
					else
					{
						// End:0x88A
						if(__NFUN_119__(Class<R6ExplosiveDescription>(GadgetClass), none))
						{
							NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 2);							
						}
						else
						{
							// End:0x8C7
							if(__NFUN_119__(Class<R6HBDeviceDescription>(GadgetClass), none))
							{
								NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 3);								
							}
							else
							{
								// End:0x904
								if(__NFUN_119__(Class<R6KitDescription>(GadgetClass), none))
								{
									NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 4);									
								}
								else
								{
									NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 5);
								}
							}
						}
					}
					NewItem.HelpText = Localize(GadgetClass.default.m_NameID, "ID_NAME", "R6Gadgets");
					NewItem.m_Object = GadgetClass;
					// End:0x995
					if(__NFUN_114__(GetCurrentGadget(true), GadgetClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x7CE;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x139D
			break;
		// End:0xB6A
		case 4:
			m_Title.SetNewText(Localize("GearRoom", "SecondaryWeapon", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(1);
			FirstInsertedItem = CreateSecondaryWeaponsSeparators();
			i = 0;
			J0xA1C:

			// End:0xB55 [Loop If]
			if(__NFUN_150__(i, m_ASecondaryWeapons.Length))
			{
				SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(m_ASecondaryWeapons[i]);
				// End:0xA7E
				if(__NFUN_119__(Class<R6PistolsDescription>(SecondaryWeaponClass), none))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 1);					
				}
				else
				{
					// End:0xABB
					if(__NFUN_119__(Class<R6MachinePistolsDescription>(SecondaryWeaponClass), none))
					{
						NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 2);						
					}
					else
					{
						NewItem = R6WindowListBoxItem(FirstInsertedItem.InsertBefore(Class'R6Window.R6WindowListBoxItem'));
					}
				}
				// End:0xB4B
				if(__NFUN_119__(NewItem, none))
				{
					NewItem.HelpText = Localize(SecondaryWeaponClass.default.m_NameID, "ID_NAME", "R6Weapons");
					NewItem.m_Object = SecondaryWeaponClass;
					// End:0xB4B
					if(__NFUN_114__(GetCurrentSecondaryWeapon(), SecondaryWeaponClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0xA1C;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(true);
			// End:0x139D
			break;
		// End:0xDA3
		case 5:
			m_Title.SetNewText(Localize("GearRoom", "SecondaryWeaponGadget", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(3);
			SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(currentOperative.m_szSecondaryWeapon, Class'Core.Class'));
			i = 0;
			J0xBF0:

			// End:0xCD6 [Loop If]
			if(__NFUN_150__(i, SecondaryWeaponClass.default.m_MyGadgets.Length))
			{
				WeaponGadgetDescriptionClass = Class<R6WeaponGadgetDescription>(SecondaryWeaponClass.default.m_MyGadgets[i]);
				// End:0xCCC
				if(__NFUN_119__(WeaponGadgetDescriptionClass, Class'R6Description.R6DescWeaponGadgetNone'))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
					NewItem.m_Object = WeaponGadgetDescriptionClass;
					// End:0xCCC
					if(__NFUN_114__(GetCurrentWeaponGadget(false), WeaponGadgetDescriptionClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0xBF0;
			}
			m_listBox.Items.Sort();
			WeaponGadgetDescriptionClass = Class'R6Description.R6DescWeaponGadgetNone';
			NewItem = R6WindowListBoxItem(m_listBox.Items.InsertAfter(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_NAME", "R6WeaponGadgets");
			NewItem.m_Object = WeaponGadgetDescriptionClass;
			// End:0xD8E
			if(__NFUN_114__(GetCurrentWeaponGadget(false), WeaponGadgetDescriptionClass))
			{
				SelectedItem = NewItem;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x139D
			break;
		// End:0xF2B
		case 6:
			m_Title.SetNewText(Localize("GearRoom", "SecondaryAmmo", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(3);
			SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(currentOperative.m_szSecondaryWeapon, Class'Core.Class'));
			i = 0;
			J0xE21:

			// End:0xEFE [Loop If]
			if(__NFUN_150__(i, SecondaryWeaponClass.default.m_Bullets.Length))
			{
				WeaponBulletDescriptionClass = Class<R6BulletDescription>(SecondaryWeaponClass.default.m_Bullets[i]);
				// End:0xEF4
				if(__NFUN_119__(WeaponBulletDescriptionClass, Class'R6Description.R6DescBulletNone'))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					NewItem.HelpText = Localize(WeaponBulletDescriptionClass.default.m_NameID, "ID_NAME", "R6Ammo");
					NewItem.m_Object = WeaponBulletDescriptionClass;
					// End:0xEF4
					if(__NFUN_114__(GetCurrentWeaponBullet(false), WeaponBulletDescriptionClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0xE21;
			}
			m_listBox.Items.Sort();
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x139D
			break;
		// End:0x1213
		case 7:
			m_Title.SetNewText(Localize("GearRoom", "SecondaryGadget", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(2);
			GadgetClass = Class'R6Description.R6DescGadgetNone';
			NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
			NewItem.HelpText = Localize(GadgetClass.default.m_NameID, "ID_NAME", "R6Gadgets");
			NewItem.m_Object = GadgetClass;
			// End:0x101A
			if(__NFUN_114__(GetCurrentGadget(false), GadgetClass))
			{
				SelectedItem = NewItem;
			}
			FirstInsertedItem = CreateGadgetsSeparators();
			i = 0;
			J0x102D:

			// End:0x11FE [Loop If]
			if(__NFUN_150__(i, m_AGadgets.Length))
			{
				GadgetClass = Class<R6GadgetDescription>(m_AGadgets[i]);
				// End:0x11F4
				if(__NFUN_129__(Class'R6Menu.R6MenuMPAdvGearWidget'.static.CheckGadget(string(GadgetClass), self, false)))
				{
					// End:0x10AC
					if(__NFUN_119__(Class<R6GrenadeDescription>(GadgetClass), none))
					{
						NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 1);						
					}
					else
					{
						// End:0x10E9
						if(__NFUN_119__(Class<R6ExplosiveDescription>(GadgetClass), none))
						{
							NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 2);							
						}
						else
						{
							// End:0x1126
							if(__NFUN_119__(Class<R6HBDeviceDescription>(GadgetClass), none))
							{
								NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 3);								
							}
							else
							{
								// End:0x1163
								if(__NFUN_119__(Class<R6KitDescription>(GadgetClass), none))
								{
									NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 4);									
								}
								else
								{
									NewItem = R6WindowListBoxItem(m_listBox.Items).InsertLastAfterSeparator(Class'R6Window.R6WindowListBoxItem', 5);
								}
							}
						}
					}
					NewItem.HelpText = Localize(GadgetClass.default.m_NameID, "ID_NAME", "R6Gadgets");
					NewItem.m_Object = GadgetClass;
					// End:0x11F4
					if(__NFUN_114__(GetCurrentGadget(false), GadgetClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x102D;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x139D
			break;
		// End:0x139A
		case 8:
			m_Title.SetNewText(Localize("GearRoom", "Armor", "R6Menu"), true);
			m_listBox.Clear();
			UpdateAnchorButtons(3);
			i = 0;
			J0x1265:

			// End:0x1385 [Loop If]
			if(__NFUN_150__(i, m_AArmors.Length))
			{
				ArmorDescriptionClass = Class<R6ArmorDescription>(m_AArmors[i]);
				ArmorForAvailabilityTest = new (none) ArmorDescriptionClass;
				// End:0x137B
				if(__NFUN_130__(__NFUN_130__(__NFUN_242__(ArmorDescriptionClass.default.m_bHideFromMenu, false), GetCurrentOperative().__NFUN_303__(ArmorDescriptionClass.default.m_LimitedToClass)), ArmorForAvailabilityTest.__NFUN_303__(GetCurrentOperative().m_CanUseArmorType)))
				{
					NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
					NewItem.HelpText = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
					NewItem.m_Object = ArmorDescriptionClass;
					// End:0x137B
					if(__NFUN_114__(GetCurrentArmor(), ArmorDescriptionClass))
					{
						SelectedItem = NewItem;
					}
				}
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x1265;
			}
			m_CurrentEquipmentType = _equipmentType;
			enableWeaponStats(false);
			// End:0x139D
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x13CB
	if(__NFUN_119__(SelectedItem, none))
	{
		m_listBox.SetSelectedItem(SelectedItem);
		m_listBox.MakeSelectedVisible();
	}
	return;
}

//This Hides Or display Anchor buttons for equipment that support it
function UpdateAnchorButtons(R6MenuEquipmentAnchorButtons.eAnchorEquipmentType _AEType)
{
	// End:0x8A
	if(__NFUN_154__(int(_AEType), int(3)))
	{
		m_AnchorButtons.HideWindow();
		m_Title.WinTop = 0.0000000;
		m_listBox.WinTop = __NFUN_175__(__NFUN_174__(m_Title.WinTop, m_Title.WinHeight), float(1));
		m_listBox.SetSize(m_listBox.WinWidth, m_fListBoxHeight);		
	}
	else
	{
		m_AnchorButtons.ShowWindow();
		m_AnchorButtons.DisplayButtons(_AEType);
		m_Title.WinTop = __NFUN_175__(__NFUN_174__(m_AnchorButtons.WinTop, m_AnchorButtons.WinHeight), float(1));
		m_listBox.WinTop = __NFUN_175__(__NFUN_174__(m_Title.WinTop, m_Title.WinHeight), float(1));
		m_listBox.SetSize(m_listBox.WinWidth, __NFUN_174__(__NFUN_175__(m_fListBoxHeight, m_AnchorButtons.WinHeight), float(1)));
	}
	return;
}

function BuildAvailableEquipment()
{
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6GadgetDescription> GadgetClass;
	local int i;
	local R6Mod pCurrentMod;
	local int j;

	m_APrimaryWeapons.Remove(0, m_APrimaryWeapons.Length);
	m_ASecondaryWeapons.Remove(0, m_ASecondaryWeapons.Length);
	m_AGadgets.Remove(0, m_AGadgets.Length);
	i = 0;
	pCurrentMod = Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod;
	j = 0;
	J0x50:

	// End:0xF0 [Loop If]
	if(__NFUN_150__(j, pCurrentMod.m_aDescriptionPackage.Length))
	{
		PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(__NFUN_1005__(__NFUN_112__(pCurrentMod.m_aDescriptionPackage[j], ".u"), Class'R6Description.R6PrimaryWeaponDescription'));
		J0x96:

		// End:0xE3 [Loop If]
		if(__NFUN_119__(PrimaryWeaponClass, none))
		{
			// End:0xD2
			if(__NFUN_123__(PrimaryWeaponClass.default.m_NameID, "NONE"))
			{
				m_APrimaryWeapons[i] = PrimaryWeaponClass;
				__NFUN_165__(i);
			}
			PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(__NFUN_1006__());
			// [Loop Continue]
			goto J0x96;
		}
		__NFUN_1007__();
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x50;
	}
	SortDescriptions(true, m_APrimaryWeapons, "R6Weapons");
	i = 0;
	j = 0;
	J0x115:

	// End:0x1B5 [Loop If]
	if(__NFUN_150__(j, pCurrentMod.m_aDescriptionPackage.Length))
	{
		GadgetClass = Class<R6GadgetDescription>(__NFUN_1005__(__NFUN_112__(pCurrentMod.m_aDescriptionPackage[j], ".u"), Class'R6Description.R6GadgetDescription'));
		J0x15B:

		// End:0x1A8 [Loop If]
		if(__NFUN_119__(GadgetClass, none))
		{
			// End:0x197
			if(__NFUN_123__(GadgetClass.default.m_NameID, "NONE"))
			{
				m_AGadgets[i] = GadgetClass;
				__NFUN_165__(i);
			}
			GadgetClass = Class<R6GadgetDescription>(__NFUN_1006__());
			// [Loop Continue]
			goto J0x15B;
		}
		__NFUN_1007__();
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x115;
	}
	SortDescriptions(true, m_AGadgets, "R6Gadgets");
	i = 0;
	j = 0;
	J0x1DA:

	// End:0x27A [Loop If]
	if(__NFUN_150__(j, pCurrentMod.m_aDescriptionPackage.Length))
	{
		SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(__NFUN_1005__(__NFUN_112__(pCurrentMod.m_aDescriptionPackage[j], ".u"), Class'R6Description.R6SecondaryWeaponDescription'));
		J0x220:

		// End:0x26D [Loop If]
		if(__NFUN_119__(SecondaryWeaponClass, none))
		{
			// End:0x25C
			if(__NFUN_123__(SecondaryWeaponClass.default.m_NameID, "NONE"))
			{
				m_ASecondaryWeapons[i] = SecondaryWeaponClass;
				__NFUN_165__(i);
			}
			SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(__NFUN_1006__());
			// [Loop Continue]
			goto J0x220;
		}
		__NFUN_1007__();
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x1DA;
	}
	SortDescriptions(true, m_ASecondaryWeapons, "R6Weapons");
	return;
}

function R6WindowListBoxItem CreatePrimaryWeaponsSeparators()
{
	local R6WindowListBoxItem NewItem, FirstInsertedItem;

	FirstInsertedItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	FirstInsertedItem.HelpText = __NFUN_235__(Localize("SUBGUN", "ID_NAME", "R6Weapons"));
	FirstInsertedItem.m_IsSeparator = true;
	FirstInsertedItem.m_iSeparatorID = 1;
	m_AnchorButtons.m_SUBGUNButton.AnchoredElement = FirstInsertedItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("ASSAULT", "ID_NAME", "R6Weapons"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 2;
	m_AnchorButtons.m_ASSAULTButton.AnchoredElement = NewItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("SHOTGUN", "ID_NAME", "R6Weapons"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 3;
	m_AnchorButtons.m_SHOTGUNButton.AnchoredElement = NewItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("SNIPER", "ID_NAME", "R6Weapons"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 4;
	m_AnchorButtons.m_SNIPERButton.AnchoredElement = NewItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("LMG", "ID_NAME", "R6Weapons"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 5;
	m_AnchorButtons.m_LMGButton.AnchoredElement = NewItem;
	return FirstInsertedItem;
	return;
}

function R6WindowListBoxItem CreateSecondaryWeaponsSeparators()
{
	local R6WindowListBoxItem NewItem, FirstInsertedItem;

	FirstInsertedItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	FirstInsertedItem.HelpText = __NFUN_235__(Localize("PISTOLS", "ID_NAME", "R6Weapons"));
	FirstInsertedItem.m_IsSeparator = true;
	FirstInsertedItem.m_iSeparatorID = 1;
	m_AnchorButtons.m_PISTOLSButton.AnchoredElement = FirstInsertedItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("MACHINEPISTOLS", "ID_NAME", "R6Weapons"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 2;
	m_AnchorButtons.m_MACHINEPISTOLSButton.AnchoredElement = NewItem;
	return FirstInsertedItem;
	return;
}

function R6WindowListBoxItem CreateGadgetsSeparators()
{
	local R6WindowListBoxItem NewItem, FirstInsertedItem;

	FirstInsertedItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	FirstInsertedItem.HelpText = __NFUN_235__(Localize("CATEGORIES", "GRENADES", "R6Gadgets"));
	FirstInsertedItem.m_IsSeparator = true;
	FirstInsertedItem.m_iSeparatorID = 1;
	m_AnchorButtons.m_GRENADESButton.AnchoredElement = FirstInsertedItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("CATEGORIES", "EXPLOSIVES", "R6Gadgets"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 2;
	m_AnchorButtons.m_EXPLOSIVESButton.AnchoredElement = NewItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("CATEGORIES", "HBDEVICE", "R6Gadgets"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 3;
	m_AnchorButtons.m_HBDEVICEButton.AnchoredElement = NewItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("CATEGORIES", "KITS", "R6Gadgets"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 4;
	m_AnchorButtons.m_KITSButton.AnchoredElement = NewItem;
	NewItem = R6WindowListBoxItem(m_listBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
	NewItem.HelpText = __NFUN_235__(Localize("CATEGORIES", "GENERAL", "R6Gadgets"));
	NewItem.m_IsSeparator = true;
	NewItem.m_iSeparatorID = 5;
	m_AnchorButtons.m_GENERALButton.AnchoredElement = NewItem;
	return FirstInsertedItem;
	return;
}

function BuildAvailableMissionArmors()
{
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local int i, nbArmor;
	local R6MissionDescription CurrentMission;
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.__NFUN_1524__();
	m_AArmors.Remove(0, m_AArmors.Length);
	CurrentMission = R6MissionDescription(R6Console(Root.Console).Master.m_StartGameInfo.m_CurrentMission);
	// End:0x65
	if(__NFUN_114__(CurrentMission, none))
	{
		return;
	}
	nbArmor = 0;
	i = 0;
	J0x73:

	// End:0xE6 [Loop If]
	if(__NFUN_150__(i, CurrentMission.m_MissionArmorTypes.Length))
	{
		ArmorDescriptionClass = Class<R6ArmorDescription>(CurrentMission.m_MissionArmorTypes[i]);
		// End:0xDC
		if(__NFUN_123__(ArmorDescriptionClass.default.m_NameID, "NONE"))
		{
			m_AArmors[nbArmor] = ArmorDescriptionClass;
			__NFUN_165__(nbArmor);
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x73;
	}
	// End:0x1F8
	if(__NFUN_129__(pModManager.IsRavenShield()))
	{
		i = 0;
		J0x101:

		// End:0x1F8 [Loop If]
		if(__NFUN_150__(i, pModManager.m_pCurrentMod.m_aDescriptionPackage.Length))
		{
			// End:0x1EE
			if(__NFUN_123__(pModManager.m_pCurrentMod.m_aDescriptionPackage[i], "R6Description"))
			{
				ArmorDescriptionClass = Class<R6ArmorDescription>(__NFUN_1005__(__NFUN_112__(pModManager.m_pCurrentMod.m_aDescriptionPackage[i], ".u"), Class'R6Description.R6ArmorDescription'));
				J0x18A:

				// End:0x1EE [Loop If]
				if(__NFUN_130__(__NFUN_119__(ArmorDescriptionClass, none), __NFUN_242__(ArmorDescriptionClass.default.m_bHideFromMenu, false)))
				{
					// End:0x1DD
					if(__NFUN_123__(ArmorDescriptionClass.default.m_NameID, "NONE"))
					{
						m_AArmors[nbArmor] = ArmorDescriptionClass;
						__NFUN_165__(nbArmor);
					}
					ArmorDescriptionClass = Class<R6ArmorDescription>(__NFUN_1006__());
					// [Loop Continue]
					goto J0x18A;
				}
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x101;
		}
	}
	// End:0x2D9
	if(__NFUN_242__(pModManager.m_pCurrentMod.m_bUseCustomOperatives, true))
	{
		i = 0;
		J0x21D:

		// End:0x2D9 [Loop If]
		if(__NFUN_150__(i, pModManager.GetPackageMgr().GetNbPackage()))
		{
			ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Description.R6ArmorDescription'));
			J0x26E:

			// End:0x2CF [Loop If]
			if(__NFUN_130__(__NFUN_119__(ArmorDescriptionClass, none), __NFUN_242__(ArmorDescriptionClass.default.m_bHideFromMenu, false)))
			{
				m_AArmors[nbArmor] = ArmorDescriptionClass;
				__NFUN_165__(nbArmor);
				ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetNextClassFromPackage());
				// [Loop Continue]
				goto J0x26E;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x21D;
		}
	}
	SortDescriptions(true, m_AArmors, "R6Armor", true);
	return;
}

function Class<R6ArmorDescription> GetDefaultArmor()
{
	// End:0x1C
	if(__NFUN_151__(m_AArmors.Length, 0))
	{
		return Class<R6ArmorDescription>(m_AArmors[0]);		
	}
	else
	{
		return none;
	}
	return;
}

function bool IsAmorAvailable(Class<R6ArmorDescription> lookedUpArmor, R6Operative currentOperative)
{
	local int i;
	local bool bArmorIsAvailble;

	bArmorIsAvailble = false;
	i = 0;
	// End:0x30
	if(__NFUN_129__(currentOperative.__NFUN_303__(lookedUpArmor.default.m_LimitedToClass)))
	{
		return false;
	}
	J0x30:

	// End:0x7A [Loop If]
	if(__NFUN_130__(__NFUN_242__(bArmorIsAvailble, false), __NFUN_150__(i, m_AArmors.Length)))
	{
		// End:0x70
		if(__NFUN_114__(lookedUpArmor, Class<R6ArmorDescription>(m_AArmors[i])))
		{
			bArmorIsAvailble = true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x30;
	}
	return bArmorIsAvailble;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
	local Class<R6WeaponGadgetDescription> WeaponGadgetDescriptionClass;
	local Class<R6BulletDescription> WeaponBulletDescriptionClass;
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local Class<R6GadgetDescription> GadgetDescriptionClass;
	local R6WindowListBoxItem SelectedItem;
	local string NewString;
	local int itemPos, i;

	// End:0x969
	if(__NFUN_154__(int(E), 2))
	{
		switch(C)
		{
			// End:0x81A
			case m_listBox:
				switch(m_CurrentEquipmentType)
				{
					// End:0x312
					case 0:
						SelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
						PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(SelectedItem.m_Object);
						NewString = Localize(PrimaryWeaponClass.default.m_NameID, "ID_Description", "R6Weapons", false, true);
						NotifyEquipmentChanged(m_CurrentEquipmentType, PrimaryWeaponClass);
						m_WeaponStats.m_fInitRangePercent = float(PrimaryWeaponClass.default.m_ARangePercent[0]);
						m_WeaponStats.m_fInitDamagePercent = float(PrimaryWeaponClass.default.m_ADamagePercent[0]);
						m_WeaponStats.m_fInitAccuracyPercent = float(PrimaryWeaponClass.default.m_AAccuracyPercent[0]);
						m_WeaponStats.m_fInitRecoilPercent = float(PrimaryWeaponClass.default.m_ARecoilPercent[0]);
						m_WeaponStats.m_fInitRecoveryPercent = float(PrimaryWeaponClass.default.m_ARecoveryPercent[0]);
						m_WeaponStats.m_fRangePercent = m_WeaponStats.m_fInitRangePercent;
						m_WeaponStats.m_fDamagePercent = m_WeaponStats.m_fInitDamagePercent;
						m_WeaponStats.m_fAccuracyPercent = m_WeaponStats.m_fInitAccuracyPercent;
						m_WeaponStats.m_fRecoilPercent = m_WeaponStats.m_fInitRecoilPercent;
						m_WeaponStats.m_fRecoveryPercent = m_WeaponStats.m_fInitRecoveryPercent;
						WeaponGadgetDescriptionClass = GetCurrentWeaponGadget(true);
						// End:0x300
						if(__NFUN_119__(WeaponGadgetDescriptionClass, Class'R6Description.R6DescWeaponGadgetNone'))
						{
							i = 0;
							J0x1FA:

							// End:0x300 [Loop If]
							if(__NFUN_150__(i, PrimaryWeaponClass.default.m_WeaponTags.Length))
							{
								// End:0x2F6
								if(__NFUN_122__(PrimaryWeaponClass.default.m_WeaponTags[i], WeaponGadgetDescriptionClass.default.m_NameTag))
								{
									m_WeaponStats.m_fRangePercent = float(PrimaryWeaponClass.default.m_ARangePercent[i]);
									m_WeaponStats.m_fDamagePercent = float(PrimaryWeaponClass.default.m_ADamagePercent[i]);
									m_WeaponStats.m_fAccuracyPercent = float(PrimaryWeaponClass.default.m_AAccuracyPercent[i]);
									m_WeaponStats.m_fRecoilPercent = float(PrimaryWeaponClass.default.m_ARecoilPercent[i]);
									m_WeaponStats.m_fRecoveryPercent = float(PrimaryWeaponClass.default.m_ARecoveryPercent[i]);
									// [Explicit Break]
									goto J0x300;
								}
								__NFUN_165__(i);
								// [Loop Continue]
								goto J0x1FA;
							}
						}
						J0x300:

						m_WeaponStats.ResizeCharts();
						// End:0x817
						break;
					// End:0x316
					case 1:
					// End:0x39D
					case 5:
						SelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
						WeaponGadgetDescriptionClass = Class<R6WeaponGadgetDescription>(SelectedItem.m_Object);
						NewString = Localize(WeaponGadgetDescriptionClass.default.m_NameID, "ID_Description", "R6WeaponGadgets", false, true);
						NotifyEquipmentChanged(m_CurrentEquipmentType, WeaponGadgetDescriptionClass);
						// End:0x817
						break;
					// End:0x3A2
					case 2:
					// End:0x420
					case 6:
						SelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
						WeaponBulletDescriptionClass = Class<R6BulletDescription>(SelectedItem.m_Object);
						NewString = Localize(WeaponBulletDescriptionClass.default.m_NameID, "ID_Description", "R6Ammo", false, true);
						NotifyEquipmentChanged(m_CurrentEquipmentType, WeaponBulletDescriptionClass);
						// End:0x817
						break;
					// End:0x425
					case 3:
					// End:0x4A6
					case 7:
						SelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
						GadgetDescriptionClass = Class<R6GadgetDescription>(SelectedItem.m_Object);
						NewString = Localize(GadgetDescriptionClass.default.m_NameID, "ID_Description", "R6Gadgets", false, true);
						NotifyEquipmentChanged(m_CurrentEquipmentType, GadgetDescriptionClass);
						// End:0x817
						break;
					// End:0x795
					case 4:
						SelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
						SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(SelectedItem.m_Object);
						NewString = Localize(SecondaryWeaponClass.default.m_NameID, "ID_Description", "R6Weapons", false, true);
						NotifyEquipmentChanged(m_CurrentEquipmentType, SecondaryWeaponClass);
						m_WeaponStats.m_fInitRangePercent = float(SecondaryWeaponClass.default.m_ARangePercent[0]);
						m_WeaponStats.m_fInitDamagePercent = float(SecondaryWeaponClass.default.m_ADamagePercent[0]);
						m_WeaponStats.m_fInitAccuracyPercent = float(SecondaryWeaponClass.default.m_AAccuracyPercent[0]);
						m_WeaponStats.m_fInitRecoilPercent = float(SecondaryWeaponClass.default.m_ARecoilPercent[0]);
						m_WeaponStats.m_fInitRecoveryPercent = float(SecondaryWeaponClass.default.m_ARecoveryPercent[0]);
						m_WeaponStats.m_fRangePercent = m_WeaponStats.m_fInitRangePercent;
						m_WeaponStats.m_fDamagePercent = m_WeaponStats.m_fInitDamagePercent;
						m_WeaponStats.m_fAccuracyPercent = m_WeaponStats.m_fInitAccuracyPercent;
						m_WeaponStats.m_fRecoilPercent = m_WeaponStats.m_fInitRecoilPercent;
						m_WeaponStats.m_fRecoveryPercent = m_WeaponStats.m_fInitRecoveryPercent;
						WeaponGadgetDescriptionClass = GetCurrentWeaponGadget(false);
						// End:0x783
						if(__NFUN_119__(WeaponGadgetDescriptionClass, Class'R6Description.R6DescWeaponGadgetNone'))
						{
							i = 0;
							J0x67D:

							// End:0x783 [Loop If]
							if(__NFUN_150__(i, SecondaryWeaponClass.default.m_WeaponTags.Length))
							{
								// End:0x779
								if(__NFUN_122__(SecondaryWeaponClass.default.m_WeaponTags[i], WeaponGadgetDescriptionClass.default.m_NameTag))
								{
									m_WeaponStats.m_fRangePercent = float(SecondaryWeaponClass.default.m_ARangePercent[i]);
									m_WeaponStats.m_fDamagePercent = float(SecondaryWeaponClass.default.m_ADamagePercent[i]);
									m_WeaponStats.m_fAccuracyPercent = float(SecondaryWeaponClass.default.m_AAccuracyPercent[i]);
									m_WeaponStats.m_fRecoilPercent = float(SecondaryWeaponClass.default.m_ARecoilPercent[i]);
									m_WeaponStats.m_fRecoveryPercent = float(SecondaryWeaponClass.default.m_ARecoveryPercent[i]);
									// [Explicit Break]
									goto J0x783;
								}
								__NFUN_165__(i);
								// [Loop Continue]
								goto J0x67D;
							}
						}
						J0x783:

						m_WeaponStats.ResizeCharts();
						// End:0x817
						break;
					// End:0x814
					case 8:
						SelectedItem = R6WindowListBoxItem(m_listBox.m_SelectedItem);
						ArmorDescriptionClass = Class<R6ArmorDescription>(SelectedItem.m_Object);
						NewString = Localize(ArmorDescriptionClass.default.m_NameID, "ID_Description", "R6Armor", false, true);
						NotifyEquipmentChanged(m_CurrentEquipmentType, ArmorDescriptionClass);
						// End:0x817
						break;
					// End:0xFFFF
					default:
						break;
				}
				// End:0x969
				break;
			// End:0x82B
			case m_AnchorButtons.m_ASSAULTButton:
			// End:0x83C
			case m_AnchorButtons.m_LMGButton:
			// End:0x84D
			case m_AnchorButtons.m_SHOTGUNButton:
			// End:0x85E
			case m_AnchorButtons.m_SNIPERButton:
			// End:0x86F
			case m_AnchorButtons.m_SUBGUNButton:
			// End:0x880
			case m_AnchorButtons.m_PISTOLSButton:
			// End:0x891
			case m_AnchorButtons.m_MACHINEPISTOLSButton:
			// End:0x8A2
			case m_AnchorButtons.m_GRENADESButton:
			// End:0x8B3
			case m_AnchorButtons.m_EXPLOSIVESButton:
			// End:0x8C4
			case m_AnchorButtons.m_HBDEVICEButton:
			// End:0x8D5
			case m_AnchorButtons.m_KITSButton:
			// End:0x966
			case m_AnchorButtons.m_GENERALButton:
				itemPos = R6WindowListBoxItem(m_listBox.Items).FindItemIndex(R6WindowListBoxAnchorButton(C).AnchoredElement);
				// End:0x963
				if(__NFUN_153__(itemPos, 0))
				{
					m_listBox.m_VertSB.pos = 0.0000000;
					m_listBox.m_VertSB.Scroll(float(itemPos));
				}
				// End:0x969
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		// End:0x9B1
		if(__NFUN_130__(__NFUN_119__(m_EquipmentText, none), __NFUN_123__(NewString, "")))
		{
			m_EquipmentText.Clear(true, true);
			m_EquipmentText.AddText(NewString, m_DescriptionTextColor, m_DescriptionTextFont);
		}
		return;
	}
}

function enableWeaponStats(bool _enable)
{
	// End:0x6B
	if(_enable)
	{
		m_Buttons.ShowWindow();
		m_EquipmentText.WinTop = m_WeaponStats.WinTop;
		m_EquipmentText.WinHeight = m_WeaponStats.WinHeight;
		m_EquipmentText.Resize();
		ChangePage(1);		
	}
	else
	{
		m_WeaponStats.HideWindow();
		m_EquipmentText.WinTop = __NFUN_175__(__NFUN_174__(m_listBox.WinTop, m_listBox.WinHeight), float(1));
		m_EquipmentText.WinHeight = __NFUN_175__(WinHeight, m_EquipmentText.WinTop);
		m_EquipmentText.Resize();
		m_EquipmentText.ShowWindow();
		m_Buttons.HideWindow();
	}
	return;
}

function ChangePage(int _Page)
{
	switch(_Page)
	{
		// End:0x2C
		case 0:
			m_WeaponStats.HideWindow();
			m_EquipmentText.ShowWindow();
			// End:0x72
			break;
		// End:0x51
		case 1:
			m_WeaponStats.ShowWindow();
			m_EquipmentText.HideWindow();
			// End:0x72
			break;
		// End:0xFFFF
		default:
			m_WeaponStats.HideWindow();
			m_EquipmentText.ShowWindow();
			break;
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x5B
	if(m_bDrawListBg)
	{
		R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, m_listBox.WinLeft, m_listBox.WinTop, m_listBox.WinWidth, m_listBox.WinHeight);
	}
	return;
}

//=============================================================================
// Simple bubble sort to list servers in alphabetical order of name 
//=============================================================================
static function SortDescriptions(bool _bAscending, out array< Class > Descriptions, string LocalizationFile, optional bool bUseTags)
{
	local int i, j;
	local Class temp;
	local bool bSwap;

	i = 0;
	J0x07:

	// End:0x213 [Loop If]
	if(__NFUN_150__(i, __NFUN_147__(Descriptions.Length, 1)))
	{
		j = 0;
		J0x21:

		// End:0x209 [Loop If]
		if(__NFUN_150__(j, __NFUN_147__(__NFUN_147__(Descriptions.Length, 1), i)))
		{
			// End:0xD7
			if(bUseTags)
			{
				// End:0x92
				if(_bAscending)
				{
					bSwap = __NFUN_116__(__NFUN_235__(Class<R6Description>(Descriptions[j]).default.m_NameTag), __NFUN_235__(Class<R6Description>(Descriptions[static.__NFUN_146__(j, 1)]).default.m_NameTag));					
				}
				else
				{
					bSwap = __NFUN_115__(__NFUN_235__(Class<R6Description>(Descriptions[j]).default.m_NameTag), __NFUN_235__(Class<R6Description>(Descriptions[static.__NFUN_146__(j, 1)]).default.m_NameTag));
				}				
			}
			else
			{
				// End:0x14D
				if(_bAscending)
				{
					bSwap = __NFUN_116__(__NFUN_235__(Localize(Class<R6Description>(Descriptions[j]).default.m_NameID, "ID_NAME", LocalizationFile)), __NFUN_235__(Localize(Class<R6Description>(Descriptions[static.__NFUN_146__(j, 1)]).default.m_NameID, "ID_NAME", LocalizationFile)));					
				}
				else
				{
					bSwap = __NFUN_115__(__NFUN_235__(Localize(Class<R6Description>(Descriptions[j]).default.m_NameID, "ID_NAME", LocalizationFile)), __NFUN_235__(Localize(Class<R6Description>(Descriptions[static.__NFUN_146__(j, 1)]).default.m_NameID, "ID_NAME", LocalizationFile)));
				}
			}
			// End:0x1FF
			if(bSwap)
			{
				temp = Descriptions[j];
				Descriptions[j] = Descriptions[__NFUN_146__(j, 1)];
				Descriptions[__NFUN_146__(j, 1)] = temp;
			}
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x21;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//=================================================================================
// ShowWindow: This is call when an equipement was selected, force the keyfocus on the list box
//=================================================================================
function ShowWindow()
{
	m_listBox.SetAcceptsFocus();
	super(UWindowWindow).ShowWindow();
	return;
}

defaultproperties
{
	m_bDrawListBg=true
	m_fListBoxLabelHeight=17.0000000
	m_fListBoxHeight=136.0000000
	m_fAnchorAreaHeight=23.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: function IsA
