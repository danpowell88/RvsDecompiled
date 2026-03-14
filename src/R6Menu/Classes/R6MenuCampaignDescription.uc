//=============================================================================
// R6MenuCampaignDescription - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuCampaignDescription.uc : In single player, show the status of the current 
//                                  selected campaign        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCampaignDescription extends UWindowWindow;

var int m_DrawStyle;
var float m_HPadding;
// NEW IN 1.60
var float m_VPadding;
// NEW IN 1.60
var float m_VSpaceBetweenElements;
// NEW IN 1.60
var float m_LabelHeight;
var R6WindowTextLabel m_MissionTitle;
// NEW IN 1.60
var R6WindowTextLabel m_NameTitle;
// NEW IN 1.60
var R6WindowTextLabel m_DifficultyTitle;
var R6WindowTextLabel m_MissionValue;
// NEW IN 1.60
var R6WindowTextLabel m_NameValue;
// NEW IN 1.60
var R6WindowTextLabel m_DifficultyValue;
var Texture m_BGTexture;
var Region m_BGTextureRegion;
var Color m_vBGColor;

function Created()
{
	local float labelWidth, RightLabelX, DifficultyWidth, NameWidth;

	labelWidth = __NFUN_175__(__NFUN_172__(WinWidth, float(2)), m_HPadding);
	RightLabelX = __NFUN_175__(__NFUN_175__(WinWidth, labelWidth), m_HPadding);
	DifficultyWidth = 135.0000000;
	NameWidth = 75.0000000;
	m_MissionTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_HPadding, m_VPadding, labelWidth, m_LabelHeight, self));
	m_MissionTitle.m_bDrawBorders = false;
	m_MissionTitle.Align = 0;
	m_MissionTitle.TextColor = Root.Colors.White;
	m_MissionTitle.m_Font = Root.Fonts[5];
	m_MissionTitle.Text = Localize("SinglePlayer", "Mission", "R6Menu");
	m_MissionTitle.m_BGTexture = none;
	m_NameTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_HPadding, __NFUN_174__(__NFUN_174__(m_MissionTitle.WinTop, m_MissionTitle.WinHeight), m_VSpaceBetweenElements), NameWidth, m_LabelHeight, self));
	m_NameTitle.m_bDrawBorders = false;
	m_NameTitle.Align = 0;
	m_NameTitle.TextColor = Root.Colors.White;
	m_NameTitle.m_Font = Root.Fonts[5];
	m_NameTitle.Text = Localize("SinglePlayer", "Name", "R6Menu");
	m_NameTitle.m_BGTexture = none;
	m_DifficultyTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_HPadding, __NFUN_174__(__NFUN_174__(m_NameTitle.WinTop, m_NameTitle.WinHeight), m_VSpaceBetweenElements), DifficultyWidth, m_LabelHeight, self));
	m_DifficultyTitle.m_bDrawBorders = false;
	m_DifficultyTitle.Align = 0;
	m_DifficultyTitle.TextColor = Root.Colors.White;
	m_DifficultyTitle.m_Font = Root.Fonts[5];
	m_DifficultyTitle.Text = Localize("SinglePlayer", "Difficulty", "R6Menu");
	m_DifficultyTitle.m_BGTexture = none;
	m_MissionValue = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', RightLabelX, m_VPadding, labelWidth, m_LabelHeight, self));
	m_MissionValue.m_bDrawBorders = false;
	m_MissionValue.Align = 1;
	m_MissionValue.TextColor = Root.Colors.White;
	m_MissionValue.m_Font = Root.Fonts[5];
	m_MissionValue.m_BGTexture = none;
	m_NameValue = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', __NFUN_174__(m_NameTitle.WinLeft, m_NameTitle.WinWidth), __NFUN_174__(__NFUN_174__(m_MissionTitle.WinTop, m_MissionTitle.WinHeight), m_VSpaceBetweenElements), __NFUN_175__(__NFUN_171__(labelWidth, float(2)), m_NameTitle.WinWidth), m_LabelHeight, self));
	m_NameValue.m_bDrawBorders = false;
	m_NameValue.Align = 1;
	m_NameValue.TextColor = Root.Colors.White;
	m_NameValue.m_Font = Root.Fonts[5];
	m_NameValue.m_BGTexture = none;
	m_DifficultyValue = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', __NFUN_174__(m_DifficultyTitle.WinLeft, m_DifficultyTitle.WinWidth), __NFUN_174__(__NFUN_174__(m_NameTitle.WinTop, m_NameTitle.WinHeight), m_VSpaceBetweenElements), __NFUN_175__(__NFUN_171__(labelWidth, float(2)), m_DifficultyTitle.WinWidth), m_LabelHeight, self));
	m_DifficultyValue.m_bDrawBorders = false;
	m_DifficultyValue.Align = 1;
	m_DifficultyValue.TextColor = Root.Colors.White;
	m_DifficultyValue.m_Font = Root.Fonts[5];
	m_DifficultyValue.m_BGTexture = none;
	m_vBGColor = Root.Colors.Black;
	return;
}

defaultproperties
{
	m_DrawStyle=5
	m_HPadding=12.0000000
	m_VPadding=18.0000000
	m_VSpaceBetweenElements=25.0000000
	m_LabelHeight=12.0000000
	m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_BGTextureRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=24866,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var g
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: function Paint
