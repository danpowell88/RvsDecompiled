//=============================================================================
// R6MenuObjectiveLabel - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuObjectiveLabel.uc : A check box plus the objective description
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/05 * Created by Alexandre Dionne
//=============================================================================
class R6MenuObjectiveLabel extends UWindowWindow;

var bool m_bObjectiveCompleted;
var float m_fYPaddingBetweenElements;
var R6WindowTextLabel m_Objective;
var R6WindowTextLabel m_ObjectiveFailed;
var Texture m_TCheckBoxBorder;
// NEW IN 1.60
var Texture m_TCheckBoxMark;
var Region m_RCheckBoxBorder;
// NEW IN 1.60
var Region m_RCheckBoxMark;

function Created()
{
	m_Objective = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', __NFUN_174__(float(m_RCheckBoxBorder.W), m_fYPaddingBetweenElements), 0.0000000, __NFUN_175__(__NFUN_175__(WinWidth, float(m_RCheckBoxBorder.W)), m_fYPaddingBetweenElements), WinHeight, self));
	m_Objective.SetProperties("", 0, Root.Fonts[0], Root.Colors.White, false);
	m_Objective.m_bResizeToText = true;
	m_ObjectiveFailed = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, 10.0000000, WinHeight, self));
	m_ObjectiveFailed.SetProperties("", 0, Root.Fonts[0], Root.Colors.Red, false);
	return;
}

function SetProperties(string _Objective, bool _completed, optional string _szFailed)
{
	m_Objective.m_bResizeToText = true;
	m_Objective.SetNewText(_Objective, true);
	m_bObjectiveCompleted = _completed;
	m_ObjectiveFailed.WinLeft = __NFUN_174__(m_Objective.WinLeft, m_Objective.WinWidth);
	m_ObjectiveFailed.m_bResizeToText = true;
	m_ObjectiveFailed.SetNewText(_szFailed, true);
	return;
}

function SetNewLabelWindowSizes(float _X, float _Y, float _W, float _H)
{
	m_Objective.WinWidth = _W;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	// End:0x7C
	if(m_bObjectiveCompleted)
	{
		DrawStretchedTextureSegment(C, 2.0000000, 2.0000000, float(m_RCheckBoxMark.W), float(m_RCheckBoxMark.H), float(m_RCheckBoxMark.X), float(m_RCheckBoxMark.Y), float(m_RCheckBoxMark.W), float(m_RCheckBoxMark.H), m_TCheckBoxMark);
	}
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_RCheckBoxBorder.W), float(m_RCheckBoxBorder.H), float(m_RCheckBoxBorder.X), float(m_RCheckBoxBorder.Y), float(m_RCheckBoxBorder.W), float(m_RCheckBoxBorder.H), m_TCheckBoxBorder);
	return;
}

defaultproperties
{
	m_fYPaddingBetweenElements=2.0000000
	m_TCheckBoxBorder=Texture'R6MenuTextures.Gui_BoxScroll'
	m_TCheckBoxMark=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RCheckBoxBorder=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=3106,ZoneNumber=0)
	m_RCheckBoxMark=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=13346,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var k
