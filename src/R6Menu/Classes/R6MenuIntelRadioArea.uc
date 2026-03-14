//=============================================================================
// R6MenuIntelRadioArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuIntelRadioArea.uc : Controls for intel menu (under speaker widget)
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Yannick Joly
//=============================================================================
class R6MenuIntelRadioArea extends UWindowDialogClientWindow;

var R6WindowStayDownButton m_ControlButton;
var R6WindowStayDownButton m_ClarkButton;
var R6WindowStayDownButton m_SweenyButton;
var R6WindowStayDownButton m_NewsButton;
var R6WindowStayDownButton m_MissionButton;
var R6WindowStayDownButton m_CurrentSelectedButton;

function Created()
{
	local Color cFontColor;
	local Font ButtonFont;
	local Texture BGSelecTexture;
	local Region BGRegion;
	local float fXOffset, fYOffset, fStepBetweenControl;

	BGSelecTexture = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", Class'Engine.Texture'));
	ButtonFont = Root.Fonts[16];
	cFontColor = Root.Colors.BlueLight;
	BGRegion.X = 132;
	BGRegion.Y = 24;
	BGRegion.W = 2;
	BGRegion.H = 19;
	fXOffset = 5.0000000;
	fYOffset = 8.0000000;
	fStepBetweenControl = 20.0000000;
	m_ControlButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20.0000000));
	m_ControlButton.ToolTipString = Localize("Tip", "Speaker1", "R6Menu");
	m_ControlButton.Text = Localize("Briefing", "Speaker1", "R6Menu");
	m_ControlButton.Align = 0;
	m_ControlButton.m_buttonFont = ButtonFont;
	m_ControlButton.m_BGSelecTexture = BGSelecTexture;
	m_ControlButton.DownRegion = BGRegion;
	m_ControlButton.m_iButtonID = int(R6MenuIntelWidget(OwnerWindow).0);
	m_ControlButton.m_bUseOnlyNotifyMsg = true;
	__NFUN_184__(fYOffset, fStepBetweenControl);
	m_ClarkButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20.0000000));
	m_ClarkButton.ToolTipString = Localize("Tip", "Speaker2", "R6Menu");
	m_ClarkButton.Text = Localize("Briefing", "Speaker2", "R6Menu");
	m_ClarkButton.Align = 0;
	m_ClarkButton.m_buttonFont = ButtonFont;
	m_ClarkButton.m_BGSelecTexture = BGSelecTexture;
	m_ClarkButton.DownRegion = BGRegion;
	m_ClarkButton.m_iButtonID = int(R6MenuIntelWidget(OwnerWindow).1);
	m_ClarkButton.m_bUseOnlyNotifyMsg = true;
	__NFUN_184__(fYOffset, fStepBetweenControl);
	m_SweenyButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20.0000000));
	m_SweenyButton.ToolTipString = Localize("Tip", "Speaker3", "R6Menu");
	m_SweenyButton.Text = Localize("Briefing", "Speaker3", "R6Menu");
	m_SweenyButton.Align = 0;
	m_SweenyButton.m_buttonFont = ButtonFont;
	m_SweenyButton.DownRegion = BGRegion;
	m_SweenyButton.m_iButtonID = int(R6MenuIntelWidget(OwnerWindow).2);
	m_SweenyButton.m_bUseOnlyNotifyMsg = true;
	__NFUN_184__(fYOffset, fStepBetweenControl);
	m_NewsButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20.0000000));
	m_NewsButton.ToolTipString = Localize("Tip", "Speaker4", "R6Menu");
	m_NewsButton.Text = Localize("Briefing", "Speaker4", "R6Menu");
	m_NewsButton.Align = 0;
	m_NewsButton.m_buttonFont = ButtonFont;
	m_NewsButton.m_BGSelecTexture = BGSelecTexture;
	m_NewsButton.DownRegion = BGRegion;
	m_NewsButton.m_iButtonID = int(R6MenuIntelWidget(OwnerWindow).3);
	m_NewsButton.m_bUseOnlyNotifyMsg = true;
	__NFUN_184__(fYOffset, fStepBetweenControl);
	m_MissionButton = R6WindowStayDownButton(CreateControl(Class'R6Window.R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20.0000000));
	m_MissionButton.ToolTipString = Localize("Tip", "Speaker5", "R6Menu");
	m_MissionButton.Text = Localize("Briefing", "Speaker5", "R6Menu");
	m_MissionButton.Align = 0;
	m_MissionButton.m_buttonFont = ButtonFont;
	m_MissionButton.m_BGSelecTexture = BGSelecTexture;
	m_MissionButton.DownRegion = BGRegion;
	m_MissionButton.m_iButtonID = int(R6MenuIntelWidget(OwnerWindow).4);
	m_MissionButton.m_bUseOnlyNotifyMsg = true;
	m_CurrentSelectedButton = m_ControlButton;
	m_CurrentSelectedButton.m_bSelected = true;
	return;
}

function Reset()
{
	m_CurrentSelectedButton.m_bSelected = false;
	m_CurrentSelectedButton = m_ControlButton;
	m_CurrentSelectedButton.m_bSelected = true;
	return;
}

function AssociateButtons()
{
	AssociateTextWithButton(m_ControlButton, "ID_CONTROL");
	AssociateTextWithButton(m_ClarkButton, "ID_CLARK");
	AssociateTextWithButton(m_SweenyButton, "ID_SWEENY");
	AssociateTextWithButton(m_NewsButton, "ID_NEWSWIRE");
	AssociateTextWithButton(m_MissionButton, "ID_MISSION_ORDER");
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6WindowStayDownButton tmpButton;

	// End:0xAD
	if(__NFUN_154__(int(E), 2))
	{
		tmpButton = R6WindowStayDownButton(C);
		// End:0xAD
		if(__NFUN_119__(tmpButton, none))
		{
			// End:0xAD
			if(__NFUN_130__(__NFUN_119__(tmpButton, m_CurrentSelectedButton), __NFUN_129__(tmpButton.bDisabled)))
			{
				m_CurrentSelectedButton.m_bSelected = false;
				m_CurrentSelectedButton = tmpButton;
				m_CurrentSelectedButton.m_bSelected = true;
				// End:0xAD
				if(__NFUN_119__(R6MenuIntelWidget(OwnerWindow), none))
				{
					R6MenuIntelWidget(OwnerWindow).ManageButtonSelection(m_CurrentSelectedButton.m_iButtonID);
				}
			}
		}
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

function AssociateTextWithButton(R6WindowStayDownButton _R6Button, string _szTextToFind)
{
	local bool bHaveTextForButton;

	bHaveTextForButton = R6MenuIntelWidget(OwnerWindow).SetMissionText(_szTextToFind);
	// End:0x3F
	if(__NFUN_129__(bHaveTextForButton))
	{
		_R6Button.bDisabled = true;		
	}
	else
	{
		_R6Button.bDisabled = false;
	}
	return;
}

