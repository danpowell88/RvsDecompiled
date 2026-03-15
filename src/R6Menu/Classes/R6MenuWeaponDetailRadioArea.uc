//=============================================================================
// R6MenuWeaponDetailRadioArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuWeaponDetailRadioArea.uc : Top buttons that allow us to change from weapon
//                                  stats to the text description
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/02 * Created by Alexandre Dionne
//=============================================================================
class R6MenuWeaponDetailRadioArea extends UWindowDialogClientWindow;

var float m_fButtonTabWidth;
// NEW IN 1.60
var float m_fButtonTabHeight;
var float m_fFirstButtonOffset;
var float m_fBetweenButtonOffset;
var R6WindowStayDownButton m_WeaponHistoryButton;
var R6WindowStayDownButton m_WeaponStatsButton;
var R6WindowStayDownButton m_CurrentSelectedButton;
var Region m_RHistoryUp;
// NEW IN 1.60
var Region m_RHistoryOver;
// NEW IN 1.60
var Region m_RHistoryDown;
// NEW IN 1.60
var Region m_RStatsUp;
// NEW IN 1.60
var Region m_RStatsOver;
// NEW IN 1.60
var Region m_RStatsDown;

function Created()
{
	local Texture ButtonTexture;
	local float fYPos;

	ButtonTexture = Texture(DynamicLoadObject("R6MenuTextures.Tab_Icon00", Class'Engine.Texture'));
	fYPos = (WinHeight - float(m_RHistoryUp.H));
	m_WeaponHistoryButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', m_fFirstButtonOffset, fYPos, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_WeaponHistoryButton.UpRegion = m_RHistoryUp;
	m_WeaponHistoryButton.OverRegion = m_RHistoryOver;
	m_WeaponHistoryButton.DownRegion = m_RHistoryDown;
	m_WeaponHistoryButton.UpTexture = ButtonTexture;
	m_WeaponHistoryButton.OverTexture = ButtonTexture;
	m_WeaponHistoryButton.DownTexture = ButtonTexture;
	m_WeaponHistoryButton.m_iDrawStyle = 5;
	m_WeaponHistoryButton.m_iButtonID = 0;
	m_WeaponHistoryButton.ToolTipString = Localize("GearRoom", "WEAPONDESC", "R6Menu");
	m_WeaponHistoryButton.m_bCanBeUnselected = false;
	m_WeaponHistoryButton.bUseRegion = true;
	m_CurrentSelectedButton = m_WeaponHistoryButton;
	m_CurrentSelectedButton.m_bSelected = true;
	m_WeaponStatsButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', ((m_WeaponHistoryButton.WinLeft + m_WeaponHistoryButton.WinWidth) + m_fBetweenButtonOffset), fYPos, m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_WeaponStatsButton.UpRegion = m_RStatsUp;
	m_WeaponStatsButton.OverRegion = m_RStatsOver;
	m_WeaponStatsButton.DownRegion = m_RStatsDown;
	m_WeaponStatsButton.UpTexture = ButtonTexture;
	m_WeaponStatsButton.OverTexture = ButtonTexture;
	m_WeaponStatsButton.DownTexture = ButtonTexture;
	m_WeaponStatsButton.m_iDrawStyle = 5;
	m_WeaponStatsButton.m_iButtonID = 1;
	m_WeaponStatsButton.ToolTipString = Localize("GearRoom", "WEAPONSTATS", "R6Menu");
	m_WeaponStatsButton.m_bCanBeUnselected = false;
	m_WeaponStatsButton.bUseRegion = true;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x98
	if((int(E) == 2))
	{
		// End:0x98
		if(((R6WindowStayDownButton(C) != none) && (R6WindowStayDownButton(C) != m_CurrentSelectedButton)))
		{
			m_CurrentSelectedButton.m_bSelected = false;
			m_CurrentSelectedButton = R6WindowStayDownButton(C);
			m_CurrentSelectedButton.m_bSelected = true;
			// End:0x98
			if((R6MenuEquipmentDetailControl(OwnerWindow) != none))
			{
				R6MenuEquipmentDetailControl(OwnerWindow).ChangePage(m_CurrentSelectedButton.m_iButtonID);
			}
		}
	}
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	m_CurrentSelectedButton.m_bSelected = false;
	m_CurrentSelectedButton = m_WeaponStatsButton;
	m_CurrentSelectedButton.m_bSelected = true;
	return;
}

defaultproperties
{
	m_fButtonTabWidth=37.0000000
	m_fButtonTabHeight=20.0000000
	m_fFirstButtonOffset=2.0000000
	m_RHistoryUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RHistoryOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RHistoryDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=29218,ZoneNumber=0)
	m_RStatsUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=16162,ZoneNumber=0)
	m_RStatsOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=21538,ZoneNumber=0)
	m_RStatsDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=26914,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
