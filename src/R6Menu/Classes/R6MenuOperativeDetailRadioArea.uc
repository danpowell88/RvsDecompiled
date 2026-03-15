//=============================================================================
// R6MenuOperativeDetailRadioArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuOperativeDetailRadioArea.uc : This is the top part of R6WindowOperativeDetailControl
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeDetailRadioArea extends UWindowDialogClientWindow;

var float m_fButtonTabWidth;
// NEW IN 1.60
var float m_fButtonTabHeight;
var float m_fFirstButtonOffset;
var float m_fBetweenButtonOffset;
var R6WindowStayDownButton m_OperativeHistoryButton;
var R6WindowStayDownButton m_OperativeSkillsButton;
var R6WindowStayDownButton m_OperativeBioButton;
var R6WindowStayDownButton m_OperativeStatsButton;
var R6WindowStayDownButton m_CurrentSelectedButton;
var Region m_RHistoryUp;
// NEW IN 1.60
var Region m_RHistoryOver;
// NEW IN 1.60
var Region m_RHistoryDown;
// NEW IN 1.60
var Region m_RSkillsUp;
// NEW IN 1.60
var Region m_RSkillsOver;
// NEW IN 1.60
var Region m_RSkillsDown;
// NEW IN 1.60
var Region m_RBioUp;
// NEW IN 1.60
var Region m_RBioOver;
// NEW IN 1.60
var Region m_RBioDown;
// NEW IN 1.60
var Region m_RStatsUp;
// NEW IN 1.60
var Region m_RStatsOver;
// NEW IN 1.60
var Region m_RStatsDown;

function Created()
{
	local Texture ButtonTexture;
	local int YPos;

	ButtonTexture = Texture(DynamicLoadObject("R6MenuTextures.Tab_Icon00", Class'Engine.Texture'));
	YPos = int((WinHeight - m_fButtonTabHeight));
	m_OperativeHistoryButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', m_fFirstButtonOffset, float(YPos), m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_OperativeHistoryButton.ToolTipString = Localize("Tip", "GearRoomButHistory", "R6Menu");
	m_OperativeHistoryButton.UpRegion = m_RHistoryUp;
	m_OperativeHistoryButton.OverRegion = m_RHistoryOver;
	m_OperativeHistoryButton.DownRegion = m_RHistoryDown;
	m_OperativeHistoryButton.UpTexture = ButtonTexture;
	m_OperativeHistoryButton.OverTexture = ButtonTexture;
	m_OperativeHistoryButton.DownTexture = ButtonTexture;
	m_OperativeHistoryButton.m_iDrawStyle = 5;
	m_OperativeHistoryButton.m_iButtonID = 1;
	m_OperativeHistoryButton.m_bCanBeUnselected = false;
	m_OperativeHistoryButton.bUseRegion = true;
	m_OperativeSkillsButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', ((m_OperativeHistoryButton.WinLeft + m_OperativeHistoryButton.WinWidth) + m_fBetweenButtonOffset), float(YPos), m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_OperativeSkillsButton.ToolTipString = Localize("Tip", "GearRoomButSkills", "R6Menu");
	m_OperativeSkillsButton.UpRegion = m_RSkillsUp;
	m_OperativeSkillsButton.OverRegion = m_RSkillsOver;
	m_OperativeSkillsButton.DownRegion = m_RSkillsDown;
	m_OperativeSkillsButton.UpTexture = ButtonTexture;
	m_OperativeSkillsButton.OverTexture = ButtonTexture;
	m_OperativeSkillsButton.DownTexture = ButtonTexture;
	m_OperativeSkillsButton.m_iDrawStyle = 5;
	m_OperativeSkillsButton.m_iButtonID = 2;
	m_OperativeSkillsButton.m_bCanBeUnselected = false;
	m_OperativeSkillsButton.bUseRegion = true;
	m_OperativeBioButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', ((m_OperativeSkillsButton.WinLeft + m_OperativeSkillsButton.WinWidth) + m_fBetweenButtonOffset), float(YPos), m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_OperativeBioButton.ToolTipString = Localize("Tip", "GearRoomButMedic", "R6Menu");
	m_OperativeBioButton.UpRegion = m_RBioUp;
	m_OperativeBioButton.OverRegion = m_RBioOver;
	m_OperativeBioButton.DownRegion = m_RBioDown;
	m_OperativeBioButton.UpTexture = ButtonTexture;
	m_OperativeBioButton.OverTexture = ButtonTexture;
	m_OperativeBioButton.DownTexture = ButtonTexture;
	m_OperativeBioButton.m_iDrawStyle = 5;
	m_OperativeBioButton.m_iButtonID = 3;
	m_OperativeBioButton.m_bCanBeUnselected = false;
	m_OperativeBioButton.bUseRegion = true;
	m_OperativeStatsButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', ((m_OperativeBioButton.WinLeft + m_OperativeBioButton.WinWidth) + m_fBetweenButtonOffset), float(YPos), m_fButtonTabWidth, m_fButtonTabHeight, self));
	m_OperativeStatsButton.ToolTipString = Localize("Tip", "GearRoomButCampStats", "R6Menu");
	m_OperativeStatsButton.UpRegion = m_RStatsUp;
	m_OperativeStatsButton.OverRegion = m_RStatsOver;
	m_OperativeStatsButton.DownRegion = m_RStatsDown;
	m_OperativeStatsButton.UpTexture = ButtonTexture;
	m_OperativeStatsButton.OverTexture = ButtonTexture;
	m_OperativeStatsButton.DownTexture = ButtonTexture;
	m_OperativeStatsButton.m_iDrawStyle = 5;
	m_OperativeStatsButton.m_iButtonID = 4;
	m_OperativeStatsButton.m_bCanBeUnselected = false;
	m_OperativeStatsButton.bUseRegion = true;
	m_CurrentSelectedButton = m_OperativeSkillsButton;
	m_CurrentSelectedButton.m_bSelected = true;
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
			if((R6MenuOperativeDetailControl(OwnerWindow) != none))
			{
				R6MenuOperativeDetailControl(OwnerWindow).ChangePage(m_CurrentSelectedButton.m_iButtonID);
			}
		}
	}
	return;
}

defaultproperties
{
	m_fButtonTabWidth=37.0000000
	m_fButtonTabHeight=20.0000000
	m_fFirstButtonOffset=2.0000000
	m_RHistoryUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_RHistoryOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_RHistoryDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48674,ZoneNumber=0)
	m_RSkillsUp=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=16162,ZoneNumber=0)
	m_RSkillsOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=21538,ZoneNumber=0)
	m_RSkillsDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=26914,ZoneNumber=0)
	m_RBioUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RBioOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RBioDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=9762,ZoneNumber=0)
	m_RStatsUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RStatsOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
	m_RStatsDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=19490,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
