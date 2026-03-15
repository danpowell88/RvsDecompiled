//=============================================================================
// R6WindowUbiLoginClient - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowPopUpBox.uc : This provides the simple frame for all the pop-up window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================
class R6WindowUbiLoginClient extends UWindowDialogClientWindow;

const K_EDIT_BOX_HEIGHT = 15;
const K_EDIT_BOX_WIDTH = 140;
const K_TEXT_HEIGHT = 15;
const K_TEXT_WIDTH = 130;
const K_VERTICAL_SPACER = 2;
const K_BOTTON_WIDTH = 95;
const K_LEFT_HOR_OFF = 5;
const K_RIGHT_HOR_OFF = 10;

var R6WindowEditControl m_pUserName;  // username edit box
var R6WindowEditControl m_pPassword;  // password edit box
var R6WindowButtonBox m_pSavePassword;  // save password button box
var R6WindowButtonBox m_pAutoLogIn;  // auto login button box
var R6WindowButton m_pCrAccountBut;  // create account button (takes user to ubi.com website)
var R6WindowTextLabelExt m_pCrAccountText;  // create account text

function SetupClientWindow(float fWindowWidth)
{
	local float fX, fY, fWidth, fHeight;

	fX = 5.0000000;
	fY = 2.0000000;
	fHeight = 15.0000000;
	fWidth = (fWindowWidth - float((5 + 10)));
	m_pUserName = R6WindowEditControl(CreateControl(Class'R6Window.R6WindowEditControl', fX, fY, fWidth, fHeight, self));
	m_pUserName.SetValue("");
	m_pUserName.CreateTextLabel(Localize("MultiPlayer", "PopUp_LoginName", "R6Menu"), 0.0000000, 0.0000000, (fWidth * 0.5000000), fHeight);
	m_pUserName.SetEditBoxTip("");
	fWidth = 165.0000000;
	m_pUserName.ModifyEditBoxW(((fWindowWidth - fWidth) - float(10)), 0.0000000, fWidth, fHeight);
	m_pUserName.EditBox.MaxLength = 15;
	(fY += float((15 + 2)));
	fWidth = (fWindowWidth - float((5 + 10)));
	m_pPassword = R6WindowEditControl(CreateControl(Class'R6Window.R6WindowEditControl', fX, fY, fWidth, fHeight, self));
	m_pPassword.SetValue("");
	m_pPassword.CreateTextLabel(Localize("MultiPlayer", "PopUp_UbiPassword", "R6Menu"), 0.0000000, 0.0000000, (fWidth * 0.5000000), fHeight);
	m_pPassword.SetEditBoxTip("");
	fWidth = 165.0000000;
	m_pPassword.ModifyEditBoxW(((fWindowWidth - fWidth) - float(10)), 0.0000000, fWidth, fHeight);
	m_pPassword.EditBox.MaxLength = 20;
	m_pPassword.EditBox.bPassword = true;
	(fY += float((15 + 2)));
	fWidth = (fWindowWidth - float((5 + 10)));
	m_pSavePassword = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fX, fY, fWidth, fHeight, self, true));
	m_pSavePassword.m_TextFont = Root.Fonts[5];
	m_pSavePassword.m_vTextColor = Root.Colors.White;
	m_pSavePassword.m_vBorder = Root.Colors.White;
	m_pSavePassword.m_bSelected = false;
	m_pSavePassword.CreateTextAndBox(Localize("MultiPlayer", "PopUp_RemPass", "R6Menu"), "", 0.0000000, 0);
	m_pSavePassword.SetButtonBox(true);
	(fY += float((15 + 2)));
	m_pAutoLogIn = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fX, fY, fWidth, fHeight, self, true));
	m_pAutoLogIn.m_TextFont = Root.Fonts[5];
	m_pAutoLogIn.m_vTextColor = Root.Colors.White;
	m_pAutoLogIn.m_vBorder = Root.Colors.White;
	m_pAutoLogIn.m_bSelected = false;
	m_pAutoLogIn.CreateTextAndBox(Localize("MultiPlayer", "PopUp_AutoLogin", "R6Menu"), "", 0.0000000, 0);
	m_pAutoLogIn.SetButtonBox(true);
	(fY += float((15 + 2)));
	fWidth = 130.0000000;
	m_pCrAccountText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', fX, fY, fWidth, fHeight, self));
	m_pCrAccountText.m_Font = Root.Fonts[5];
	m_pCrAccountText.m_vTextColor = Root.Colors.White;
	m_pCrAccountText.AddTextLabel(Localize("MultiPlayer", "PopUp_www", "R6Menu"), 0.0000000, 0.0000000, 200.0000000, 0, false);
	m_pCrAccountText.m_bTextCenterToWindow = true;
	fX = ((fWindowWidth - float(95)) - float(10));
	fWidth = 95.0000000;
	m_pCrAccountBut = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fX, fY, fWidth, fHeight, self, true));
	m_pCrAccountBut.m_vButtonColor = Root.Colors.White;
	m_pCrAccountBut.SetButtonBorderColor(Root.Colors.White);
	m_pCrAccountBut.m_bDrawBorders = true;
	m_pCrAccountBut.Align = 2;
	m_pCrAccountBut.ImageX = 2.0000000;
	m_pCrAccountBut.ImageY = 2.0000000;
	m_pCrAccountBut.m_bDrawSimpleBorder = true;
	m_pCrAccountBut.bStretched = true;
	m_pCrAccountBut.SetText(Localize("MultiPlayer", "PopUp_CrAcct", "R6Menu"));
	m_pCrAccountBut.SetFont(0);
	m_pCrAccountBut.TextColor = Root.Colors.White;
	return;
}

//-------------------------------------------------------------------------
// ManageR6ButtonBoxNotify - Notify function for classes of
// type 'R6WindowButtonBox'
//-------------------------------------------------------------------------
function Notify(UWindowDialogControl C, byte E)
{
	switch(C)
	{
		// End:0x93
		case m_pCrAccountBut:
			// End:0x90
			if((int(E) == 2))
			{
				R6Console(Root.Console).m_GameService.Initialize();
				Root.Console.ConsoleCommand(("startminimized " @ R6Console(Root.Console).m_GameService.m_szUbiHomePage));
			}
			// End:0x13D
			break;
		// End:0x9B
		case m_pSavePassword:
		// End:0x13A
		case m_pAutoLogIn:
			// End:0xF3
			if((int(E) == 2))
			{
				// End:0xF3
				if(R6WindowButtonBox(C).GetSelectStatus())
				{
					R6WindowButtonBox(C).m_bSelected = (!R6WindowButtonBox(C).m_bSelected);
				}
			}
			m_pAutoLogIn.bDisabled = (!m_pSavePassword.m_bSelected);
			// End:0x137
			if(m_pAutoLogIn.bDisabled)
			{
				m_pAutoLogIn.m_bSelected = false;
			}
			// End:0x13D
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

