//=============================================================================
// R6WindowEditControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowEditControl.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowEditControl extends UWindowEditControl;

var bool m_bUseSpecialPaint;  // use this special paint
var bool m_bDisabled;  // true, the control is disable
var R6WindowTextLabel m_pTextLabel;

function Created()
{
	// End:0x11
	if((!bNoKeyboard))
	{
		SetAcceptsFocus();
	}
	EditBox = UWindowEditBox(CreateWindow(Class'R6Window.R6WindowEditBox', 0.0000000, 0.0000000, WinWidth, WinHeight));
	EditBox.NotifyOwner = self;
	EditBoxWidth = WinWidth;
	SetEditTextColor(Root.Colors.BlueLight);
	return;
}

//=======================================================================================================
//=======================================================================================================
// DISPLAY
function BeforePaint(Canvas C, float X, float Y)
{
	// End:0x20
	if((!m_bUseSpecialPaint))
	{
		super.BeforePaint(C, X, Y);
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture t;

	// End:0xD1
	if(m_bUseSpecialPaint)
	{
		// End:0x14
		if(m_bDisabled)
		{
			return;
		}
		// End:0xCE
		if((m_pTextLabel != none))
		{
			// End:0x6C
			if(EditBox.m_bMouseOn)
			{
				m_pTextLabel.TextColor = Root.Colors.ButtonTextColor[2];
				ParentWindow.MouseEnter();				
			}
			else
			{
				// End:0xCE
				if(m_pTextLabel.TextColor != Root.Colors.White)
				{
					m_pTextLabel.TextColor = Root.Colors.White;
					ParentWindow.MouseLeave();
				}
			}
		}		
	}
	else
	{
		super.Paint(C, X, Y);
	}
	return;
}

function ForceCaps(bool choice)
{
	// End:0x2B
	if((R6WindowEditBox(EditBox) != none))
	{
		R6WindowEditBox(EditBox).bCaps = choice;
	}
	return;
}

function ModifyEditBoxW(float _fX, float _fY, float _fWidth, float _fHeight)
{
	EditBox.WinLeft = _fX;
	EditBox.WinTop = _fY;
	EditBox.WinWidth = _fWidth;
	EditBox.WinHeight = _fHeight;
	EditBox.Font = 5;
	EditBoxWidth = EditBox.WinWidth;
	m_bUseSpecialPaint = true;
	return;
}

function CreateTextLabel(string _szTitle, float _fX, float _fY, float _fWidth, float _fHeight)
{
	m_pTextLabel = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', _fX, _fY, _fWidth, _fHeight, self));
	m_pTextLabel.SetProperties(_szTitle, 0, Root.Fonts[5], Root.Colors.White, false);
	return;
}

//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetEditControlStatus(bool _bDisable)
{
	m_bDisabled = _bDisable;
	EditBox.bCanEdit = (!_bDisable);
	// End:0x59
	if(_bDisable)
	{
		m_pTextLabel.TextColor = Root.Colors.ButtonTextColor[1];		
	}
	else
	{
		m_pTextLabel.TextColor = Root.Colors.ButtonTextColor[0];
	}
	return;
}

//====================================================================
// SetEditBoxTip: set the tooltipstring, this string is return to the parent window when the mouse is over the edit box
//====================================================================
function SetEditBoxTip(string _szToolTip)
{
	EditBox.ToolTipString = _szToolTip;
	return;
}

defaultproperties
{
	m_bUseSpecialPaint=true
}
