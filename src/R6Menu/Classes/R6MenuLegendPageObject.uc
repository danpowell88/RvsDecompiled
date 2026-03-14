//=============================================================================
// R6MenuLegendPageObject - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuLegendPageObject.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================
class R6MenuLegendPageObject extends R6MenuLegendPage;

function Created()
{
	super.Created();
	m_szPageTitle = Localize("PlanningLegend", "Object", "R6Menu");
	m_ButtonItem[0] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuLegendItem(m_ButtonItem[0]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_KnownTerrorist';
	m_ButtonItem[0].m_Button = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[0].m_Button.SetText(Localize("PlanningLegend", "ObjectTerrorist", "R6Menu"));
	m_ButtonItem[0].m_Button.ToolTipString = Localize("PlanningLegend", "ObjectTerroristTip", "R6Menu");
	m_ButtonItem[0].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[0].m_Button.m_bPlayButtonSnd = false;
	m_ButtonItem[1] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuLegendItem(m_ButtonItem[1]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_KnownHostage';
	m_ButtonItem[1].m_Button = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[1].m_Button.SetText(Localize("PlanningLegend", "ObjectHostage", "R6Menu"));
	m_ButtonItem[1].m_Button.ToolTipString = Localize("PlanningLegend", "ObjectHostageTip", "R6Menu");
	m_ButtonItem[1].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[1].m_Button.m_bPlayButtonSnd = false;
	m_ButtonItem[2] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuLegendItem(m_ButtonItem[2]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_Objective';
	m_ButtonItem[2].m_Button = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[2].m_Button.SetText(Localize("PlanningLegend", "ObjectObjective", "R6Menu"));
	m_ButtonItem[2].m_Button.ToolTipString = Localize("PlanningLegend", "ObjectObjectiveTip", "R6Menu");
	m_ButtonItem[2].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[2].m_Button.m_bPlayButtonSnd = false;
	m_ButtonItem[3] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuLegendItem(m_ButtonItem[3]).m_pObjectIcon = Texture'R6Planning.Legend.PlanLegend_ExtractionCircle';
	m_ButtonItem[3].m_Button = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[3].m_Button.SetText(Localize("PlanningLegend", "ObjectExtraction", "R6Menu"));
	m_ButtonItem[3].m_Button.ToolTipString = Localize("PlanningLegend", "ObjectExtractionTip", "R6Menu");
	m_ButtonItem[3].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[3].m_Button.m_bPlayButtonSnd = false;
	m_ButtonItem[4] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuLegendItem(m_ButtonItem[4]).m_pObjectIcon = Texture'R6Planning.Legend.PlanLegend_InsertionCircle';
	m_ButtonItem[4].m_Button = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[4].m_Button.SetText(Localize("PlanningLegend", "ObjectInsertion", "R6Menu"));
	m_ButtonItem[4].m_Button.ToolTipString = Localize("PlanningLegend", "ObjectInsertionTip", "R6Menu");
	m_ButtonItem[4].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[4].m_Button.m_bPlayButtonSnd = false;
	m_ButtonItem[5] = R6WindowListButtonItem(Items.Append(ListClass));
	R6MenuLegendItem(m_ButtonItem[5]).m_pObjectIcon = Texture'R6Planning.Legend.PlanLegend_ObjectCircle';
	m_ButtonItem[5].m_Button = R6WindowButton(CreateWindow(Class'R6Window.R6WindowButton', 0.0000000, 0.0000000, WinWidth, m_fItemHeight, self));
	m_ButtonItem[5].m_Button.SetText(Localize("PlanningLegend", "ObjectStaticMesh", "R6Menu"));
	m_ButtonItem[5].m_Button.ToolTipString = Localize("PlanningLegend", "ObjectStaticMeshTip", "R6Menu");
	m_ButtonItem[5].m_Button.m_buttonFont = m_FontForButtons;
	m_ButtonItem[5].m_Button.m_bPlayButtonSnd = false;
	return;
}

