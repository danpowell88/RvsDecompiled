//=============================================================================
// R6WindowButtonAndEditBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowButtonAndEditBox.uc : This class works like its parent class,
//                                with The addition of a text edit box.
//                                Regular Text .... Edit Box .... CheckBox
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/23 * Created by John Bennett
//=============================================================================
class R6WindowButtonAndEditBox extends R6WindowButtonBox;

                                // true if the player selected the button
var R6WindowEditControl m_pEditBox;
var string m_szEditTextHistory;

function Paint(Canvas C, float X, float Y)
{
	super.Paint(C, X, Y);
	// End:0x8B
	if((m_pEditBox != none))
	{
		// End:0x56
		if((m_szEditTextHistory != m_pEditBox.GetValue()))
		{
			m_szEditTextHistory = m_pEditBox.GetValue();
			Notify(1);
		}
		// End:0x8B
		if(m_pEditBox.EditBox.m_CurrentlyEditing)
		{
			m_bSelected = (m_pEditBox.GetValue() != "");
		}
	}
	return;
}

function CreateEditBox(float fWidth)
{
	local int fXPos;

	fXPos = int(((m_fXBox - fWidth) - float(3)));
	m_pEditBox = R6WindowEditControl(CreateWindow(Class'R6Window.R6WindowEditControl', float(fXPos), 0.0000000, fWidth, WinHeight, self));
	m_pEditBox.SetValue("");
	return;
}

//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetDisableButtonAndEditBox(bool _bDisable)
{
	m_pEditBox.EditBox.bCanEdit = (!_bDisable);
	bDisabled = _bDisable;
	// End:0x62
	if(_bDisable)
	{
		m_pEditBox.m_BorderColor = Root.Colors.ButtonTextColor[1];		
	}
	else
	{
		m_pEditBox.m_BorderColor = Root.Colors.ButtonTextColor[0];
	}
	return;
}

function SetEditBoxTip(string _szToolTip)
{
	// End:0x1F
	if((m_pEditBox != none))
	{
		m_pEditBox.SetEditBoxTip(_szToolTip);
	}
	return;
}

